# Tmux - Quick Reference

## Install

### One-liner
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shandiprill/scripts/main/tmux/setup-tmux.sh)"
```

### Local
```bash
bash setup-tmux.sh
```

## Quick Start
- Create session: `tmux new -s name`
- Attach: `tmux a -t name`
- List: `tmux ls`
- Detach: `Prefix + d` (Prefix = Ctrl+Space)

## Keybindings (Prefix = Ctrl+Space)
- New window: `Prefix + c`
- Split vertical: `Prefix + |`
- Split horizontal: `Prefix + -`
- Navigate panes: `Prefix + h/j/k/l` (vim keys)
- Resize: `Shift + Arrow keys`
- Next window: `Alt + Right`
- Previous window: `Alt + Left`
- Rename window: `Prefix + ,`
- Kill pane: `Prefix + x`
- Zoom pane: `Prefix + z`

## Common Workflows

### Development Setup
```bash
tmux new -s dev -n editor
tmux new-window -t dev -n server
# Prefix + 1 → vim file.js
# Prefix + 2 → npm start
```

### Remote Development
```bash
ssh user@server
tmux new -s coding
# Later: ssh user@server && tmux a -t coding
```

### Monitor Services
```bash
tmux new -s monitor
tmux new-window -t monitor -n logs
tmux send-keys -t monitor:logs "tail -f app.log" Enter
```

## Advanced
- Copy mode: `Prefix + [`
- Paste: `Prefix + ]`
- Capture pane: `tmux capture-pane -t session -p > output.txt`
- Sync panes: `Prefix + :` → `setw synchronize-panes on`

## Documentation
- Man page: `man tmux`
- List keys: `tmux list-keys`
- All commands: `tmux list-commands`

For full guide, visit: https://github.com/shandiprill/scripts/blob/main/tmux/TUTORIAL.md
