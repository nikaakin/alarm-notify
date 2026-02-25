# Project Context for AI Assistants

## Project Overview

**alarm-notify** - A bash-based timer CLI that sends desktop notifications when time is up.

- **Primary file**: `alarm-notify-linux` (bash script)
- **Package manager**: Arch Linux (AUR), also supports Debian
- **Target users**: Linux users (primarily Arch/Hyprland)
- **Repo**: https://github.com/nikaakin/alarm-notify

## Architecture Decisions

### --load Feature (Batch Task Loading)

**Problem solved**: Load multiple timers from a file as suspended shell jobs for daily workflow planning.

**Implementation approach**: ZDOTDIR injection
- Scripts can't create jobs in parent shell (fundamental Unix limitation)
- Solution: Spawn a new zsh with custom `.zshrc` that creates jobs during init
- User's real `.zshrc` is sourced first, then jobs are created
- `ZDOTDIR` is unset after init so child shells work normally

**Why not alternatives?**
- `eval "$(command)"` - Freezes terminal when stopped processes hold pipe open
- `exec $SHELL -c "..."` - Jobs don't transfer across `exec $SHELL -i`
- Shell function in `.zshrc` - Would work but requires user setup

### Self-Stopping Pattern

```bash
# Instead of parent trying to stop child (unreliable):
script &
kill -STOP $!  # Often fails in shell init context

# Child stops itself (reliable):
if [ "$START_PAUSED" -eq 1 ]; then
    kill -STOP $$  # $$ = current PID
fi
```

## Security Checklist

Every time user input is embedded in shell commands, check:

1. **Single-quote escaping** - `escape_single_quotes()` function
   - Replace `'` with `'\''`
   - Wrap in single quotes: `'$escaped_input'`

2. **Temp file permissions**
   - `chmod 700` on directories
   - `chmod 600` on files
   - Check `mktemp` return value

3. **Don't trust environment**
   - Don't use `$SHELL` for command execution (could be malicious)
   - Hardcode known shells: `exec bash`, `exec zsh`

4. **Argument injection**
   - Use `--` before user-provided arguments: `notify-send -- "$message"`
   - Prevents messages starting with `-` being interpreted as flags

5. **Resource limits**
   - `MAX_TIMER=10080` prevents integer overflow/DoS

## Code Patterns

### Option Parsing (Long + Short)

```bash
# Handle long options before getopts
for arg in "$@"; do
    case $arg in
        --load) LOAD_TASKS=1 ;;
        --load=*) LOAD_PATH="${arg#*=}" ;;
    esac
done

# Remove long options for getopts
ARGS=()
for arg in "$@"; do
    case $arg in
        --load|--load=*) ;;  # skip
        *) ARGS+=("$arg") ;;
    esac
done
set -- "${ARGS[@]}"

# Now use getopts for short options
while getopts "en" opt; do ...
```

### Zsh Job Control

```bash
# Suppress [1] PID output during job creation
unsetopt notify
command &
command &
setopt notify  # Re-enable for normal use
```

### Process States (ps aux STAT column)

- `T` = Stopped (what we want)
- `S` = Sleeping (still running, will complete!)
- `TN` = Stopped + Nice priority (correct)
- `SN` = Sleeping + Nice (BUG - not actually stopped)

## Testing Commands

```bash
# Syntax check
bash -n alarm-notify-linux

# Test command injection safety
./alarm-notify-linux 1 "'; echo PWNED; '"

# Check process states after --load
ps aux | grep alarm-notify
# Should see TN, not SN

# Kill all alarm-notify processes
pkill -9 -f "alarm-notify"
```

## Release Workflow

```bash
# Use the release script
./scripts/release.sh 1.2.0 "Feature description"

# Manual steps for AUR
cd ~/Desktop/work/aur-packages/alarm-notify
cp ~/Desktop/work/alarm-notify/packaging/arch/PKGBUILD .
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO
git commit -m "Update to v1.2.0"
git push
```

## User Preferences

- **Don't implement without confirmation** on design decisions
- **Ask questions first** to understand requirements
- **Explain trade-offs** between approaches
- Prefers learning explanations alongside fixes
- Uses zsh with oh-my-zsh on Arch/Hyprland
- Has `tpm` tool that spawns `$SHELL` (affected ZDOTDIR bug)

## Common Gotchas

1. **Subshell can't modify parent** - No way around this, must spawn new shell or use eval
2. **`kill -STOP $!` unreliable during shell init** - Use self-stopping pattern instead
3. **ZDOTDIR persists to child shells** - Must `unset ZDOTDIR` after init
4. **`set -m` required for bash job control** - Not enabled by default in non-interactive init
5. **zsh `jobs` truncates display** - Full command is there, just not shown

## Files Structure

```
alarm-notify/
├── alarm-notify-linux     # Main script
├── alarm-notify-mac       # macOS variant (unmaintained)
├── alarm-notify.wav       # Notification sound
├── alarm-notify.png       # Notification icon
├── README.md              # User documentation
├── LICENCE                # MIT
├── SKILL.md               # This file (AI context)
├── LOAD_TASKS_EXPLAINED.md # Technical deep-dive for learning
├── scripts/
│   └── release.sh         # Release automation
└── packaging/
    ├── arch/
    │   └── PKGBUILD
    └── debian/
        └── ...
```
