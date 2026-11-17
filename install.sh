#!/usr/bin/env bash
# Symlink these configs into $HOME with GNU Stow, and build the mouse-barrier helper.
# usage: ./install.sh [package...]     (defaults to all packages)
# System setup (packages, services, ly, zram) is separate: system/setup.sh
set -euo pipefail
cd "$(dirname "$0")"

command -v stow >/dev/null || { echo "stow not found: sudo pacman -S stow" >&2; exit 1; }
mkdir -p "$HOME/.config"

packages=("$@")
[ ${#packages[@]} -eq 0 ] && packages=(i3 polybar rofi dunst picom fontconfig gtk portal x11 screenlayout)

stow --restow --target="$HOME" "${packages[@]}"
echo "Stowed: ${packages[*]}"

# mouse barriers (C helper used by i3/scripts/walls)
b=i3/.config/i3/barriers
if [ -f "$b/barriers.c" ]; then
    cc -O2 -Wall -o "$b/barriers" "$b/barriers.c" -lX11 -lXfixes -lXrandr && echo "Built $b/barriers"
fi
