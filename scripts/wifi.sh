#!/bin/bash
#Toggles wifi on/off based on current state of wifi connection
action="$1"
current=$(nmcli radio wifi)
if [ "$action" = "toggle" ]; then
  [ "$current" = "enabled" ] && action="off" || action="on"
fi
[ "$action" = "on" ]  && nmcli radio wifi on
[ "$action" = "off" ] && nmcli radio wifi off

ssid=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d':' -f2)
icon=$( [ -n "$ssid" ] && echo "" || echo "󰖪" )

echo "{\"icon\":\"$icon\", \"ssid\":\"$ssid\"}"      
