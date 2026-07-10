import { CONTENT_WIDTH, HEIGHT, bg, bold, cell, fg, fit, pair, palette, run } from "../core";

export type AgentStatus = "working" | "blocked" | "idle";

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
  tool?: string; // agent process (claude/opencode/codex) if one runs here
  status?: AgentStatus;
};

type Match = { pane: Pane; score: number };

// Items visible at once: rows left after the top section (12), the JUMP
// header + prompt + gap (3), and any rows other sections reserve (agents),
// at 1 row per item (+1 for the selected detail).
let reservedRows = 0;
export const setReservedRows = (rows: number) => {
  reservedRows = rows;
};
// -16 leaves a guaranteed 2-row gap above the bottom stats (prompt + gap +
// stats block all accounted for).
const visibleCount = () => Math.max(3, HEIGHT - 16 - reservedRows);
const SHELLS = new Set(["zsh", "bash", "fish", "sh", "login", "-zsh", "-bash"]);
const AGENT_TOOLS = new Set(["claude", "opencode", "codex"]);

let panes: Pane[] = [];
let query = "";
let selected = 0;
let scrollOffset = 0;
let listRunning = false;

// Toggleable filters (ctrl-a / ctrl-p): none active → everything shows.
let filterAgents = false;
let filterProcs = false;

// One ps pass → children map, so each pane's full process tree is a cheap BFS.
type ProcessTree = {
  children: Map<number, number[]>;
  names: Map<number, string>;
  cpu: Map<number, number>;
};

const readProcessTree = (output: string): ProcessTree => {
  const children = new Map<number, number[]>();
  const names = new Map<number, string>();
  const cpu = new Map<number, number>();

  for (const line of output.split("\n")) {
    const match = line.match(/^\s*(\d+)\s+(\d+)\s+([\d.]+)\s+(.+)$/);
    if (!match) continue;
    const pid = Number(match[1]);
    const ppid = Number(match[2]);
    names.set(pid, match[4]!.split("/").at(-1)!.trim());
    cpu.set(pid, Number(match[3]));
    if (!children.has(ppid)) children.set(ppid, []);
    children.get(ppid)!.push(pid);
  }

  return { children, names, cpu };
};

const descendants = (pid: number, tree: ProcessTree) => {
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

// First agent process in the pane's tree, with its cpu usage.
const findAgent = (pid: number, tree: ProcessTree) => {
  const queue = [pid];
  while (queue.length) {
    const current = queue.shift()!;
    const name = tree.names.get(current);
    if (name && AGENT_TOOLS.has(name)) return { tool: name, cpu: tree.cpu.get(current) ?? 0 };
    queue.push(...(tree.children.get(current) ?? []));
  }
  return undefined;
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

// Agent status with hysteresis: tool-use pauses (reading files, edits)
// briefly drop the "esc to interrupt" marker even though the agent is still
// going, so "working" only decays to idle after a sustained quiet period.
const WORKING_STICKY_MS = 12_000;
const lastWorkingAt = new Map<string, number>();

const detectStatus = async (target: string, cpu: number): Promise<AgentStatus> => {
  const content = (await run(["tmux", "capture-pane", "-p", "-t", target])).toLowerCase();
  const tail = content.split("\n").slice(-30).join("\n");

  const blocked =
    tail.includes("do you want") ||
    tail.includes("waiting for approval") ||
    tail.includes("permission required");
  if (blocked) {
    lastWorkingAt.delete(target);
    return "blocked";
  }

  const working =
    tail.includes("esc to interrupt") ||
    tail.includes("ctrl+c to interrupt") ||
    /[✻✽✶✳✢·⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏] \w+…/.test(tail) ||
    cpu > 20;
  if (working) {
    lastWorkingAt.set(target, Date.now());
    return "working";
  }

  // Recently working → still working (pause between tool calls, not done).
  const last = lastWorkingAt.get(target);
  if (last && Date.now() - last < WORKING_STICKY_MS) return "working";
  return "idle";
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
    run(["/bin/ps", "-axo", "pid=,ppid=,pcpu=,comm="]),
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

  const result: Pane[] = rows.map((line) => {
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

  // Resolve agent tool + live status for agent panes, in parallel.
  await Promise.all(
    result.map(async (pane) => {
      const agent = Number.isFinite(pane.pid) ? findAgent(pane.pid, tree) : undefined;
      if (!agent) return;
      pane.tool = agent.tool;
      pane.status = await detectStatus(
        `${pane.session}:${pane.windowIndex}.${pane.paneIndex}`,
        agent.cpu,
      );
    }),
  );

  return result;
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

const isRunningProc = (pane: Pane) =>
  !pane.tool && pane.processes.some((name) => !SHELLS.has(name));

const filtered = () => {
  if (!filterAgents && !filterProcs) return panes;
  return panes.filter(
    (pane) => (filterAgents && pane.tool) || (filterProcs && isRunningProc(pane)),
  );
};

// Priority tiers: blocked agents (need attention!) > working agents > idle
// agents > other running processes (node, bun, btop…) > bare shells.
// Within a tier, most recently used first.
const tier = (pane: Pane) => {
  if (pane.status === "blocked") return 0;
  if (pane.status === "working") return 1;
  if (pane.tool) return 2;
  if (pane.processes.some((name) => !SHELLS.has(name))) return 3;
  return 4;
};

// Browse order: three solid blocks — agents, running processes, shells —
// so types never interleave. Within a block, same-session panes sit
// together; sessions rank by their most urgent pane (blocked > working >
// idle), then by recency.
const blockOf = (pane: Pane) => (pane.tool ? 0 : isRunningProc(pane) ? 1 : 2);

const bySessionGroups = (list: Pane[]) => {
  const rank = new Map<string, { tier: number; activity: number }>();
  for (const pane of list) {
    const key = `${blockOf(pane)}:${pane.session}`;
    const current = rank.get(key);
    rank.set(key, {
      tier: Math.min(current?.tier ?? 9, tier(pane)),
      activity: Math.max(current?.activity ?? 0, pane.activity),
    });
  }
  return [...list].sort((a, b) => {
    const blockA = blockOf(a);
    const blockB = blockOf(b);
    if (blockA !== blockB) return blockA - blockB;
    const ra = rank.get(`${blockA}:${a.session}`)!;
    const rb = rank.get(`${blockB}:${b.session}`)!;
    return (
      ra.tier - rb.tier ||
      rb.activity - ra.activity ||
      a.session.localeCompare(b.session) ||
      Number(a.windowIndex) - Number(b.windowIndex) ||
      Number(a.paneIndex) - Number(b.paneIndex)
    );
  });
};

const byTierThenRecency = (a: Pane, b: Pane) =>
  tier(a) - tier(b) || b.activity - a.activity;

// Up to +4 for panes used in the last few hours, decaying to 0 — so recently
// touched panes float up even among equal fuzzy matches.
const recencyBonus = (pane: Pane) => {
  const hoursAgo = (Date.now() / 1000 - pane.activity) / 3600;
  return Math.max(0, 4 - hoursAgo);
};

const matches = (): Match[] => {
  if (!query) {
    return bySessionGroups(filtered()).map((pane) => ({ pane, score: 0 }));
  }
  return filtered()
    .map((pane) => ({
      pane,
      score: fuzzyScore(haystack(pane), query) + (4 - tier(pane)) * 3 + recencyBonus(pane),
    }))
    .filter((match) => match.score > -Infinity)
    .sort((a, b) => b.score - a.score || byTierThenRecency(a.pane, b.pane));
};

// Snapshot of the last pane list; painted instantly on startup while the
// live refresh (ps + git resolution) runs behind it.
const CACHE_FILE = `${process.env.HOME}/.cache/tmux-sidebar-panes.json`;
const STATE_FILE = `${process.env.HOME}/.cache/tmux-sidebar-state.json`;

// Only the filter toggles persist across opens; search always starts fresh.
const saveState = () => {
  void Bun.write(STATE_FILE, JSON.stringify({ filterAgents, filterProcs }));
};

export const toggleAgentFilter = () => {
  filterAgents = !filterAgents;
  selected = 0;
  saveState();
};

export const toggleProcFilter = () => {
  filterProcs = !filterProcs;
  selected = 0;
  saveState();
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
    const state = (await Bun.file(STATE_FILE).json()) as {
      filterAgents?: boolean;
      filterProcs?: boolean;
    };
    filterAgents = state.filterAgents ?? false;
    filterProcs = state.filterProcs ?? false;
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
};

export const backspace = () => {
  query = query.slice(0, -1);
  selected = 0;
};

export const hasQuery = () => query.length > 0;

export const getPanes = () => panes;

// True while any visible agent is working — drives the fast spinner repaint.
export const hasWorkingAgents = () => panes.some((pane) => pane.status === "working");

// Cursor column on the prompt line: after " / " (3 cols) + query, 1-indexed.
export const queryCursorColumn = () => 4 + query.length;

export const clearQuery = () => {
  query = "";
  selected = 0;
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

// Agent status glyph after the name: spinner while working, ✓ when done,
// ● when blocked on approval. Spinner frame keyed to wall clock so it
// animates across renders.
const SPINNER = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

const statusGlyph = (status: AgentStatus) => {
  if (status === "working")
    return fg(palette.yellow, SPINNER[Math.floor(Date.now() / 80) % SPINNER.length]!);
  if (status === "blocked") return fg(palette.red, "●");
  return fg(palette.green, "✓");
};

// Compact single-line rows: "name ⠸   session:win"; the selection is just a
// background highlight, no expansion.
const rowLines = (pane: Pane, isSelected: boolean, width: number) => {
  const name = headline(pane);
  const glyphCols = pane.status ? 2 : 0; // " " + glyph
  const nameWidth = Math.min(name.length, width - 12 - glyphCols);
  const meta = sessionLabel(pane, width - nameWidth - glyphCols - 5);

  const color = isSelected ? palette.cyan : PROCESS_COLORS[name] ?? palette.text;
  const label = bold(fg(color, truncate(name, nameWidth)));
  const suffix = pane.status ? ` ${statusGlyph(pane.status)}` : "";
  const gap = " ".repeat(Math.max(1, width - nameWidth - glyphCols - meta.length - 4));
  const top = fit(`  ${label}${suffix}${gap}${fg(palette.muted, meta)}`, width);

  return isSelected ? [bg(palette.empty, top)] : [top];
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

  // Single prompt line: "/ query" (muted placeholder when empty), filter
  // chips (^a agents, ^p procs) and match count on the right. The terminal
  // cursor sits after the query.
  const count = `${list.length}/${panes.length}`;
  const text = query || "search…";
  const chips = `${fg(filterAgents ? palette.purple : palette.empty, "a")} ${fg(filterProcs ? palette.yellow : palette.empty, "p")}`;
  const gap = " ".repeat(Math.max(1, CONTENT_WIDTH - 3 - text.length - 4 - count.length - 1));
  const input = fit(
    ` ${fg(palette.muted, "/")} ${query ? fg(palette.text, query) : fg(palette.muted, text)}${gap}${chips} ${fg(palette.muted, count)} `,
    CONTENT_WIDTH,
  );

  return [input, cell(), ...rows];
};
