#!/usr/bin/env bun
// tmux sidebar: `sidebar.ts toggle` opens/closes a left pane running `sidebar.ts run`.
import { $ } from "bun";

const SIDEBAR_OPT = "@sidebar_pane";
const LAYOUT_OPT = "@sidebar_layout";
const WIDTH = 30;

async function toggle() {
  // Pane id stored per-window; if it still exists, kill it (close sidebar).
  const existing = (
    await $`tmux show-options -wqv ${SIDEBAR_OPT}`.text()
  ).trim();

  if (existing) {
    const alive = (await $`tmux list-panes -F '#{pane_id}'`.text())
      .split("\n")
      .includes(existing);
    if (alive) {
      await $`tmux kill-pane -t ${existing}`;
      // Restore the layout snapshotted before the sidebar opened.
      const layout = (
        await $`tmux show-options -wqv ${LAYOUT_OPT}`.text()
      ).trim();
      if (layout) await $`tmux select-layout ${layout}`.nothrow();
      await $`tmux set-option -wu ${SIDEBAR_OPT}`;
      await $`tmux set-option -wu ${LAYOUT_OPT}`;
      return;
    }
  }

  // Snapshot layout so closing the sidebar restores pane sizes exactly.
  const layout = (
    await $`tmux display-message -p '#{window_layout}'`.text()
  ).trim();

  // Open on the left, full height, without stealing focus.
  const paneId = (
    await $`tmux split-window -hbf -d -l ${WIDTH} -P -F '#{pane_id}' bun ${import.meta.path} run`.text()
  ).trim();
  await $`tmux set-option -w ${SIDEBAR_OPT} ${paneId}`;
  await $`tmux set-option -w ${LAYOUT_OPT} ${layout}`;
}

async function run() {
  // Placeholder content — replace with real rendering later.
  console.clear();
  process.stdout.write("\x1b[?25l"); // hide cursor
  const cleanup = () => {
    process.stdout.write("\x1b[?25h");
    process.exit(0);
  };
  process.on("SIGINT", cleanup);
  process.on("SIGTERM", cleanup);

  const render = () => {
    console.clear();
    console.log("\x1b[1;33m  ▌ sidebar\x1b[0m");
    console.log("\x1b[90m  ────────────────────\x1b[0m");
    console.log("");
    console.log("  placeholder");
    console.log("");
    console.log(`\x1b[90m  ${new Date().toLocaleTimeString()}\x1b[0m`);
  };

  render();
  setInterval(render, 1000);
}

const cmd = process.argv[2];
if (cmd === "toggle") await toggle();
else if (cmd === "run") await run();
else {
  console.error("usage: sidebar.ts <toggle|run>");
  process.exit(1);
}
