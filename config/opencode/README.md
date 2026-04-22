# opencode

Config and a local patch that swaps the TUI splash logo for a pixelarticons smile face.

## Files

- `opencode.json` — opencode config
- `AGENTS.md` — symlink to shared agents config
- `smile-logo.patch` — diff against `packages/opencode/src/cli/logo.ts` replacing the `opencode` wordmark with the smile art
- `rebuild-with-smile.sh` — clones upstream at the matching tag, applies the patch, rebuilds, and swaps in the binary

## Reapplying after an upgrade

`oc upgrade` (or any auto-updater) overwrites `~/.opencode/bin/opencode` with the stock binary, wiping the smile. To reapply:

```sh
~/.dotfiles/config/opencode/rebuild-with-smile.sh
```

With no args it reads the version of the currently installed binary, clones that tag, applies `smile-logo.patch`, rebuilds, and swaps. Pass an explicit tag to target a different version:

```sh
~/.dotfiles/config/opencode/rebuild-with-smile.sh v1.15.0
```

The script keeps a backup of the previous binary at `~/.opencode/bin/opencode.bak`.

## When the patch fails to apply

If upstream rewrites `packages/opencode/src/cli/logo.ts`, `git apply` errors out. Two options:

1. Open `smile-logo.patch` and port the `left`/`right` arrays into the new file shape, or
2. Edit `/tmp/opencode-src/packages/opencode/src/cli/logo.ts` directly, then regenerate:
   ```sh
   cd /tmp/opencode-src && git diff packages/opencode/src/cli/logo.ts \
     > ~/.dotfiles/config/opencode/smile-logo.patch
   ```

## Reverting

```sh
cp ~/.opencode/bin/opencode.bak ~/.opencode/bin/opencode
```

## Build notes

- First `bun install` in the opencode monorepo pulls ~5k packages (~5 min). Subsequent rebuilds are fast — deps live in bun's global store.
- The build script requires `bun >= 1.3.11`. Run `bun upgrade` if it complains.
- `--skip-embed-web-ui` is passed to skip bundling the web UI — the TUI doesn't need it and it cuts build time + binary size (~86M vs ~102M).
- The animated shimmer originates from `(originX, originY)` in `logo.tsx`, tuned for the original wordmark's geometry. On the smaller smile art the sweep looks slightly off-center but still works.
