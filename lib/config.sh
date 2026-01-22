#!/bin/bash
# Config management for TSM

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-session-manager"
CONFIG_FILE="$CONFIG_DIR/config.conf"

# Default configuration
declare -A CONFIG_DEFAULTS=(
    [language]="auto"
    [theme]="default"
    [auto_attach]="false"
    [show_preview]="true"
    [default_session]="main"
    [history_limit]="50000"
    [mouse_support]="true"
)

# Current configuration
declare -A CONFIG

# Initialize config directory and file
config_init() {
    # Create config directory
    [[ ! -d "$CONFIG_DIR" ]] && mkdir -p "$CONFIG_DIR"
    
    # Create default config if not exists
    if [[ ! -f "$CONFIG_FILE" ]]; then
        config_create_default
    fi
    
    # Load configuration
    config_load
}

# Create default configuration file
config_create_default() {
    cat > "$CONFIG_FILE" << 'EOF'
# Tmux Session Manager Configuration
# https://github.com/ahmedsaid47/tmux-session-manager

# Language: auto, en, tr
language=auto

# Theme: default, minimal
theme=default

# Auto-attach to last session on start
auto_attach=false

# Show session preview (window list)
show_preview=true

# Default session name for new sessions
default_session=main

# Tmux history limit
history_limit=50000

# Enable mouse support
mouse_support=true
EOF
}

# Load configuration from file
config_load() {
    # Start with defaults
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
            
            # Store value
            [[ -n "$key" ]] && CONFIG[$key]="$value"
        done < "$CONFIG_FILE"
    fi
}

# Save configuration to file
config_save() {
    cat > "$CONFIG_FILE" << EOF
# Tmux Session Manager Configuration
# https://github.com/ahmedsaid47/tmux-session-manager

# Language: auto, en, tr
language=${CONFIG[language]}

# Theme: default, minimal
theme=${CONFIG[theme]}

# Auto-attach to last session on start
auto_attach=${CONFIG[auto_attach]}

# Show session preview (window list)
show_preview=${CONFIG[show_preview]}

# Default session name for new sessions
default_session=${CONFIG[default_session]}

# Tmux history limit
history_limit=${CONFIG[history_limit]}

# Enable mouse support
mouse_support=${CONFIG[mouse_support]}
EOF
}

# Get config value
config_get() {
    local key="$1"
    echo "${CONFIG[$key]:-${CONFIG_DEFAULTS[$key]}}"
}

# Set config value
config_set() {
    local key="$1"
    local value="$2"
    CONFIG[$key]="$value"
}

# Get config directory path
config_get_dir() {
    echo "$CONFIG_DIR"
}
