#!/usr/bin/env bash
set -euo pipefail

# Reload Karabiner-Elements config by re-selecting the active profile.
karabiner_cli="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

"$karabiner_cli" --select-profile "Default profile"
echo "Karabiner reloaded."
