#!/usr/bin/env bash
cache=/tmp/hypr_bar_updates.json
max_age=600  # seconds (10 minutes)

if [ -f "$cache" ] && [ $(( $(date +%s) - $(stat -c %Y "$cache") )) -lt $max_age ]; then
  cat "$cache"
  exit 0
fi

# Run checks with timeouts
pacman_u=$(timeout 10 pacman -Qu 2>/dev/null | wc -l) || pacman_u=0
yay_u=$(timeout 30 yay -Qu 2>/dev/null | wc -l)       || yay_u=0
count=$((pacman_u + yay_u))
json=$(printf '{"count":"%s","pacman_u":"%s","yay_u":"%s"}\n' "$count" "$pacman_u" "$yay_u")
printf '%s' "$json" > "$cache"
printf '%s' "$json"