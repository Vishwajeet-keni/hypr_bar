#!/bin/bash
# Toggles bluetooth on/off via bluetoothctl. Same contract as wifi.sh:
# one JSON line, script computes state + a ready-to-display status string.
action="$1"
current=$(bluetoothctl show | awk '/Powered/{print $2}')
if [ "$action" = "toggle" ]; then
  [ "$current" = "yes" ] && action="off" || action="on"
fi
[ "$action" = "on" ]  && bluetoothctl power on  >/dev/null
[ "$action" = "off" ] && bluetoothctl power off >/dev/null

state_raw=$(bluetoothctl show | awk '/Powered/{print $2}')
state=$( [ "$state_raw" = "yes" ] && echo "on" || echo "off" )
device=$(bluetoothctl info 2>/dev/null | awk -F': ' '/Name/{print $2; exit}')
icon=$( [ "$state" = "on" ] && echo "󰂯" || echo "󰂲" )

if [ "$state" = "off" ]; then
  status="Off"
elif [ -n "$device" ]; then
  status="$device"
else
  status="On"
fi

echo "{\"icon\":\"$icon\", \"state\":\"$state\", \"device\":\"$device\", \"status\":\"$status\"}"
