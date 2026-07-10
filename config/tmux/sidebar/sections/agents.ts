import { CONTENT_WIDTH, bold, cell, fg, fit, pair, palette, run } from "../core";
import { getPanes, type Pane } from "./processes";

const TOOLS = new Set(["claude", "opencode", "codex"]);
const MAX_SHOWN = 4;

type Status = "working" | "blocked" | "idle";
type Agent = { pane: Pane; tool: string; status: Status };

const STATUS_COLOR: Record<Status, string> = {
  working: palette.yellow,
  blocked: palette.red,
  idle: palette.muted,
};
const STATUS_GLYPH: Record<Status, string> = { working: "●", blocked: "●", idle: "○" };

let agents: Agent[] = [];
let refreshRunning = false;

// Status from what's actually on screen in the pane, with CPU as fallback:
// claude/opencode both show "esc to interrupt" while working, and permission
// prompts while blocked.
const detectStatus = async (pane: Pane, cpu: number): Promise<Status> => {
  const target = `${pane.session}:${pane.windowIndex}.${pane.paneIndex}`;
  const content = (await run(["tmux", "capture-pane", "-p", "-t", target])).toLowerCase();
  const tail = content.split("\n").slice(-25).join("\n");

  if (tail.includes("esc to interrupt")) return "working";
  if (tail.includes("do you want") || tail.includes("waiting for approval")) return "blocked";
  return cpu > 15 ? "working" : "idle";
};

export const refreshAgents = async (onChange: () => void) => {
  if (refreshRunning) return;
  refreshRunning = true;

  // One ps pass with cpu, then walk each pane's tree for an agent process.
  const ps = await run(["/bin/ps", "-axo", "pid=,ppid=,pcpu=,comm="]);
  const children = new Map<number, number[]>();
  const info = new Map<number, { cpu: number; name: string }>();

  for (const line of ps.split("\n")) {
    const match = line.match(/^\s*(\d+)\s+(\d+)\s+([\d.]+)\s+(.+)$/);
    if (!match) continue;
    const pid = Number(match[1]);
    const ppid = Number(match[2]);
    info.set(pid, { cpu: Number(match[3]), name: match[4]!.split("/").at(-1)!.trim() });
    if (!children.has(ppid)) children.set(ppid, []);
    children.get(ppid)!.push(pid);
  }

  const found: { pane: Pane; tool: string; cpu: number }[] = [];
  for (const pane of getPanes()) {
    const queue = [pane.pid];
    while (queue.length) {
      const pid = queue.shift()!;
      const proc = info.get(pid);
      if (proc && TOOLS.has(proc.name)) {
        found.push({ pane, tool: proc.name, cpu: proc.cpu });
        break;
      }
      queue.push(...(children.get(pid) ?? []));
    }
  }

  agents = await Promise.all(
    found.map(async ({ pane, tool, cpu }) => ({
      pane,
      tool,
      status: await detectStatus(pane, cpu),
    })),
  );
  // Attention first: blocked, then working, then idle.
  const rank: Record<Status, number> = { blocked: 0, working: 1, idle: 2 };
  agents.sort((a, b) => rank[a.status] - rank[b.status]);

  refreshRunning = false;
  onChange();
};

export const agentLines = (): string[] => {
  if (!agents.length) return [];

  // Disambiguate duplicate session names with their window index.
  const counts = new Map<string, number>();
  for (const agent of agents) {
    counts.set(agent.pane.session, (counts.get(agent.pane.session) ?? 0) + 1);
  }

  const lines = [
    pair("AGENTS", String(agents.length), palette.purple, palette.muted, CONTENT_WIDTH, true),
  ];
  for (const agent of agents.slice(0, MAX_SHOWN)) {
    const name =
      (counts.get(agent.pane.session) ?? 0) > 1
        ? `${agent.pane.session}:${agent.pane.windowIndex}`
        : agent.pane.session;
    lines.push(
      fit(
        ` ${fg(STATUS_COLOR[agent.status], STATUS_GLYPH[agent.status])} ${bold(fg(palette.text, name))}`,
        CONTENT_WIDTH,
      ),
      fit(
        `   ${fg(STATUS_COLOR[agent.status], agent.status)}${fg(palette.muted, ` · ${agent.tool}`)}`,
        CONTENT_WIDTH,
      ),
    );
  }
  lines.push(cell());
  return lines;
};
