#!/bin/bash
# Language management for TSM

TSM_ROOT="${TSM_ROOT:-$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")}"
LANG_DIR="$TSM_ROOT/lang"

# Detect system language
lang_detect() {
    local sys_lang="${LANG%%_*}"  # "tr_TR.UTF-8" → "tr"
    sys_lang="${sys_lang,,}"       # lowercase
    
    # Check if language file exists
    if [[ -f "$LANG_DIR/$sys_lang.sh" ]]; then
        echo "$sys_lang"
    else
        echo "en"  # fallback to English
    fi
}

# Load language file
lang_load() {
    local lang="$1"
    
    # Handle auto detection
    if [[ "$lang" == "auto" ]]; then
        lang=$(lang_detect)
    fi
    
    # Load language file
    local lang_file="$LANG_DIR/$lang.sh"
    if [[ -f "$lang_file" ]]; then
        source "$lang_file"
    else
        # Fallback to English
        source "$LANG_DIR/en.sh"
    fi
    
    # Store current language
    CURRENT_LANG="$lang"
}

# Get available languages
lang_list() {
    local langs=()
    for f in "$LANG_DIR"/*.sh; do
        [[ -f "$f" ]] && langs+=("$(basename "$f" .sh)")
    done
    echo "${langs[@]}"
}

# Get language display name
lang_get_name() {
    local lang="$1"
    case "$lang" in
        en) echo "English" ;;
        tr) echo "Türkçe" ;;
        *) echo "$lang" ;;
    esac
}
