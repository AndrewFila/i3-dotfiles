#!/bin/sh
# Arch's stock setup scripts (pass DISPLAY etc. to systemd/dbus user services)
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# Load X resources (yomi colors, st font)
[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"

# Session environment, shared with ly's i3 session
[ -f "$HOME/.xprofile" ] && . "$HOME/.xprofile"

exec i3
