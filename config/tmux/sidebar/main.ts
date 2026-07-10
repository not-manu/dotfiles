#!/usr/bin/env bun

import { HEIGHT, cell, paint, restoreTerminal } from "./core";
import { startTop, topLines, updateTop } from "./sections/top";
import {
  appendQuery,
  backspace,
  clearQuery,
  hasQuery,
  hasWorkingAgents,
  jumpToSelected,
  moveSelection,
  processLines,
  queryCursorColumn,
  refreshPanes,
  setReservedRows,
  startProcesses,
  toggleAgentFilter,
  toggleProcFilter,
} from "./sections/processes";
import { refreshTasks, taskLines } from "./sections/tasks";

let closed = false;
const cleanup = () => {
  if (closed) return;
  closed = true;
  process.stdin.setRawMode?.(false);
  restoreTerminal();
  process.exit(0);
};

const render = () => {
  // JUMP up top; TASKS pinned above the system stats at the bottom.
  const stats = topLines();
  const tasks = taskLines();
  setReservedRows(tasks.length); // shrink the process list to make room
  const jump = processLines();
  const filler = Math.max(1, HEIGHT - jump.length - tasks.length - stats.length - 1);
  // Real terminal cursor sits on the prompt line (first row), after the query.
  paint([...jump, ...Array(filler).fill(cell()), ...tasks, ...stats], {
    row: 1,
    column: queryCursorColumn(),
  });
};

process.on("SIGINT", cleanup);
process.on("SIGTERM", cleanup);
process.on("SIGHUP", cleanup);

process.stdin.setRawMode?.(true);
process.stdin.resume();
process.stdin.on("data", (data: Buffer) => {
  const key = data.toString();

  if (key === "\x1c") return cleanup(); // ctrl-\
  if (key === "\x01") {
    toggleAgentFilter(); // ctrl-a
    return render();
  }
  if (key === "\x10") {
    toggleProcFilter(); // ctrl-p
    return render();
  }
  if (key === "\x1b[A") {
    moveSelection(-1);
    return render();
  }
  if (key === "\x1b[B") {
    moveSelection(1);
    return render();
  }
  if (key === "\x1b") {
    // Esc clears an in-progress query first; only quits once it's empty.
    if (hasQuery()) {
      clearQuery();
      return render();
    }
    return cleanup();
  }
  if (key === "\r" || key === "\n") {
    if (jumpToSelected()) return cleanup();
    return;
  }
  if (key === "\x7f" || key === "\b") {
    backspace();
    return render();
  }
  if (key.startsWith("\x1b")) return; // ignore other escape sequences (e.g. left/right arrows)

  const printable = [...key].filter((char) => char >= " " && char !== "\x7f").join("");
  if (printable) {
    appendQuery(printable);
    render();
  }
});

startTop(render);
void startProcesses(render);
void refreshTasks(render);
setInterval(() => updateTop(render), 1000);
// Smooth spinner: repaint at animation rate, but only while something spins.
setInterval(() => {
  if (hasWorkingAgents()) render();
}, 80);
setInterval(() => {
  void refreshPanes(render);
  void refreshTasks(render);
}, 3000);
render();
