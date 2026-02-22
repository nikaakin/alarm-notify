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
- `--load [FILE]` load tasks from file as suspended jobs (default: `~/.config/alarm-notify/tasks`)
- `--help` print this README

Examples:

```bash
alarm-notify 10 #starts timer in the current terminal with no message
alarm-notify 25 "Stand up and stretch" #starts timer in the current terminal with custom message
alarm-notify -n 45 "Meeting starts" # starts timer in (nohup) on background terminal
alarm-notify -e 5 "Tea" #starts timer in external terminal and it will spawn up external terminal as well
```

## Batch Tasks (Daily Workflow)

Load multiple timers from a file as suspended shell jobs. Perfect for planning your day.

### Task File Format

Create `~/.config/alarm-notify/tasks` (or any file):

```
# Comments start with #
30 dsa training
60 documentation review
45 code review
15 break
```

Format: `<minutes> <message>` — one task per line.

### Usage

```bash
# Load from default path (~/.config/alarm-notify/tasks)
alarm-notify --load

# Load from custom path
alarm-notify --load ~/my-tasks.txt
alarm-notify --load=/path/to/tasks
```

**Note**: This command spawns a new interactive shell with your tasks loaded as suspended jobs. Your shell configuration (`.zshrc`/`.bashrc`) is preserved.

### Workflow

```
$ alarm-notify --load
Loading 3 tasks from /home/user/.config/alarm-notify/tasks...

  [1] 30 min - dsa training
  [2] 60 min - documentation review  
  [3] 45 min - code review

Tasks loaded. Use: jobs (list), fg (start next), Ctrl+Z (pause)
```

Control your tasks:

| Command | Action |
|---------|--------|
| `jobs` | List all suspended timers |
| `fg` | Start next task (first in file) |
| `fg %2` | Start specific job by number |
| `Ctrl+Z` | Pause current timer |
| `kill %1` | Cancel a specific job |

This lets you edit your task file the night before and load it in your startup terminal each morning.

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
