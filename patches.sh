#!/usr/bin/env bash

set -euo pipefail

echo "Applying post-install patches..."

# Patch 1: Symlink awww to swww for Waypaper compatibility
if command -v awww >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  
  if [[ ! -f "$HOME/.local/bin/swww" ]]; then
    ln -s "$(which awww)" "$HOME/.local/bin/swww"
    echo "Symlinked swww -> awww"
  fi
  
  if command -v awww-daemon >/dev/null 2>&1 && [[ ! -f "$HOME/.local/bin/swww-daemon" ]]; then
    ln -s "$(which awww-daemon)" "$HOME/.local/bin/swww-daemon"
    echo "Symlinked swww-daemon -> awww-daemon"
  fi
else
  echo "awww is not installed. Skipping swww symlink patch."
fi

# Add future patches below this line
