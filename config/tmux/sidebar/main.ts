#!/usr/bin/env bun
// tmux sidebar entrypoint — runs inside a borderless overlay popup (see tmux.conf).
// Add a feature: create sections/<name>.ts exporting a Section, register it below.

import { accent, dim, HR, type Section } from "./ui";
import { clock } from "./sections/clock";

const placeholder: Section = () => ["  placeholder"];

const sections: Section[] = [placeholder, clock];

process.stdout.write("\x1b[?25l"); // hide cursor
const cleanup = () => {
  process.stdout.write("\x1b[?25h");
  process.exit(0);
};
process.on("SIGINT", cleanup);
process.on("SIGTERM", cleanup);

// Popup owns the keyboard while open, so close keys are handled here.
process.stdin.setRawMode?.(true);
process.stdin.resume();
process.stdin.on("data", (d: Buffer) => {
  const s = d.toString();
  if (s === "\x1c" /* C-\ */ || s === "q" || s === "\x1b" /* Esc */) cleanup();
});

const render = () => {
  const body = sections.flatMap((section) => [...section(), ""]);
  console.clear();
  console.log([accent("  ▌ sidebar"), HR, "", ...body, dim("  C-\\ / q / esc to close")].join("\n"));
};

render();
setInterval(render, 1000);
