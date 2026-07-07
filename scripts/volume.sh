#!/bin/bash
# Reports and sets output volume as a 0-100 percentage via wpctl.
# Usage: volume.sh          -> report current value
#        volume.sh set 50   -> set to 50%, then report
# If you're on PulseAudio/pactl instead of PipeWire, swap the two
# wpctl lines below for their pactl equivalents.
action="$1"
value="$2"

if [ "$action" = "set" ] && [ -n "$value" ]; then
  wpctl set-volume @DEFAULT_AUDIO_SINK@ "${value}%"
fi

raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
vol=$(echo "$raw" | awk '{print $2}')
pct=$(awk -v v="$vol" 'BEGIN{printf "%d", v*100}')
muted=$(echo "$raw" | grep -q "MUTED" && echo "true" || echo "false")

echo "{\"value\": $pct, \"muted\": $muted}"
