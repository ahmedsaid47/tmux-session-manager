#!/bin/bash
# Utility functions for TSM

# Check if running inside tmux
is_in_tmux() {
    [[ -n "$TMUX" ]]
}

# Check if tmux is installed
check_tmux() {
    command -v tmux &>/dev/null
}

# Check terminal capabilities
check_terminal() {
    # Check for basic color support
    if [[ -t 1 ]] && [[ "${TERM:-dumb}" != "dumb" ]]; then
        HAS_COLORS=true
    else
        HAS_COLORS=false
    fi
    
    # Check for emoji support (heuristic)
    # Modern terminals usually support emoji
    case "$TERM" in
        xterm-256color|xterm-color|screen-256color|tmux-256color)
            HAS_EMOJI=true
            ;;
        *)
            # Check if running in known modern terminals
            if [[ -n "$WT_SESSION" ]] || [[ -n "$ITERM_SESSION_ID" ]] || [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
                HAS_EMOJI=true
            else
                HAS_EMOJI=false
            fi
            ;;
    esac
    
    # Check for Unicode support
    if [[ "${LANG:-}" == *UTF-8* ]] || [[ "${LC_ALL:-}" == *UTF-8* ]]; then
        HAS_UNICODE=true
    else
        HAS_UNICODE=false
    fi
}

# Check connection type
check_connection() {
    if [[ -n "$SSH_CONNECTION" ]] || [[ -n "$SSH_CLIENT" ]]; then
        CONNECTION_TYPE="ssh"
    elif [[ -n "$MOSH_KEY" ]] || pgrep -x mosh-server &>/dev/null; then
        CONNECTION_TYPE="mosh"
    else
        CONNECTION_TYPE="local"
    fi
}

# Get terminal width
get_term_width() {
    local width
    width=$(tput cols 2>/dev/null) || width=80
    echo "$width"
}

# Get terminal height
get_term_height() {
    local height
    height=$(tput lines 2>/dev/null) || height=24
    echo "$height"
}

# Clear screen and move cursor to top
clear_screen() {
    if [[ "$HAS_COLORS" == "true" ]]; then
        printf '\033[2J\033[H'
    else
        clear
    fi
}

# Move cursor up N lines
cursor_up() {
    local n="${1:-1}"
    printf '\033[%dA' "$n"
}

# Move cursor down N lines
cursor_down() {
    local n="${1:-1}"
    printf '\033[%dB' "$n"
}

# Clear from cursor to end of screen
clear_to_end() {
    printf '\033[J'
}

# Hide cursor
cursor_hide() {
    printf '\033[?25l'
}

# Show cursor
cursor_show() {
    printf '\033[?25h'
}

# Read single key (with escape sequence support)
read_key() {
    local key
    IFS= read -rsn1 key
    
    # Check for escape sequence
    if [[ "$key" == $'\x1b' ]]; then
        read -rsn2 -t 0.1 key2
        key+="$key2"
    fi
    
    echo "$key"
}

# Cleanup on exit
cleanup() {
    cursor_show
    stty echo 2>/dev/null
}

# Setup trap for cleanup
setup_cleanup() {
    trap cleanup EXIT INT TERM
}

# Print centered text
print_centered() {
    local text="$1"
    local width="${2:-$(get_term_width)}"
    local text_len=${#text}
    local padding=$(( (width - text_len) / 2 ))
    
    printf "%*s%s\n" "$padding" "" "$text"
}

# Print horizontal line
print_line() {
    local char="${1:--}"
    local width="${2:-$(get_term_width)}"
    printf '%*s\n' "$width" '' | tr ' ' "$char"
}

# Trim whitespace from string
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

# Check if string is empty or whitespace only
is_empty() {
    local var="$1"
    [[ -z "$(trim "$var")" ]]
}

# Validate session name
validate_session_name() {
    local name="$1"
    # Session names can't contain: . : 
    # and shouldn't start with -
    if [[ "$name" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_-]*$ ]]; then
        return 0
    else
        return 1
    fi
}
