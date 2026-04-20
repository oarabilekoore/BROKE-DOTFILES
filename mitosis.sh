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

echo "Exporting flatpak packages..."
if command -v flatpak >/dev/null 2>&1; then
  flatpak list --app --columns=application >"$DOT_DIR/pkglist-flatpak.txt"
else
  echo "[WARNING] flatpak not installed, skipping export." >&2
  touch "$DOT_DIR/pkglist-flatpak.txt"
fi

# 2. Backup configurations
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

rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

cd "$HOME" || exit 1

for item in "${CONFIGS[@]}"; do
  if [[ -e "$item" ]]; then
    cp -r --parents "$item" "$BACKUP_DIR/"
    echo "Backed up: $item"
  else
    echo "[WARNING] Skipped: $item (not found)" >&2
  fi
done
