#!/bin/bash
# Configuration management for TSM

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-session-manager"
CONFIG_FILE="$CONFIG_DIR/config.conf"

declare -A CONFIG_DEFAULTS=(
    ['language']='auto'
    ['theme']='default'
    ['auto_attach']='false'
    ['show_preview']='true'
    ['default_session']='main'
    ['history_limit']='50000'
    ['mouse_support']='true'
    ['last_session']=''
)

declare -A CONFIG

# Initialize config
config_init() {
    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
    fi
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        config_create_default
    fi
    
    config_load
}

# Create default config file
config_create_default() {
    cat > "$CONFIG_FILE" << 'EOF'
# TSM - Tmux Session Manager Configuration
# https://github.com/ahmedsaid47/tmux-session-manager

# Language: auto, en, tr
language=auto

# Theme: default, minimal
theme=default

# Auto-attach to last session on start
auto_attach=false

# Show session preview
show_preview=true

# Default session name for new sessions
default_session=main

# Tmux history limit
history_limit=50000

# Mouse support
mouse_support=true

# Last used session (auto-updated)
last_session=
EOF
}

# Load config from file
config_load() {
    # Set defaults first
    for key in "${!CONFIG_DEFAULTS[@]}"; do
        CONFIG[$key]="${CONFIG_DEFAULTS[$key]}"
    done
    
    # Read config file
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$key" ]] && continue
            
            # Trim whitespace
            key="${key##*( )}"
            key="${key%%*( )}"
            value="${value##*( )}"
            value="${value%%*( )}"
            
            if [[ -n "$key" ]]; then
                CONFIG[$key]="$value"
            fi
        done < "$CONFIG_FILE"
    fi
}

# Get config value
config_get() {
    local key="$1"
    echo "${CONFIG[$key]:-${CONFIG_DEFAULTS[$key]:-}}"
}

# Set config value
config_set() {
    local key="$1"
    local value="$2"
    CONFIG[$key]="$value"
}

# Save config to file
config_save() {
    cat > "$CONFIG_FILE" << EOF
# TSM - Tmux Session Manager Configuration
# https://github.com/ahmedsaid47/tmux-session-manager

# Language: auto, en, tr
language=${CONFIG['language']:-auto}

# Theme: default, minimal
theme=${CONFIG['theme']:-default}

# Auto-attach to last session on start
auto_attach=${CONFIG['auto_attach']:-false}

# Show session preview
show_preview=${CONFIG['show_preview']:-true}

# Default session name for new sessions
default_session=${CONFIG['default_session']:-main}

# Tmux history limit
history_limit=${CONFIG['history_limit']:-50000}

# Mouse support
mouse_support=${CONFIG['mouse_support']:-true}

# Last used session (auto-updated)
last_session=${CONFIG['last_session']:-}
EOF
}

# Save last session
save_last_session() {
    local session="$1"
    config_set last_session "$session"
    config_save
}

# Get last session
get_last_session() {
    config_get last_session
}
