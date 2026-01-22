#!/bin/bash
# Core functions for TSM - Session management

# Get list of sessions
sessions_list() {
    tmux list-sessions -F "#{session_name}|#{session_windows}|#{?session_attached,1,0}|#{session_created}" 2>/dev/null
}

# Get session count
sessions_count() {
    tmux list-sessions 2>/dev/null | wc -l
}

# Check if session exists
session_exists() {
    local name="$1"
    tmux has-session -t "$name" 2>/dev/null
}

# Create new session
session_create() {
    local name="$1"
    local attach="${2:-true}"
    
    if session_exists "$name"; then
        return 1
    fi
    
    if [[ "$attach" == "true" ]]; then
        tmux new-session -s "$name"
    else
        tmux new-session -d -s "$name"
    fi
}

# Delete session
session_delete() {
    local name="$1"
    tmux kill-session -t "$name" 2>/dev/null
}

# Rename session
session_rename() {
    local old_name="$1"
    local new_name="$2"
    
    if session_exists "$new_name"; then
        return 1
    fi
    
    tmux rename-session -t "$old_name" "$new_name" 2>/dev/null
}

# Attach to session
session_attach() {
    local name="$1"
    
    if is_in_tmux; then
        tmux switch-client -t "$name"
    else
        tmux attach-session -t "$name"
    fi
}

# Get session info
session_info() {
    local name="$1"
    tmux list-sessions -F "#{session_name}|#{session_windows}|#{?session_attached,1,0}|#{session_created}" -f "#{==:#{session_name},$name}" 2>/dev/null
}

# Get windows in session
session_windows() {
    local name="$1"
    tmux list-windows -t "$name" -F "#{window_index}|#{window_name}|#{?window_active,1,0}|#{window_panes}" 2>/dev/null
}

# Get last attached session
session_last() {
    tmux list-sessions -F "#{session_name}|#{session_last_attached}" 2>/dev/null | \
        sort -t'|' -k2 -rn | head -1 | cut -d'|' -f1
}

# Clone session (create new with same structure)
session_clone() {
    local source="$1"
    local target="$2"
    
    if ! session_exists "$source"; then
        return 1
    fi
    
    if session_exists "$target"; then
        return 2
    fi
    
    # Get working directory of source
    local dir
    dir=$(tmux display-message -t "$source" -p '#{pane_current_path}')
    
    # Create new session in same directory
    tmux new-session -d -s "$target" -c "$dir"
}

# Window management
window_create() {
    local session="$1"
    local name="${2:-}"
    
    if [[ -n "$name" ]]; then
        tmux new-window -t "$session" -n "$name"
    else
        tmux new-window -t "$session"
    fi
}

window_delete() {
    local session="$1"
    local index="$2"
    tmux kill-window -t "$session:$index"
}

window_rename() {
    local session="$1"
    local index="$2"
    local name="$3"
    tmux rename-window -t "$session:$index" "$name"
}
