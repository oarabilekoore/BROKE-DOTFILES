#!/usr/bin/env bash

# --- Configuration ---
# Updated directory to where your shaders and the list file actually live
SHADER_DIR="$HOME/.config/hypr/shaders"
LIST_FILE="$SHADER_DIR/available-shaders.list"

# Check if the list file exists
if [[ ! -f "$LIST_FILE" ]]; then
  notify-send "Shader Picker Error" "Could not find $LIST_FILE"
  exit 1
fi

# 1. Parse the text file
# We start the list with the turn off option, then extract "Name - Description"
OPTIONS="Turn off shaders\n"
OPTIONS+=$(awk -F 'name:| description:| file:' '{
    # If the line correctly breaks into our 4 expected segments
    if (NF >= 4) {
        printf "%s - %s\n", $2, $3
    }
}' "$LIST_FILE")

# 2. Display the list in Vicinae using its dmenu subcommand
CHOICE=$(echo -e "$OPTIONS" | vicinae dmenu -p "Select Shader:")

# Exit silently if the user hits ESC or closes Vicinae without selecting
if [[ -z "$CHOICE" ]]; then
  exit 0
fi

# 3. Handle Turning Off Shaders
if [[ "$CHOICE" == "Turn off shaders" ]]; then
  # Clear the shader in Hyprland
  hyprctl keyword decoration:screen_shader "[[EMPTY]]"
  hyprctl keyword debug:damage_tracking 2
  notify-send "Shaders Disabled" "System-wide screen shaders turned off."
  exit 0
fi

# 4. Extract the exact name from the user's choice
# This grabs whatever is before the ' - ' separator
SELECTED_NAME=$(echo "$CHOICE" | awk -F ' - ' '{print $1}')

# 5. Look up the matching filename in your list
SELECTED_FILE=$(awk -F 'name:| description:| file:' -v name="$SELECTED_NAME" '{
    if ($2 == name) {
        print $4
    }
}' "$LIST_FILE")

# 6. Apply the selected shader
if [[ -n "$SELECTED_FILE" ]]; then
  SHADER_PATH="$SHADER_DIR/$SELECTED_FILE"

  if [[ -f "$SHADER_PATH" ]]; then
    # Apply the shader in Hyprland
    hyprctl keyword debug:damage_tracking 1
    hyprctl keyword decoration:screen_shader "$SHADER_PATH"
    notify-send "Shader Applied" "Currently using: $SELECTED_NAME"
  else
    notify-send "Shader Error" "File not found: $SHADER_PATH"
  fi
else
  notify-send "Shader Error" "Could not map choice back to a file."
fi
