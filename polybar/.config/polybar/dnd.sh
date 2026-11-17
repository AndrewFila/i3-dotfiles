#!/bin/sh
# Polybar bell: shows whether dunst notifications are paused (do not disturb).
# With "toggle", flips the state first.
[ "${1:-}" = toggle ] && dunstctl set-paused toggle
if [ "$(dunstctl is-paused 2>/dev/null)" = true ]; then
    waiting=$(dunstctl count waiting 2>/dev/null)
    [ "${waiting:-0}" -gt 0 ] && echo "%{F#E1BA21}󰂛 $waiting%{F-}" || echo "%{F#8A909A}󰂛%{F-}"
else
    echo "%{F#2280CF}󰂚%{F-}"
fi
