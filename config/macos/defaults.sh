#!/usr/bin/env bash
set -euo pipefail

defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 9
defaults write -g NSUserKeyEquivalents -dict-add "Quit java" "@~^q"
