# i3-dotfiles

My Arch Linux desktop: **i3**, **polybar**, **rofi**, **dunst** and **picom**, themed
with [yomi](https://github.com/AndrewFila/yomi). The terminal side (Neovim, tmux, zsh)
lives in my separate [dotfiles](https://github.com/AndrewFila/dotfiles) repo.

Managed with GNU Stow, the same as the other repo: every file here is symlinked into
place, so editing the live config edits the repo.

## Packages

| Package        | Installs to                              | What it is |
|----------------|------------------------------------------|------------|
| `i3`           | `~/.config/i3/`                          | i3 config, helper scripts, mouse-barrier helper (C) |
| `polybar`      | `~/.config/polybar/`                     | One bar per monitor, notification bell |
| `rofi`         | `~/.config/rofi/`                        | Launcher + yomi theme (used by every menu) |
| `dunst`        | `~/.config/dunst/`                       | Notifications |
| `picom`        | `~/.config/picom/`                       | Compositor: blur, shadows, rounded corners |
| `fontconfig`   | `~/.config/fontconfig/`                  | Inter for UI, FiraCode Nerd Font for monospace |
| `gtk`          | `~/.config/gtk-{3,4}.0/`                 | Font, dark mode, Papirus icons |
| `portal`       | `~/.config/xdg-desktop-portal/`          | GTK file picker for Firefox under i3 |
| `x11`          | `~/.xinitrc`, `~/.xprofile`, `~/.Xresources` | Session setup, yomi colors for st |
| `screenlayout` | `~/.screenlayout/`                       | arandr monitor layouts |

`system/` holds things outside `$HOME`: `setup.sh` (packages, services, ly, zram,
paru) and the zram config.

## Keys

`mod` is the Super key.

| Key | Does |
|-----|------|
| `mod+Return` | Terminal (st) |
| `mod+d` / `mod+Shift+d` / `mod+Tab` | Apps / run command / switch window (rofi) |
| `mod+f` | Firefox |
| `mod+g` | Steam games menu |
| `mod+o` | Audio output menu |
| `mod+l` | Monitor layout menu |
| `mod+Shift+v` | Clipboard history |
| `` mod+` `` / `mod+c` / `mod+m` | Scratchpads: terminal / Discord / Spotify |
| `mod+Shift+minus` / `mod+minus` | Send window to scratchpad / cycle scratchpads |
| `F12` / `Shift+F12` / `Ctrl+F12` | Screenshot: area / full screen / focused window |
| `mod+n` / `mod+Shift+n` / `mod+Ctrl+n` | Dismiss notification / history / do not disturb |
| `mod+Escape` | Lock screen (blurred wallpaper) |
| `mod+q` | Close window |
| `mod+Shift+f` | Fullscreen |
| `mod+Shift+g` / `mod+Ctrl+g` | Grow / shrink gaps |
| `mod+Shift+e` | Log out |

## Install

```sh
git clone <this repo> ~/i3-dotfiles
~/i3-dotfiles/system/setup.sh     # packages, services, ly, zram, paru (sudo)
~/i3-dotfiles/install.sh          # symlink configs, build the barrier helper
```

The wallpaper is set with `~/.config/i3/scripts/wallpaper <image>`; the chosen
image is a symlink at `~/.config/wallpaper` and isn't tracked.

## Not in this repo

- **st** is a separate clone of Luke Smith's build in `~/.config/st`, with
  `st-urlhandler` and `st-copyout` changed to use rofi instead of dmenu.
- **Disk/boot setup** (NVMe at `/data`, Windows in systemd-boot) was a one-off
  for this machine.
