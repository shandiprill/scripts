#!/bin/bash
set -e
echo "[*] Installing tmux..."
apt-get update && apt-get install -y tmux
echo "[*] Creating tmux configuration..."
mkdir -p /root/.config/tmux
cat > /root/.config/tmux/tmux.conf << 'EOF'
unbind C-b
set -g prefix C-Space
bind C-Space send-prefix
set -g mouse on
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:RGB"
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g history-limit 10000
set -g status-bg colour235
set -g status-fg white
set -g status-left "#[fg=colour33]#S #[default]| "
set -g status-right "#[fg=colour33]%H:%M #[default]| #[fg=colour33]%d-%b-%y"
set -g pane-border-style fg=colour240
set -g pane-active-border-style "bg=default fg=colour33"
bind -n M-Left select-window -t :-
bind -n M-Right select-window -t :+
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
bind -n S-Up resize-pane -U 5
bind -n S-Down resize-pane -D 5
bind -n S-Left resize-pane -L 5
bind -n S-Right resize-pane -R 5
bind | split-window -h
bind - split-window -v
bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"
EOF
echo "[*] Tmux installed successfully!"
