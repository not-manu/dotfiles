#!/usr/bin/env bun

import { restoreTerminal } from "./core";
import { startTop, updateTop } from "./sections/top";

let closed = false;
const cleanup = () => {
  if (closed) return;
  closed = true;
  process.stdin.setRawMode?.(false);
  restoreTerminal();
  process.exit(0);
};

process.on("SIGINT", cleanup);
process.on("SIGTERM", cleanup);
process.on("SIGHUP", cleanup);

process.stdin.setRawMode?.(true);
process.stdin.resume();
process.stdin.on("data", (data: Buffer) => {
  const key = data.toString();
  if (key.includes("\x1c") || key.includes("q") || key.includes("\x1b")) cleanup();
});

startTop();
setInterval(updateTop, 1000);
