#!/bin/bash

# Emits current workspace state as JSON, once immediately, then again only when
# Hyprland actually reports a workspace-related change on socket2 (event-driven,
# no polling).

emit() {
    current_workspace=$(hyprctl activeworkspace | grep "ID" | awk '{print $3}')
    workspaces=$(hyprctl workspaces | grep "ID" | awk '{print $3}' | sort -n | tr '\n' ' ')
    all_workspaces=$(echo "1 2 3 4 5 $workspaces" | tr ' ' '\n' | grep -v '^$' | sort -nu | tr '\n' ',' | sed 's/,$//')
    echo "{\"current\": $current_workspace, \"workspaces\": [$all_workspaces]}"
}

# Emit once immediately so the widget has data before the first event arrives
emit

# Then only re-emit when something workspace-related actually happens
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | \
while read -r line; do
    case "$line" in
        workspace\>\>*|createworkspace\>\>*|destroyworkspace\>\>*|moveworkspace\>\>*)
            emit
            ;;
    esac
done