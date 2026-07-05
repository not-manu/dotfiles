#!/usr/bin/env bun
// tmux sidebar rendered inside a borderless overlay popup (see tmux.conf).
// Nothing resizes: the popup floats over the left edge of the window.
// Exits (closing the popup) on C-\, q, or Esc.

console.clear();
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
  console.clear();
  console.log("\x1b[1;33m  ▌ sidebar\x1b[0m");
  console.log("\x1b[90m  ────────────────────\x1b[0m");
  console.log("");
  console.log("  placeholder");
  console.log("");
  console.log(`\x1b[90m  ${new Date().toLocaleTimeString()}\x1b[0m`);
  console.log("");
  console.log("\x1b[90m  C-\\ / q / esc to close\x1b[0m");
};

render();
setInterval(render, 1000);
