#!/bin/bash

emit() {
    level=$(cat /sys/class/power_supply/BAT0/capacity)
    status=$(cat /sys/class/power_supply/BAT0/status)

    # Set icon
    if [ "$status" = "Charging" ]; then
        icon=""
    else
        case $level in
            9[0-9]|100) icon="" ;;
    [6-8][0-9]) icon="" ;;
    [4-5][0-9]) icon="" ;;
    [1-3][0-9]) icon="" ;;
    *) icon="" ;;
        esac
    fi

    # status
    class="$status"
    low_batt=30

    [ "$level" -le $low_batt ] && class="critical"

    # Low battery warning logic
    shown_file="/tmp/eww_batt_warning_shown"

    if [ "$level" -le $low_batt ] && [ "$status" = "Discharging" ] && [ ! -f "$shown_file" ]; then
        eww open low_batt_warning 2>/dev/null
        touch "$shown_file"
    fi

    # Reset shown if charging OR battery recovered above 30
    if [ "$status" = "Charging" ] || [ "$level" -gt $low_batt ]; then
        rm -f "$shown_file"
    fi

    echo "{\"icon\":\"$icon\", \"level\":\"$level\", \"class\":\"$class\"}"
}

# Emit once immediately so the widget has data before the first event arrives
emit

# Then only re-emit when upower reports an actual change
upower --monitor | while read -r line; do
    case "$line" in
        *"device changed"*|*"state changed"*|*"percentage"*)
            emit
            ;;
    esac
done