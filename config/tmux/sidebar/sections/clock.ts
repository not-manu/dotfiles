import { dim, type Section } from "../ui";

export const clock: Section = () => [dim(`  ${new Date().toLocaleTimeString()}`)];
