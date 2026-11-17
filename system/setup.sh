#!/usr/bin/env bash
# System-level setup for this desktop (needs sudo). Safe to run more than once.
#   - installs packages.txt
#   - zram swap, SSD trim, pacman cache cleanup, cron (for timeshift)
#   - ly display manager on tty1 with the yomi Game of Life theme
#   - paru (AUR helper)
#   - clipboard history service (clipmenud)
# Run it from a normal terminal (it asks for your sudo password).
set -euo pipefail
cd "$(dirname "$0")/.."

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

step "Packages"
mapfile -t pkgs < <(grep -v '^#' packages.txt | tr ' ' '\n' | grep -v '^$')
sudo pacman -S --needed "${pkgs[@]}"

step "zram swap"
sudo install -m 644 system/zram-generator.conf /etc/systemd/zram-generator.conf
sudo systemctl daemon-reload
sudo systemctl restart systemd-zram-setup@zram0.service
swapon --show

step "Timers and services"
sudo systemctl enable --now fstrim.timer    # weekly SSD trim
sudo systemctl enable --now paccache.timer  # keep last 3 versions in pacman cache
sudo systemctl enable --now cronie.service  # timeshift's scheduled snapshots
systemctl --user enable --now clipmenud.service  # clipboard history

step "ly (login screen)"
CONF=/etc/ly/config.ini
[ -f "$CONF.bak" ] || sudo cp "$CONF" "$CONF.bak"
sudo sed -i \
    -e 's/^animation = .*/animation = gameoflife/' \
    -e 's/^gameoflife_fg = .*/gameoflife_fg = 0x00004C89/' \
    -e 's/^gameoflife_frame_delay = .*/gameoflife_frame_delay = 8/' \
    -e 's/^gameoflife_initial_density = .*/gameoflife_initial_density = 0.35/' \
    -e 's/^gameoflife_entropy_interval = .*/gameoflife_entropy_interval = 10/' \
    -e 's/^bg = .*/bg = 0x000F0F14/' \
    -e 's/^fg = .*/fg = 0x00D8D8E0/' \
    -e 's/^border_fg = .*/border_fg = 0x002280CF/' \
    -e 's/^error_fg = .*/error_fg = 0x01F11A39/' \
    -e 's/^bigclock = .*/bigclock = en/' \
    "$CONF"
sudo systemctl disable getty@tty1.service 2>/dev/null || true
sudo systemctl enable ly@tty1.service

step "paru (AUR helper)"
if command -v paru >/dev/null; then
    echo "paru already installed"
else
    tmp=$(mktemp -d)
    git clone --depth=1 https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
    (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi

step "Done"
echo "Next: open Timeshift (rofi -> Timeshift), choose RSYNC, pick the /data drive, and set a schedule."
