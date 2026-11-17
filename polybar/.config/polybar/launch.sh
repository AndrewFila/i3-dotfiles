#!/usr/bin/env bash
# Start one polybar per connected monitor; tray goes on the primary one.
polybar-msg cmd quit >/dev/null 2>&1
killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.2; done

primary=$(polybar --list-monitors | awk -F: '/primary/{print $1; exit}')
for m in $(polybar --list-monitors | cut -d: -f1); do
    bar=main; [ "$m" = "$primary" ] && bar=primary
    MONITOR=$m polybar --reload "$bar" >/tmp/polybar-"$m".log 2>&1 &
    disown
done
