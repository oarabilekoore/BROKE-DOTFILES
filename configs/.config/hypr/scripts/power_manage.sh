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

apply_profile() {
  local freq=$1
  local mode_name=$2
  local scheduler=$3
  local prev_mode=$(cat "$STATE_FILE" 2>/dev/null)

  # Only apply and notify if the state actually changes
  if [[ "$mode_name" != "$prev_mode" ]]; then
    # 1. Apply CPU Frequency
    for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
      echo "$freq" >"$file" 2>/dev/null
    done

    # 2. Apply SCX Scheduler
    # scx_loader gracefully stops the current scheduler and starts the new one
    scx_loader -s "$scheduler" >/dev/null 2>&1

    # 3. Update State & Notify
    echo "$mode_name" >"$STATE_FILE"
    notify-send -u normal -i "speedometer" "Power Management" "Mode: ${mode_name}\nScheduler: scx_${scheduler}"
  fi
}

check_battery() {
  local status=$(get_status)
  local capacity=$(get_battery)

  # 1. Charger Logic: Resets everything to Max Performance
  if [[ "$status" == "Charging" || "$status" == "Full" ]]; then
    rm -f "$OVERRIDE_FILE"
    apply_profile "$MAX_FREQ" "PERFORMANCE (AC)" "rustland"
    return
  fi

  # 2. Manual Override Logic: Respect user's toggle until plugged back in
  if [[ -f "$OVERRIDE_FILE" ]]; then
    return
  fi

  # 3. 3-Tier Auto Logic
  if [[ "$capacity" -le $CRITICAL_THRESHOLD ]]; then
    apply_profile "$MIN_FREQ" "EXTREME POWERSAVE (Critical)" "tickless"
  elif [[ "$capacity" -le $LOW_THRESHOLD ]]; then
    apply_profile "$LOW_FREQ" "POWERSAVE (Low)" "lavd"
  else
    apply_profile "$MAX_FREQ" "PERFORMANCE (High)" "rustland"
  fi
}

toggle_mode() {
  local current=$(cat "$STATE_FILE" 2>/dev/null)

  # Toggle manually swaps between Performance and the standard Low mode
  if [[ "$current" == "PERFORMANCE (High)" || "$current" == "MANUAL PERFORMANCE" || "$current" == "PERFORMANCE (AC)" ]]; then
    touch "$OVERRIDE_FILE"
    apply_profile "$LOW_FREQ" "MANUAL POWERSAVE" "lavd"
  else
    touch "$OVERRIDE_FILE"
    apply_profile "$MAX_FREQ" "MANUAL PERFORMANCE" "rustland"
  fi
}

case "$1" in
"check") check_battery ;;
"toggle") toggle_mode ;;
esac
