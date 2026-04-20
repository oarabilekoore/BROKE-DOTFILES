#!/bin/bash

# Name of your Rust binary
BIN_NAME="waybar_auto_hide"

# Use -f to match the full command line because the name is >15 chars
if pgrep -f "$BIN_NAME" >/dev/null; then

  notify-send "Waybar" "Manual Mode: Locked Open"

  # --- LOCK MODE ---
  # Kill the specific process using the full command line match
  pkill -f "$BIN_NAME"

  # Force Waybar to show immediately
  pkill -SIGUSR2 waybar

  # Optional: Send a notification
else
  # --- AUTO MODE ---

  # Get the directory where this script is saved
  DIR="$(dirname "$(realpath "$0")")"

  # Start the rust binary from the same directory
  nohup "$DIR/$BIN_NAME" >/dev/null 2>&1 &

  notify-send "Waybar" "Auto Mode: Enabled"
fi
