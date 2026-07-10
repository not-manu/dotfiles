export const WIDTH = Math.min(32, process.stdout.columns || 32);
export const HEIGHT = Math.min(32, process.stdout.rows || 32);
export const CONTENT_WIDTH = WIDTH;

export const palette = {
  background: "16;15;15",
  text: "206;205;195",
  muted: "135;133;128",
  empty: "40;39;38",
  red: "209;77;65",
  yellow: "208;162;21",
  green: "135;154;57",
  cyan: "58;169;159",
  blue: "67;133;190",
  purple: "139;126;200",
} as const;

export const fg = (color: string, text: string) =>
  `\x1b[38;2;${color}m${text}\x1b[38;2;${palette.text}m`;

export const bold = (text: string) => `\x1b[1m${text}\x1b[22m`;

const visibleLength = (text: string) => text.replace(/\x1b\[[0-9;?]*[ -/]*[@-~]/g, "").length;

export const fit = (content = "", width = CONTENT_WIDTH) => {
  const padding = Math.max(0, width - visibleLength(content));
  return `${content}${" ".repeat(padding)}`;
};

export const cell = (content = "") => fit(content);

export const pair = (
  left: string,
  right: string,
  leftColor: string = palette.muted,
  rightColor: string = palette.text,
  width: number = CONTENT_WIDTH,
  boldLeft = false,
) => {
  const gap = Math.max(1, width - left.length - right.length - 1);
  const leftText = boldLeft ? bold(fg(leftColor, left)) : fg(leftColor, left);
  return fit(`${leftText}${" ".repeat(gap)}${fg(rightColor, right)} `, width);
};

export const bar = (
  value: number,
  color: string,
  width: number = CONTENT_WIDTH,
  filledGlyph = "█",
  emptyGlyph = "░",
) => {
  const barWidth = width - 1;
  const filled = Math.round(Math.min(1, Math.max(0, value)) * barWidth);
  return fit(`${fg(color, filledGlyph.repeat(filled))}${fg(palette.empty, emptyGlyph.repeat(barWidth - filled))} `, width);
};

export const paint = (lines: string[]) => {
  const background = `\x1b[48;2;${palette.background}m\x1b[38;2;${palette.text}m`;
  const canvas = [...lines, ...Array(Math.max(0, HEIGHT - lines.length)).fill(" ".repeat(WIDTH))];
  const frame = canvas.slice(0, HEIGHT).map((line, index) => `\x1b[${index + 1};1H${line}`).join("");
  process.stdout.write(`\x1b[?25l\x1b[?7l${background}${frame}`);
};

export const restoreTerminal = () => {
  process.stdout.write("\x1b[0m\x1b[?7h\x1b[?25h");
};
