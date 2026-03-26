#!/bin/bash
#!/bin/bash
#!/bin/bash

STATE_FILE="/tmp/cpu_power_mode"
# This file tracks if the user manually picked a mode to stop the auto-switch from fighting you
OVERRIDE_FILE="/tmp/cpu_power_override"

# Get current status
CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity)
STATUS=$(cat /sys/class/power_supply/BAT0/status)

# Function to apply settings
apply_mode() {
  local mode=$1
  local notify_type=$2
  local msg=$3

  sudo cpupower frequency-set -g "$mode" >/dev/null
  echo "$mode" >"$STATE_FILE"
  notify-send -u "$notify_type" -i "speedometer" "Power Management" "$msg"
}

toggle_power() {
  CURRENT_MODE=$(cat "$STATE_FILE" 2>/dev/null || echo "powersave")

  if [ "$CURRENT_MODE" = "powersave" ]; then
    # User explicitly wants performance
    touch "$OVERRIDE_FILE"
    apply_mode "performance" "normal" "Manual Override: PERFORMANCE enabled"
  else
    # User explicitly wants powersave
    rm -f "$OVERRIDE_FILE"
    apply_mode "powersave" "normal" "Manual Override: POWERSAVE enabled"
  fi
}

check_battery() {
  # If we are plugged in, clear overrides and allow performance
  if [ "$STATUS" = "Charging" ] || [ "$STATUS" = "Full" ]; then
    rm -f "$OVERRIDE_FILE"
    return
  fi

  # AUTO-SWITCH LOGIC
  # Only auto-switch to powersave if:
  # 1. Battery < 30%
  # 2. We haven't already auto-switched (checked via STATE_FILE)
  # 3. There is no MANUAL OVERRIDE file present
  if [ "$CAPACITY" -le 30 ] && [ ! -f "$OVERRIDE_FILE" ]; then
    CURRENT_MODE=$(cat "$STATE_FILE" 2>/dev/null)
    if [ "$CURRENT_MODE" != "powersave" ]; then
      apply_mode "powersave" "critical" "Low Battery ($CAPACITY%): Auto-switching to POWERSAVE"
    fi
  fi
}

case "$1" in
toggle) toggle_power ;;
check) check_battery ;;
esac
