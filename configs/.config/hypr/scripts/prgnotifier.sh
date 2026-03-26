#!/bin/bash

# Check required tools
check_command() {
  if ! command -v "$1" &>/dev/null; then
    echo "Error: $1 not found. Please install $2." >&2
    exit 1
  fi
}

check_command "brightnessctl" "brightnessctl"
check_command "pactl" "pipewire-pulse or pulseaudio"
check_command "notify-send" "libnotify"

# Function to get brightness percentage
get_brightness() {
  local current=$(brightnessctl get)
  local max=$(brightnessctl max)
  echo $(((current * 100) / max))
}

# Function to get volume percentage
get_volume() {
  pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1
}

# Function to determine brightness icon based on level
get_brightness_icon() {
  local level=$1
  if [ "$level" -le 30 ]; then
    echo "display-brightness-low"
  elif [ "$level" -le 70 ]; then
    echo "display-brightness-medium"
  else
    echo "display-brightness-high"
  fi
}

# Function to determine volume icon based on level
get_volume_icon() {
  local level=$1
  # Check if actually muted first
  local mute_status=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
  if [ "$mute_status" = "yes" ]; then
    echo "audio-volume-muted"
  elif [ "$level" -le 30 ]; then
    echo "audio-volume-low"
  elif [ "$level" -le 70 ]; then
    echo "audio-volume-medium"
  else
    echo "audio-volume-high"
  fi
}

# Function to show progress notification
show_progress() {
  local percent=$1
  local title=$2
  local icon=$3
  local message="${percent}%"

  # If volume is muted, override the message
  if [[ "$icon" == "audio-volume-muted" ]]; then
    message="Muted"
    percent=0
  fi

  # Using x-canonical-private-synchronous for SwayNC/mako grouping
  notify-send \
    -u normal \
    -i "$icon" \
    -h string:x-canonical-private-synchronous:"$title" \
    -h int:value:"$percent" \
    -t 1500 \
    "$title" "$message"
}

case "$1" in
"light up")
  brightnessctl set +10%
  curr=$(get_brightness)
  icon=$(get_brightness_icon "$curr")
  show_progress "$curr" "Brightness" "$icon"
  ;;

"light down")
  brightnessctl set 10%-
  curr=$(get_brightness)
  icon=$(get_brightness_icon "$curr")
  show_progress "$curr" "Brightness" "$icon"
  ;;

"volume up")
  # Ensure we unmute first, then increase volume
  pactl set-sink-mute @DEFAULT_SINK@ 0
  pactl set-sink-volume @DEFAULT_SINK@ +10%
  curr=$(get_volume)
  show_progress "$curr" "Volume" "$icon"
  ;;

"volume down")
  # Most users prefer volume down to also unmute,
  # but you can remove the next line if you want it to stay muted.
  pactl set-sink-mute @DEFAULT_SINK@ 0
  pactl set-sink-volume @DEFAULT_SINK@ -10%
  curr=$(get_volume)
  show_progress "$curr" "Volume" "$icon"
  ;;

"volume toggle")
  pactl set-sink-mute @DEFAULT_SINK@ toggle
  mute_status=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
  curr=$(get_volume)

  if [ "$mute_status" = "yes" ]; then
    show_progress "$curr" "Volume" "audio-volume-muted"
  else
    icon=$(get_volume_icon "$curr")
    show_progress "$curr" "Volume" "$icon"
  fi
  ;;

*)
  echo "Usage: $0 {light up|light down|volume up|volume down|volume toggle}" >&2
  exit 1
  ;;
esac
