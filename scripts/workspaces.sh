#!/bin/bash

# Get current workspace from hyprctl (without jq)
current_workspace=$(hyprctl activeworkspace | grep "ID" | awk '{print $3}')

# Get all workspaces (without jq)
workspaces=$(hyprctl workspaces | grep "ID" | awk '{print $3}' | sort -n | tr '\n' ' ')

all_workspaces=$(echo "1 2 3 4 5 $workspaces" | tr ' ' '\n' | grep -v '^$' | sort -nu | tr '\n' ',' | sed 's/,$//')
echo "{\"current\": $current_workspace, \"workspaces\": [$all_workspaces]}"
