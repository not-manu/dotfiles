import { CONTENT_WIDTH, HEIGHT, bg, bold, cell, fg, fit, palette } from "../core";

type Pane = {
  session: string;
  windowIndex: string;
  window: string;
  paneIndex: string;
  command: string;
  path: string;
  pid: number;
  processes: string[]; // every command in this pane's process tree, e.g. zsh, claude, bun, node
};

type Match = { pane: Pane; score: number };

// Items visible at once: rows left after the top section (12) and the
// search header + gap (2), at 2 rows per item (name + path).
const VISIBLE = Math.max(3, Math.floor((HEIGHT - 14) / 2));
const SHELLS = new Set(["zsh", "bash", "fish", "sh", "login", "-zsh", "-bash"]);

let panes: Pane[] = [];
let query = "";
let selected = 0;
let scrollOffset = 0;
let listRunning = false;

const run = async (command: string[]) => {
  try {
    const child = Bun.spawn(command, { stdout: "pipe", stderr: "ignore" });
    const output = await new Response(child.stdout).text();
    return (await child.exited) === 0 ? output : "";
  } catch {
    return "";
  }
};

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
      "#{session_name}\t#{window_index}\t#{window_name}\t#{pane_index}\t#{pane_current_command}\t#{pane_current_path}\t#{pane_pid}",
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
    const [session, windowIndex, window, paneIndex, command, path, pid] = line.split("\t");
    const panePid = Number(pid);
    return {
      session: session ?? "",
      windowIndex: windowIndex ?? "",
      window: window ?? "",
      paneIndex: paneIndex ?? "",
      command: command ?? "",
      path: displayPaths.get(path ?? "") ?? path ?? "",
      pid: panePid,
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

// A pane is "active" when something beyond the login shell runs in it
// (claude, nvim, a dev server…) — those rank above idle shells.
const isActive = (pane: Pane) => pane.processes.some((name) => !SHELLS.has(name));

const matches = (): Match[] => {
  if (!query) {
    return panes
      .map((pane) => ({ pane, score: isActive(pane) ? 1 : 0 }))
      .sort((a, b) => b.score - a.score);
  }
  return panes
    .map((pane) => ({
      pane,
      score: fuzzyScore(haystack(pane), query) + (isActive(pane) ? 5 : 0),
    }))
    .filter((match) => match.score > -Infinity)
    .sort((a, b) => b.score - a.score);
};

export const refreshPanes = async (onChange: () => void) => {
  if (listRunning) return;
  listRunning = true;
  panes = await listPanes();
  listRunning = false;
  selected = Math.min(selected, Math.max(0, matches().length - 1));
  onChange();
};

export const startProcesses = (onChange: () => void) => {
  void refreshPanes(onChange);
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

// Each result renders as two rows: "▌name   session:win" over a dimmed cwd,
// plus a blank spacer so entries read as cards instead of a wall of text.
const rowLines = (pane: Pane, isSelected: boolean) => {
  const name = headline(pane);
  const nameWidth = Math.min(name.length, CONTENT_WIDTH - 12);
  const meta = sessionLabel(pane, CONTENT_WIDTH - nameWidth - 5);

  const label = isSelected
    ? bold(fg(palette.cyan, truncate(name, nameWidth)))
    : bold(fg(palette.text, truncate(name, nameWidth)));
  const gap = " ".repeat(Math.max(1, CONTENT_WIDTH - nameWidth - meta.length - 4));
  const top = fit(`  ${label}${gap}${fg(palette.muted, meta)}`, CONTENT_WIDTH);
  const bottom = fit(
    `   ${fg(isSelected ? palette.text : palette.muted, shortPath(pane.path, CONTENT_WIDTH - 4))}`,
    CONTENT_WIDTH,
  );

  return isSelected ? [bg(palette.empty, top), bg(palette.empty, bottom)] : [top, bottom];
};

export const processLines = (): string[] => {
  const list = matches();
  if (selected >= list.length) selected = Math.max(0, list.length - 1);

  if (selected < scrollOffset) scrollOffset = selected;
  if (selected >= scrollOffset + VISIBLE) scrollOffset = selected - VISIBLE + 1;
  scrollOffset = Math.max(0, Math.min(scrollOffset, Math.max(0, list.length - VISIBLE)));

  const view = list.slice(scrollOffset, scrollOffset + VISIBLE);
  const rows = view.length
    ? view.flatMap(({ pane }, i) => rowLines(pane, scrollOffset + i === selected))
    : [fit(`  ${fg(palette.muted, query ? "no matches" : "no panes")}`, CONTENT_WIDTH)];

  // Header doubles as the prompt: red search glyph ("⌕", U+2315 — no nerd
  // font needed) + query (or muted placeholder) left, match count right.
  const text = query || "search…";
  const count = `${list.length}/${panes.length}`;
  const gap = " ".repeat(Math.max(1, CONTENT_WIDTH - 4 - text.length - count.length - 1));
  const header = fit(
    ` ${bold(fg(palette.red, "⌕"))} ${query ? bold(fg(palette.red, text)) : fg(palette.muted, text)}${fg(palette.red, "▏")}${gap}${fg(palette.muted, count)} `,
    CONTENT_WIDTH,
  );

  return [header, cell(), ...rows];
};
