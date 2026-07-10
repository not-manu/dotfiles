import { CONTENT_WIDTH, bold, cell, fg, fit, pair, palette } from "../core";

const TASKS_FILE = `${process.env.HOME}/TODO.md`;
const MAX_LINES = 8;

let lines: string[] = [];

export const refreshTasks = async (onChange: () => void) => {
  try {
    const content = await Bun.file(TASKS_FILE).text();
    const next = content.split("\n").filter((line) => line.trim() !== "");
    if (JSON.stringify(next) !== JSON.stringify(lines)) {
      lines = next;
      onChange();
    }
  } catch {
    lines = [];
  }
};

const truncate = (text: string, width: number) =>
  text.length > width ? `${text.slice(0, Math.max(0, width - 1))}…` : text;

// Inline markdown accents: `code` cyan, **bold** bold — nvim-ish.
const inline = (text: string, baseColor: string) =>
  fg(baseColor, text)
    .replace(/`([^`]+)`/g, (_, code) => `${fg(palette.cyan, code)}\x1b[38;2;${baseColor}m`)
    .replace(/\*\*([^*]+)\*\*/g, (_, strong) => bold(strong));

// Line-level markdown highlighting, like an nvim buffer:
//   # heading   → bold yellow
//   - [x] done  → green ✓, struck-through muted text
//   - [ ] todo  → muted ○, normal text
//   - bullet    → muted dot, normal text
const highlight = (line: string): string => {
  const width = CONTENT_WIDTH - 3;

  const heading = line.match(/^(#+)\s+(.*)$/);
  if (heading) return ` ${bold(fg(palette.yellow, truncate(heading[2]!, width)))}`;

  const done = line.match(/^\s*-\s*\[x\]\s+(.*)$/i);
  if (done)
    return ` ${fg(palette.green, "✓")} \x1b[9m${fg(palette.muted, truncate(done[1]!, width - 2))}\x1b[29m`;

  const todo = line.match(/^\s*-\s*\[ \]\s+(.*)$/);
  if (todo)
    return ` ${fg(palette.muted, "○")} ${inline(truncate(todo[1]!, width - 2), palette.text)}`;

  const bullet = line.match(/^\s*-\s+(.*)$/);
  if (bullet)
    return ` ${fg(palette.muted, "·")} ${inline(truncate(bullet[1]!, width - 2), palette.text)}`;

  return ` ${inline(truncate(line, width + 2), palette.muted)}`;
};

export const taskLines = (): string[] => {
  if (!lines.length) return [];

  // Skip the "# todo/tasks" title — the section header already says it.
  const body = lines.filter((line) => !/^#\s*(tasks|todo)\s*$/i.test(line));

  // Nothing open (or everything checked off) → a little victory lap.
  const open = body.filter((line) => !/^\s*-\s*\[x\]/i.test(line));
  if (open.length === 0) {
    return [
      pair("TODO", "", palette.yellow, palette.muted, CONTENT_WIDTH, true),
      fit(` ${fg(palette.green, "✓")} ${fg(palette.muted, "all done — go outside")}`, CONTENT_WIDTH),
      cell(),
    ];
  }

  const shown = body.slice(0, MAX_LINES);
  const hidden = body.length - shown.length;

  return [
    pair("TODO", hidden > 0 ? `+${hidden}` : "", palette.yellow, palette.muted, CONTENT_WIDTH, true),
    ...shown.map((line) => fit(highlight(line), CONTENT_WIDTH)),
    cell(),
  ];
};
