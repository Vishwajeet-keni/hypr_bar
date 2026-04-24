#!/bin/bash

# timeout 10 = give up after 10 seconds, return 0 instead of crashing
pacman_u=$(timeout 10 pacman -Qu 2>/dev/null | wc -l) || pacman_u=0
yay_u=$(timeout 30 yay -Qu 2>/dev/null | wc -l)       || yay_u=0
count=$((pacman_u + yay_u))

echo "{\"count\":\"$count\",\"pacman_u\":\"$pacman_u\",\"yay_u\":\"$yay_u\"}"
