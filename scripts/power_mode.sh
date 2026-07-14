#!/bin/bash
# Cycles/sets the TLP power profile via tlpctl (tlp-pd's D-Bus client) —
# no root needed, unlike calling `tlp` directly: tlpctl authenticates
# through your active session, and `tlpctl get` reads the live profile
# straight from tlp-pd, so there's no local state file to keep in sync.
#
# Requires: tlp-pd package installed, tlp-pd.service enabled+running.
# Same calling convention as wifi.sh: no arg = report current state,
# "toggle" = advance to the next state, or pass a profile name directly.
#
# eww/GTK can fire a single click's onclick handler more than once
# (confirmed via debug log — multiple PIDs spawned in the same
# millisecond for one click). On a 3-state cycle, an even multiple of
# extra fires can silently cancel out and look like the toggle is
# "stuck". The flock below makes only ONE toggle actually execute per
# burst — any duplicate invocations that arrive while one is already
# running just skip their mutation and fall through to reporting
# whatever state exists once the lock frees up.
action="$1"
lock_file="/tmp/power_mode.lock"

debug_log="/tmp/power_mode_debug.log"
echo "$(date '+%H:%M:%S.%3N') pid=$$ action='$action'" >> "$debug_log"

current=$(timeout 3 tlpctl get 2>/dev/null)
echo "  pid=$$ read current='$current'" >> "$debug_log"
# Fallback if tlp-pd isn't running/reachable — surfaces the problem
# in the UI instead of the widget silently showing stale data.
if [ -z "$current" ]; then
  echo '{"icon":"", "mode":"unavailable"}'
  exit 1
fi

if [ "$action" = "toggle" ]; then
  (
    flock -n 200 || { echo "  pid=$$ LOCK BUSY, skipping" >> "$debug_log"; exit 0; }
    echo "  pid=$$ got lock, current='$current'" >> "$debug_log"

    case "$current" in
      performance)  next="balanced" ;;
      balanced)     next="power-saver" ;;
      power-saver)  next="performance" ;;
      *)            exit 0 ;;
    esac
    echo "  pid=$$ applying $next" >> "$debug_log"
    timeout 3 tlpctl "$next" >/dev/null 2>&1
  ) 200>"$lock_file"

  current=$(timeout 3 tlpctl get 2>/dev/null)
  echo "  pid=$$ final current='$current'" >> "$debug_log"
elif [ "$action" = "performance" ] || [ "$action" = "balanced" ] || [ "$action" = "power-saver" ]; then
  (
    flock -n 200 || exit 0
    timeout 3 tlpctl "$action" >/dev/null 2>&1
  ) 200>"$lock_file"
  current=$(timeout 3 tlpctl get 2>/dev/null)
fi

case "$current" in
  performance)  icon="" ;; # swap for whatever glyph fits your icon set
  balanced)     icon="" ;;
  power-saver)  icon="" ;;
esac

echo "{\"icon\":\"$icon\", \"mode\":\"$current\"}"