#!/usr/bin/env bash

# Get metadata using playerctl
PLAYER_STATUS=$(playerctl status 2>/dev/null)

if [ "$PLAYER_STATUS" = "Playing" ] || [ "$PLAYER_STATUS" = "Paused" ]; then
    # Get Artist and Title
    ARTIST=$(playerctl metadata artist 2>/dev/null)
    TITLE=$(playerctl metadata title 2>/dev/null)

    # Format the string
    if [ -n "$ARTIST" ]; then
        RAW_TEXT="$ARTIST - $TITLE"
    else
        RAW_TEXT="$TITLE"
    fi

    # Escape special characters for GTK/Pango markup (&, <, >)
    # This fixes the "Entity did not end with a semicolon" error
    FULL_TEXT=$(echo "$RAW_TEXT" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')

    # Truncate to 30 characters and add ellipsis if necessary
    # Note: We measure the raw length to avoid counting the escaped chars
    if [ ${#RAW_TEXT} -gt 55 ]; then
        DISPLAY_TEXT="${FULL_TEXT:0:27}..."
    else
        DISPLAY_TEXT="$FULL_TEXT"
    fi

    # Set class based on status
    if [ "$PLAYER_STATUS" = "Playing" ]; then
        CLASS="active"
    else
        CLASS="inactive"
    fi

    # Output JSON for Waybar
    echo "{\"text\": \"󰝚 $DISPLAY_TEXT\", \"class\": \"$CLASS\", \"tooltip\": \"$FULL_TEXT\"}"
else
    echo "{\"text\": \"\", \"class\": \"inactive\"}"
fi
