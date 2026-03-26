#!/bin/bash

# 1. Fetch connected devices
DEVICES=$(adb devices -l | grep -v "List of devices" | sed '/^$/d' | awk '{
    model="Unknown"
    for(i=1;i<=NF;i++) if($i ~ /^model:/) model=$i;
    print $1 " (" model ")"
}' | sed 's/model://g')

MENU_LIST="Connect to New IP\n$DEVICES"
SELECTED=$(echo -e "$MENU_LIST" | vicinae dmenu -p "Select Android Device" -i -l 10)

if [ -z "$SELECTED" ]; then exit 0; fi

if [[ "$SELECTED" == "Connect to New IP" ]]; then
  DEVICE_IP=$(echo "" | vicinae dmenu -p "Enter Phone IP:")
  if [ -z "$DEVICE_IP" ]; then exit 1; fi
  adb connect "$DEVICE_IP"
  TARGET="$DEVICE_IP"
else
  TARGET=$(echo "$SELECTED" | awk '{print $1}')
fi

# 2. Add "Test Settings" to the Mode selection
MODE=$(echo -e "Test-Auto\nGaming-Highest\nGaming-Balanced\nGaming-Low" | vicinae dmenu -p "Select Mode:")

case $MODE in
Test-Auto)
  echo Test Auto Mode
  scrcpy -s "$TARGET"
  ;;
Gaming-Highest)
  echo High Mode
  scrcpy -s "$TARGET" -m 1980 -b 6500k --max-fps 60 --no-audio -K -S
  ;;

Gaming-Balanced)
  echo Balanced Mode
  scrcpy -s "$TARGET" -m 1280 -b 4500k --max-fps 30 --no-audio -K -S
  ;;

Gaming-Low)
  echo Low Mode
  scrcpy -s "$TARGET" -m 1080 -b 3500k --max-fps 30 --no-audio -K -S
  ;;
esac
