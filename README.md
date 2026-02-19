# Alarm Notify

Simple timer scripts that show a desktop notification when the time is up.

## Features

- Minute-based timer with optional message
- Terminal countdown (Linux)
- External terminal mode (`-e`) and silent background mode (`-n`) on Linux
- Desktop notification + optional sound alert
- Linux and macOS variants

## Prerequisites

### Linux

- `notify-send` (libnotify)
- `aplay` (alsa-utils)
- Optional terminal emulator for `-e`: gnome-terminal, alacritty, konsole, xfce4-terminal, xterm, ghostty. (add any terminal you want in the script ```launch_in_terminal``` function)

### macOS

## ‼️ not maintained (some features are not implemented here, like visible timer and setting custom notification message)
- `terminal-notifier`
- `afplay` (built-in)

## Usage

Linux script:

```bash
alarm-notify [OPTIONS] <minutes> [message]
```

Options:

- `-e` launch countdown in a new terminal window and exit
- `-n` run silently in the background
- `--help` print this README

Examples:

```bash
alarm-notify 10 #starts timer in the current terminal with no message
alarm-notify 25 "Stand up and stretch" #starts timer in the current terminal with custom message
alarm-notify -n 45 "Meeting starts" # starts timer in (nohup) on background terminal
alarm-notify -e 5 "Tea" #starts timer in external terminal and it will spawn up external terminal as well
```

macOS script:

```bash
alarm-notify-mac 15 5
```

The macOS variant uses `terminal-notifier` and plays the bundled sound after the sleep.

## Installation

### Arch Linux (AUR)

```bash
# From AUR (once published)
yay -S alarm-notify

# Or build locally
cd packaging/arch
makepkg -si
```

### Ubuntu / Debian

```bash
# Build .deb package
sudo apt install devscripts debhelper
cd packaging/debian
cp -r ../.. /tmp/alarm-notify-1.0.0
cd /tmp/alarm-notify-1.0.0
dpkg-buildpackage -us -uc -b
sudo dpkg -i ../alarm-notify_1.0.0-1_all.deb
```

Both install `alarm-notify` to `/usr/bin` and assets to `/usr/share/alarm-notify`.

## Structure

alarm-notify/
├── alarm-notify-linux
├── alarm-notify-mac
├── alarm-notify.wav
├── alarm-notify.png
├── README.md
└── LICENCE

## Limitations

- On macOS, custom notification icons require the `-sender` option in `terminal-notifier` with a valid bundle identifier.

## License

This project is licensed under the MIT License - see the [LICENCE](./LICENCE) file for details.
