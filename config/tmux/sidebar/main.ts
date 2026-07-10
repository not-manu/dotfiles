#!/usr/bin/env bun

import { cell, paint, restoreTerminal } from "./core";
import { startTop, topLines, updateTop } from "./sections/top";
import {
  appendQuery,
  backspace,
  clearQuery,
  hasQuery,
  jumpToSelected,
  moveSelection,
  processLines,
  queryCursorColumn,
  refreshPanes,
  startProcesses,
} from "./sections/processes";

let closed = false;
const cleanup = () => {
  if (closed) return;
  closed = true;
  process.stdin.setRawMode?.(false);
  restoreTerminal();
  process.exit(0);
};

const render = () => {
  const top = topLines();
  // Real terminal cursor sits on the prompt line (header + 1), after the query.
  paint([...top, cell(), ...processLines()], {
    row: top.length + 3,
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
startProcesses(render);
setInterval(() => updateTop(render), 1000);
setInterval(() => void refreshPanes(render), 3000);
render();
