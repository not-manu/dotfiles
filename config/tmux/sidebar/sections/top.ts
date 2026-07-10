import os from "node:os";

import {
  CONTENT_WIDTH,
  bar,
  cell,
  fit,
  paint,
  pair,
  palette,
} from "../core";

const COLUMN_GAP = 1;

type CpuSnapshot = { idle: number; total: number };
type NetworkSnapshot = { received: number; sent: number; sampledAt: number };

const readCpu = (): CpuSnapshot => {
  let idle = 0;
  let total = 0;

  for (const cpu of os.cpus()) {
    idle += cpu.times.idle;
    total += Object.values(cpu.times).reduce((sum, time) => sum + time, 0);
  }

  return { idle, total };
};

let previousCpu = readCpu();
let cpuUsage = 0;
let memoryUsed = os.totalmem() - os.freemem();
let diskUsed = 0;
let diskFree = 0;
let diskRatio = 0;
let networkReceived = 0;
let networkSent = 0;
let networkDownRate = 0;
let networkUpRate = 0;
let previousNetwork: NetworkSnapshot | undefined;
let refreshRunning = false;
let tick = 0;

const sampleCpu = () => {
  const next = readCpu();
  const totalDelta = next.total - previousCpu.total;
  const idleDelta = next.idle - previousCpu.idle;
  cpuUsage = totalDelta > 0 ? ((totalDelta - idleDelta) / totalDelta) * 100 : 0;
  previousCpu = next;
};

const run = async (command: string[]) => {
  try {
    const child = Bun.spawn(command, { stdout: "pipe", stderr: "ignore" });
    const output = await new Response(child.stdout).text();
    return (await child.exited) === 0 ? output : "";
  } catch {
    return "";
  }
};

const parseMemory = (output: string) => {
  const pageSize = Number(output.match(/page size of (\d+) bytes/)?.[1]);
  if (!pageSize) return;

  const pages = (label: string) =>
    Number(output.match(new RegExp(`Pages ${label}:\\s+(\\d+)\\.`))?.[1] || 0);
  memoryUsed = (pages("active") + pages("wired down") + pages("occupied by compressor")) * pageSize;
};

const parseDisk = (output: string) => {
  const fields = output.trim().split("\n").at(-1)?.trim().split(/\s+/);
  if (!fields || fields.length < 6) return;

  diskUsed = Number(fields[2]) * 1024;
  diskFree = Number(fields[3]) * 1024;
  diskRatio = Number(fields[4]?.replace("%", "")) / 100;
};

const parseNetwork = (output: string) => {
  const interfaces = new Map<string, { received: number; sent: number }>();

  for (const line of output.split("\n")) {
    if (!line.includes("<Link#")) continue;
    const fields = line.trim().split(/\s+/);
    const name = fields[0]!;
    if (name === "lo0" || name.endsWith("*")) continue;

    const received = Number(fields.at(-5));
    const sent = Number(fields.at(-2));
    if (Number.isFinite(received) && Number.isFinite(sent)) interfaces.set(name, { received, sent });
  }

  networkReceived = 0;
  networkSent = 0;
  for (const stats of interfaces.values()) {
    networkReceived += stats.received;
    networkSent += stats.sent;
  }

  const sampledAt = Date.now();
  if (previousNetwork) {
    const seconds = (sampledAt - previousNetwork.sampledAt) / 1000;
    networkDownRate = Math.max(0, networkReceived - previousNetwork.received) / seconds;
    networkUpRate = Math.max(0, networkSent - previousNetwork.sent) / seconds;
  }
  previousNetwork = { received: networkReceived, sent: networkSent, sampledAt };
};

const refreshSlowMetrics = async () => {
  if (refreshRunning) return;
  refreshRunning = true;

  const [memoryOutput, diskOutput, networkOutput] = await Promise.all([
    run(["/usr/bin/vm_stat"]),
    run(["/bin/df", "-kP", "/System/Volumes/Data"]),
    run(["/usr/sbin/netstat", "-ibn"]),
  ]);

  parseMemory(memoryOutput);
  parseDisk(diskOutput);
  parseNetwork(networkOutput);
  refreshRunning = false;
  render();
};

const formatBytes = (bytes: number) => {
  const units = ["B", "K", "M", "G", "T"];
  let value = Math.max(0, bytes);
  let unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  const precision = value >= 100 || unit === 0 ? 0 : value >= 10 ? 1 : 2;
  return `${value.toFixed(precision)}${units[unit]}`;
};

const usageColor = (value: number) =>
  value >= 80 ? palette.red : value >= 50 ? palette.yellow : palette.green;

const render = () => {
  const totalMemory = os.totalmem();
  const memoryRatio = memoryUsed / totalMemory;
  const load = os.loadavg();
  const columnsWidth = CONTENT_WIDTH - COLUMN_GAP;
  const leftWidth = Math.floor(columnsWidth / 2);
  const rightWidth = columnsWidth - leftWidth;
  const columnGap = " ".repeat(COLUMN_GAP);

  paint([
    pair("MEM", `${(memoryRatio * 100).toFixed(0)}%`, palette.yellow, palette.yellow, CONTENT_WIDTH, true),
    bar(memoryRatio, palette.yellow, CONTENT_WIDTH, "━", "━"),
    pair(`used ${formatBytes(memoryUsed)}`, `of ${formatBytes(totalMemory)}`),
    cell(),
    `${pair("CPU", `${cpuUsage.toFixed(0)}%`, palette.cyan, usageColor(cpuUsage), leftWidth, true)}${columnGap}${pair("DISK", `${(diskRatio * 100).toFixed(0)}%`, palette.purple, palette.purple, rightWidth, true)}`,
    `${bar(cpuUsage / 100, usageColor(cpuUsage), leftWidth, "━", "━")}${columnGap}${bar(diskRatio, palette.purple, rightWidth, "━", "━")}`,
    `${fit(`${load[0]!.toFixed(1)} load ${os.cpus().length}c`, leftWidth)}${columnGap}${fit(`${formatBytes(diskUsed)} / ${formatBytes(diskFree)}`, rightWidth)}`,
    cell(),
    pair("NET", `total ${formatBytes(networkReceived + networkSent)}`, palette.blue, palette.text, CONTENT_WIDTH, true),
    pair("down", `${formatBytes(networkDownRate)}/s`, palette.muted, palette.blue),
    pair("up", `${formatBytes(networkUpRate)}/s`, palette.muted, palette.cyan),
    cell(),
    pair("", "q / esc"),
  ]);
};

export const startTop = () => {
  render();
  void refreshSlowMetrics();
};

export const updateTop = () => {
  sampleCpu();
  render();
  if (++tick % 2 === 0) void refreshSlowMetrics();
};
