#!/usr/bin/env bash

set -euo pipefail

DOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$DOT_DIR/configs"

echo "Starting mitosis (system backup)..."

# 1. Export package lists
echo "Exporting pacman packages..."
pacman -Qqen >"$DOT_DIR/pkglist-pacman.txt"

echo "Exporting yay packages..."
pacman -Qqem >"$DOT_DIR/pkglist-yay.txt" 2>/dev/null || true

# 2. Backup configurations
# Add paths here relative to your home directory
CONFIGS=(
  ".config/hypr"
  ".config/waybar"
  ".config/vicinae"
  ".config/waypaper"
  ".config/swaync"
  ".config/wallust"
  ".config/fish"
  ".config/kitty"
  ".config/nvim"
  ".bashrc"
)

mkdir -p "$BACKUP_DIR"

for item in "${CONFIGS[@]}"; do
  if [[ -e "$HOME/$item" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$item")"
    rsync -a --delete "$HOME/$item" "$BACKUP_DIR/$(dirname "$item")/"
    echo "Backed up: $item"
  else
    echo "[WARNING] Skipped: $item (not found)" >&2
  fi
done

echo "Mitosis complete."
