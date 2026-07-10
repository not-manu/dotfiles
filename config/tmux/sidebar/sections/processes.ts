import { CONTENT_WIDTH, HEIGHT, bg, bold, cell, fg, fit, pair, palette, run } from "../core";

export type Pane = {
  session: string;
  windowIndex: string;
  window: string;
  paneIndex: string;
  command: string;
  path: string;
  pid: number;
  activity: number; // window_activity timestamp, for most-recently-used sorting
  processes: string[]; // every command in this pane's process tree, e.g. zsh, claude, bun, node
};

type Match = { pane: Pane; score: number };

// Items visible at once: rows left after the top section (12), the JUMP
// header + prompt + gap (3), and any rows other sections reserve (agents),
// at 1 row per item (+1 for the selected detail).
let reservedRows = 0;
export const setReservedRows = (rows: number) => {
  reservedRows = rows;
};
const visibleCount = () => Math.max(3, HEIGHT - 16 - reservedRows);
const SHELLS = new Set(["zsh", "bash", "fish", "sh", "login", "-zsh", "-bash"]);

let panes: Pane[] = [];
let query = "";
let selected = 0;
let scrollOffset = 0;
let listRunning = false;

// One ps pass → children map, so each pane's full process tree is a cheap BFS.
const readProcessTree = (output: string) => {
  const children = new Map<number, number[]>();
  const names = new Map<number, string>();

  for (const line of output.split("\n")) {
    const match = line.match(/^\s*(\d+)\s+(\d+)\s+(.+)$/);
    if (!match) continue;
    const pid = Number(match[1]);
    const ppid = Number(match[2]);
    names.set(pid, match[3]!.split("/").at(-1)!.trim());
    if (!children.has(ppid)) children.set(ppid, []);
    children.get(ppid)!.push(pid);
  }

  return { children, names };
};

const descendants = (
  pid: number,
  tree: { children: Map<number, number[]>; names: Map<number, string> },
) => {
  const commands: string[] = [];
  const queue = [pid];
  while (queue.length) {
    const current = queue.shift()!;
    const name = tree.names.get(current);
    if (name) commands.push(name);
    queue.push(...(tree.children.get(current) ?? []));
  }
  return [...new Set(commands)];
};

// Cache of absolute cwd → display path ("repo" or "repo/sub/dir"), resolved
// via git; non-repo paths fall back to a home-relative path.
const displayPaths = new Map<string, string>();

const resolveDisplayPath = async (absolute: string, homeRelative: string) => {
  const root = (await run(["git", "-C", absolute, "rev-parse", "--show-toplevel"])).trim();
  if (!root) return homeRelative;
  const repo = root.split("/").at(-1)!;
  const rest = absolute.slice(root.length).replace(/^\//, "");
  return rest ? `${repo}/${rest}` : repo;
};

const listPanes = async (): Promise<Pane[]> => {
  const [paneOutput, psOutput] = await Promise.all([
    run([
      "tmux",
      "list-panes",
      "-a",
      "-F",
      "#{session_name}\t#{window_index}\t#{window_name}\t#{pane_index}\t#{pane_current_command}\t#{pane_current_path}\t#{pane_pid}\t#{window_activity}",
    ]),
    run(["/bin/ps", "-axo", "pid=,ppid=,comm="]),
  ]);

  const tree = readProcessTree(psOutput);
  const home = process.env.HOME ?? "";

  const rows = paneOutput
    .split("\n")
    .filter(Boolean)
    .filter((line) => !line.startsWith("_")); // hide _scratch_* etc, like sessions.sh

  // Resolve repo-relative display paths for any cwd we haven't seen yet.
  const absolutePaths = [...new Set(rows.map((line) => line.split("\t")[5] ?? ""))];
  await Promise.all(
    absolutePaths
      .filter((absolute) => absolute && !displayPaths.has(absolute))
      .map(async (absolute) => {
        const homeRelative = home ? absolute.replace(home, "~") : absolute;
        displayPaths.set(absolute, await resolveDisplayPath(absolute, homeRelative));
      }),
  );

  return rows.map((line) => {
    const [session, windowIndex, window, paneIndex, command, path, pid, activity] =
      line.split("\t");
    const panePid = Number(pid);
    return {
      session: session ?? "",
      windowIndex: windowIndex ?? "",
      window: window ?? "",
      paneIndex: paneIndex ?? "",
      command: command ?? "",
      path: displayPaths.get(path ?? "") ?? path ?? "",
      pid: panePid,
      activity: Number(activity) || 0,
      processes: Number.isFinite(panePid) ? descendants(panePid, tree) : [],
    };
  });
};

// The headline process for a row: prefer a non-shell descendant (claude, nvim,
// bun…) over the login shell tmux reports as the pane command.
const headline = (pane: Pane) =>
  pane.processes.find((name) => !SHELLS.has(name)) ?? pane.command ?? "?";

// Subsequence fuzzy match: every query char must appear in order; contiguous
// runs and early matches score higher, like a lightweight fzf.
const fuzzyScore = (text: string, needle: string) => {
  const t = text.toLowerCase();
  const q = needle.toLowerCase();
  let score = 0;
  let cursor = 0;
  let streak = 0;

  for (const char of q) {
    const index = t.indexOf(char, cursor);
    if (index === -1) return -Infinity;
    streak = index === cursor ? streak + 1 : 1;
    score += 1 + streak;
    cursor = index + 1;
  }

  return score - text.length * 0.01;
};

const haystack = (pane: Pane) =>
  `${pane.processes.join(" ")} ${pane.command} ${pane.window} ${pane.session} ${pane.path}`;

// Priority tiers: agents (claude, opencode, codex) > other running processes
// (node, bun, btop…) > bare shells. Within a tier, most recently used first.
const AGENT_TOOLS = new Set(["claude", "opencode", "codex"]);

const tier = (pane: Pane) => {
  if (pane.processes.some((name) => AGENT_TOOLS.has(name))) return 0;
  if (pane.processes.some((name) => !SHELLS.has(name))) return 1;
  return 2;
};

const byTierThenRecency = (a: Pane, b: Pane) =>
  tier(a) - tier(b) || b.activity - a.activity;

const matches = (): Match[] => {
  if (!query) {
    return [...panes].sort(byTierThenRecency).map((pane) => ({ pane, score: 0 }));
  }
  return panes
    .map((pane) => ({
      pane,
      score: fuzzyScore(haystack(pane), query) + (2 - tier(pane)) * 5,
    }))
    .filter((match) => match.score > -Infinity)
    .sort((a, b) => b.score - a.score || byTierThenRecency(a.pane, b.pane));
};

// Snapshot of the last pane list; painted instantly on startup while the
// live refresh (ps + git resolution) runs behind it.
const CACHE_FILE = `${process.env.HOME}/.cache/tmux-sidebar-panes.json`;
const STATE_FILE = `${process.env.HOME}/.cache/tmux-sidebar-state.json`;

const saveState = () => {
  void Bun.write(STATE_FILE, JSON.stringify({ query }));
};

export const refreshPanes = async (onChange: () => void) => {
  if (listRunning) return;
  listRunning = true;
  panes = await listPanes();
  listRunning = false;
  selected = Math.min(selected, Math.max(0, matches().length - 1));
  onChange();
  void Bun.write(CACHE_FILE, JSON.stringify(panes));
};

export const startProcesses = async (onChange: () => void) => {
  const refresh = refreshPanes(onChange);
  try {
    const state = (await Bun.file(STATE_FILE).json()) as { query?: string };
    if (typeof state.query === "string") query = state.query;
  } catch {
    // no saved state yet
  }
  try {
    const cached = (await Bun.file(CACHE_FILE).json()) as Pane[];
    if (listRunning && Array.isArray(cached)) {
      panes = cached;
      onChange();
    }
  } catch {
    // no cache yet — first run
  }
  await refresh;
};

export const appendQuery = (text: string) => {
  query += text;
  selected = 0;
  saveState();
};

export const backspace = () => {
  query = query.slice(0, -1);
  selected = 0;
  saveState();
};

export const hasQuery = () => query.length > 0;

export const getPanes = () => panes;

// Cursor column on the prompt line: after " / " (3 cols) + query, 1-indexed.
export const queryCursorColumn = () => 4 + query.length;

export const clearQuery = () => {
  query = "";
  selected = 0;
  saveState();
};

export const moveSelection = (delta: number) => {
  const count = matches().length;
  if (count === 0) return;
  selected = (selected + delta + count) % count;
};

export const jumpToSelected = (): boolean => {
  const match = matches()[selected];
  if (!match) return false;

  const { session, windowIndex, paneIndex } = match.pane;
  const target = `${session}:${windowIndex}.${paneIndex}`;

  // Inside a display-popup there is no "current client", so switch-client
  // must be pointed at an attached client explicitly.
  const clients = Bun.spawnSync(["tmux", "list-clients", "-F", "#{client_name}"])
    .stdout.toString()
    .split("\n")
    .filter(Boolean);

  if (clients.length === 0) return false;
  for (const client of clients) {
    Bun.spawnSync(["tmux", "switch-client", "-c", client, "-t", target]);
  }
  return true;
};

const truncate = (text: string, width: number) =>
  text.length > width ? `${text.slice(0, Math.max(0, width - 1))}…` : text;

// "~/Documents/Projects/not-manu/localsim" → "…/not-manu/localsim"
const shortPath = (path: string, width: number) => {
  if (path.length <= width) return path;
  const parts = path.split("/");
  while (parts.length > 2 && `…/${parts.slice(1).join("/")}`.length > width) parts.shift();
  const compact = `…/${parts.slice(1).join("/")}`;
  return compact.length <= width ? compact : truncate(parts.at(-1) ?? path, width);
};

// Session label for the right column: drop the hidden-session underscore
// prefix ("_scratch_dotfiles_w17" → "scratch_dotfiles_w17") and keep the tail,
// which is the distinctive part.
const sessionLabel = (pane: Pane, width: number) => {
  const name = pane.session.replace(/^_/, "");
  const label = `${name}:${pane.windowIndex}`;
  return label.length <= width ? label : `…${label.slice(-(width - 1))}`;
};

// Accent color per process, so the list reads at a glance.
const PROCESS_COLORS: Record<string, string> = {
  claude: palette.purple,
  nvim: palette.green,
  bun: palette.yellow,
  node: palette.yellow,
  python: palette.yellow,
  cargo: palette.yellow,
  ssh: palette.blue,
};

// Compact single-line rows: "name   session:win". Only the selected entry
// expands to a second line with its cwd, so the list stays scannable.
const rowLines = (pane: Pane, isSelected: boolean, width: number) => {
  const name = headline(pane);
  const nameWidth = Math.min(name.length, width - 12);
  const meta = sessionLabel(pane, width - nameWidth - 5);

  const color = isSelected ? palette.cyan : PROCESS_COLORS[name] ?? palette.text;
  const label = bold(fg(color, truncate(name, nameWidth)));
  const gap = " ".repeat(Math.max(1, width - nameWidth - meta.length - 4));
  const top = fit(`  ${label}${gap}${fg(palette.muted, meta)}`, width);

  if (!isSelected) return [top];
  const detail = fit(`   ${fg(palette.text, shortPath(pane.path, width - 4))}`, width);
  return [bg(palette.empty, top), bg(palette.empty, detail)];
};

export const processLines = (): string[] => {
  const list = matches();
  const visible = visibleCount();
  if (selected >= list.length) selected = Math.max(0, list.length - 1);

  if (selected < scrollOffset) scrollOffset = selected;
  if (selected >= scrollOffset + visible) scrollOffset = selected - visible + 1;
  scrollOffset = Math.max(0, Math.min(scrollOffset, Math.max(0, list.length - visible)));

  const view = list.slice(scrollOffset, scrollOffset + visible);
  const showBar = list.length > visible;
  const rowWidth = showBar ? CONTENT_WIDTH - 1 : CONTENT_WIDTH;
  let rows = view.length
    ? view.flatMap(({ pane }, i) => rowLines(pane, scrollOffset + i === selected, rowWidth))
    : [fit(`  ${fg(palette.muted, query ? "no matches" : "no panes")}`, CONTENT_WIDTH)];

  // Scrollbar down the right edge: thumb sized/positioned by viewport ratio.
  if (showBar) {
    const thumbLength = Math.max(1, Math.round((visible / list.length) * rows.length));
    const thumbStart = Math.min(
      rows.length - thumbLength,
      Math.round((scrollOffset / list.length) * rows.length),
    );
    rows = rows.map((row, i) => {
      const inThumb = i >= thumbStart && i < thumbStart + thumbLength;
      return `${row}${fg(inThumb ? palette.muted : palette.empty, "▐")}`;
    });
  }

  // JUMP header with match count, then the prompt line: query, or a muted
  // placeholder. The terminal's own cursor sits after the query (see paint).
  const header = pair(
    "JUMP",
    `${list.length}/${panes.length}`,
    palette.blue,
    palette.muted,
    CONTENT_WIDTH,
    true,
  );
  const input = fit(` ${fg(palette.muted, "/")} ${fg(palette.text, query)}`, CONTENT_WIDTH);

  return [header, input, cell(), ...rows];
};
