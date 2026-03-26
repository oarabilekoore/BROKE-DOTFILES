#!/bin/bash
#!/bin/bash
#!/usr/bin/env bash
STATE_FILE="/tmp/caffeine_on"

enable_caffeine() {
  if [[ ! -f "$STATE_FILE" ]]; then
    notify-send "Caffeine Enabled" "Preventing Idle & Lock"
    touch "$STATE_FILE"
    if pgrep hypridle >/dev/null; then
      pkill hypridle
    fi
  fi
}

disable_caffeine() {
  if [[ -f "$STATE_FILE" ]]; then
    notify-send "Caffeine Disabled" "Restoring Idle & Lock"
    rm -f "$STATE_FILE"
    pgrep hypridle >/dev/null || hypridle &
  fi
}

toggle_caffeine() {
  if [[ -f "$STATE_FILE" ]]; then
    disable_caffeine
  else
    enable_caffeine
  fi
}

case "$1" in
"on") enable_caffeine ;;
"off") disable_caffeine ;;
"toggle") toggle_caffeine ;;
"waybar")
  if [[ -f "$STATE_FILE" ]]; then
    echo '{"text": "caffeine-on", "class": "active", "tooltip": "Caffeine is ON"}'
  else
    echo '{"text": "", "class": "inactive", "tooltip": ""}'
  fi
  ;;
*)
  echo "Usage: $0 {on|off|toggle|waybar}"
  ;;
esac
