#!/bin/bash
# Reports and sets screen brightness as a 0-100 percentage via brightnessctl.
# Usage: brightness.sh          -> report current value
#        brightness.sh set 70   -> set to 70%, then report
action="$1"
value="$2"

if [ "$action" = "set" ] && [ -n "$value" ]; then
  brightnessctl set "${value}%" >/dev/null
fi

current=$(brightnessctl get)
max=$(brightnessctl max)
pct=$(( current * 100 / max ))

echo "{\"value\": $pct}"
