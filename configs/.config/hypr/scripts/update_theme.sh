#!/bin/bash

# Waypaper passes the path as $1
WALLPAPER_PATH="$1"
HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"
AUTOHIDE_SCRIPT="waybar_auto_hide"

if [[ -z "$WALLPAPER_PATH" ]]; then
  echo "No path provided. Usage: ./update_theme.sh /path/to/img.jpg"
  exit 1
fi

# --- 1. UPDATE HYPRLOCK ---
if [ -f "$HYPRLOCK_CONF" ]; then
  ESCAPED_PATH=$(echo "$WALLPAPER_PATH" | sed 's/[\/&]/\\&/g')
  sed -i "/^background {/,/}/ s|^ *path =.*|path = $ESCAPED_PATH|" "$HYPRLOCK_CONF"
fi

# --- 2. GENERATE COLORS (Wallust) ---
wallust run "$WALLPAPER_PATH" >/dev/null

# --- 4. RELOAD APPS ---
pkill -x -SIGUSR2 waybar || (pkill -x waybar && waybar &)

if command -v swaync-client &>/dev/null; then
  swaync-client -rs >/dev/null 2>&1 || true
fi

# Restart Auto-Hide Script
if pgrep -f "$AUTOHIDE_SCRIPT" >/dev/null; then
  pkill -f "$AUTOHIDE_SCRIPT"
fi
nohup "$AUTOHIDE_SCRIPT" >/dev/null 2>&1 &

echo "Theme Sync Complete for $WALLPAPER_PATH"
