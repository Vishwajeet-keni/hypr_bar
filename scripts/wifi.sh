#!/bin/bash
# Toggles wifi on/off and reports state for both the bar widget and the
# control center tile. Single source of truth — do not add a second poller.
action="$1"
current=$(nmcli radio wifi)
if [ "$action" = "toggle" ]; then
  [ "$current" = "enabled" ] && action="off" || action="on"
fi
[ "$action" = "on" ]  && nmcli radio wifi on
[ "$action" = "off" ] && nmcli radio wifi off

state_raw=$(nmcli radio wifi)
state=$( [ "$state_raw" = "enabled" ] && echo "on" || echo "off" )
ssid=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d':' -f2)
icon=$( [ -n "$ssid" ] && echo "" || echo "󰖪"  )

# status is the ready-to-display subtitle text — script decides it,
# Yuck just prints it, same pattern as system_stats.sh's state classes.
if [ "$state" = "off" ]; then
  status="Off"
elif [ -n "$ssid" ]; then
  status="$ssid"
else
  status="On"
fi

echo "{\"icon\":\"$icon\", \"ssid\":\"$ssid\", \"state\":\"$state\", \"status\":\"$status\"}"