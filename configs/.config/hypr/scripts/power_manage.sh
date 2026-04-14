#!/usr/bin/env bash

# Frequencies in kHz
MAX_FREQ=2800000
LOW_FREQ=1900000
MIN_FREQ=800000 # 800 MHz Extreme Mode

# Thresholds
LOW_THRESHOLD=60
CRITICAL_THRESHOLD=30 # Now triggers at 30%

STATE_FILE="/tmp/power_mode_state"
OVERRIDE_FILE="/tmp/power_mode_override"

get_battery() { cat /sys/class/power_supply/BAT0/capacity; }
get_status() { cat /sys/class/power_supply/BAT0/status; }

apply_freq() {
  local freq=$1
  local mode_name=$2
  local prev_mode=$(cat "$STATE_FILE" 2>/dev/null)

  # Only apply and notify if the state actually changes
  if [[ "$mode_name" != "$prev_mode" ]]; then
    for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
      echo "$freq" >"$file" 2>/dev/null
    done
    echo "$mode_name" >"$STATE_FILE"
    notify-send -u normal -i "speedometer" "Power Management" "CPU Mode: ${mode_name}"
  fi
}

check_battery() {
  local status=$(get_status)
  local capacity=$(get_battery)

  # 1. Charger Logic: Resets everything to Max Performance
  if [[ "$status" == "Charging" || "$status" == "Full" ]]; then
    rm -f "$OVERRIDE_FILE"
    apply_freq "$MAX_FREQ" "PERFORMANCE (AC)"
    return
  fi

  # 2. Manual Override Logic: Respect user's toggle until plugged back in
  if [[ -f "$OVERRIDE_FILE" ]]; then
    return
  fi

  # 3. 3-Tier Auto Logic
  if [[ "$capacity" -le $CRITICAL_THRESHOLD ]]; then
    apply_freq "$MIN_FREQ" "EXTREME POWERSAVE (Critical)"
  elif [[ "$capacity" -le $LOW_THRESHOLD ]]; then
    apply_freq "$LOW_FREQ" "POWERSAVE (Low)"
  else
    apply_freq "$MAX_FREQ" "PERFORMANCE (High)"
  fi
}

toggle_mode() {
  local current=$(cat "$STATE_FILE" 2>/dev/null)

  # Toggle manually swaps between Performance and the standard Low mode
  if [[ "$current" == "PERFORMANCE (High)" || "$current" == "MANUAL PERFORMANCE" || "$current" == "PERFORMANCE (AC)" ]]; then
    touch "$OVERRIDE_FILE"
    apply_freq "$LOW_FREQ" "MANUAL POWERSAVE"
  else
    touch "$OVERRIDE_FILE"
    apply_freq "$MAX_FREQ" "MANUAL PERFORMANCE"
  fi
}

case "$1" in
"check") check_battery ;;
"toggle") toggle_mode ;;
esac
