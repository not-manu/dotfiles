// Shared ANSI helpers + the Section contract every feature file implements.

export const dim = (s: string) => `\x1b[90m${s}\x1b[0m`;
export const accent = (s: string) => `\x1b[1;33m${s}\x1b[0m`;

export const HR = dim("  ────────────────────");

// A section returns its lines each tick; main.ts stacks them in order.
export type Section = () => string[];
