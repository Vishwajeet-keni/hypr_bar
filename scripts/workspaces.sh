#!/usr/bin/env bash
set -euo pipefail

emit_now() {
  current_workspace=$(hyprctl activeworkspace | awk '/ID/ {print $3}')
  workspaces=$(hyprctl workspaces | awk '/ID/ {print $3}' | sort -n | tr '\n' ' ')
  all_workspaces=$(echo "1 2 3 4 5 $workspaces" | tr ' ' '\n' | grep -v '^$' | sort -nu | tr '\n' ',' | sed 's/,$//')
  echo "{\"current\": $current_workspace, \"workspaces\": [$all_workspaces]}"
}

emit_now

debounce_pid=""
cleanup() {
  if [ -n "${debounce_pid:-}" ] && kill -0 "$debounce_pid" 2>/dev/null; then
    kill "$debounce_pid" 2>/dev/null || true
  fi
}
trap 'cleanup; exit 0' EXIT INT TERM

schedule_emit_last_event() {
  # cancel previous timer if running
  if [ -n "$debounce_pid" ] && kill -0 "$debounce_pid" 2>/dev/null; then
    kill "$debounce_pid" 2>/dev/null || true
  fi

  ( sleep 0.100; emit_now ) &
  debounce_pid=$!
}

socket_path="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
if [ ! -e "$socket_path" ]; then
  echo "/* hypr socket not found: $socket_path — falling back to polling */" >&2
  while true; do
    emit_now
    sleep 2
  done
fi

# Correct socket connection: socat -u UNIX-CONNECT:SOCKET -
socat -u "UNIX-CONNECT:$socket_path" - | while read -r line; do
  case "$line" in
    workspace\>\>*|createworkspace\>\>*|destroyworkspace\>\>*|moveworkspace\>\>*)
      schedule_emit_last_event
      ;;
  esac
done