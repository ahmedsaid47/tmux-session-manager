#!/bin/bash
# Menu system for TSM - v2.2.1 Fixed

declare -a MENU_ITEMS
declare -a MENU_ACTIONS
MENU_SELECTED=0
MENU_TITLE=""
MENU_FILTER=""
MENU_RESULT=255
INPUT_RESULT=""

# Terminal reset
reset_terminal() {
    stty sane 2>/dev/null
    stty echo 2>/dev/null
    printf '\033[?25h'  # cursor show
}

# Draw box
draw_box() {
    local title="$1"
    local width="${MENU_WIDTH:-44}"
    
    echo -e "${C_PRIMARY}${BOX_TL}$(printf '%*s' $((width-2)) '' | tr ' ' "$BOX_H")${BOX_TR}${C_RESET}"
    
    local title_len=${#title}
    local padding=$(( (width - 2 - title_len) / 2 ))
    echo -e "${C_PRIMARY}${BOX_V}${C_RESET}$(printf '%*s' $padding '')${C_BOLD}$title${C_RESET}$(printf '%*s' $((width - 2 - padding - title_len)) '')${C_PRIMARY}${BOX_V}${C_RESET}"
    
    echo -e "${C_PRIMARY}${BOX_BL}$(printf '%*s' $((width-2)) '' | tr ' ' "$BOX_H")${BOX_BR}${C_RESET}"
}

# Draw menu items
draw_menu() {
    local start_index="${1:-0}"
    local max_items="${2:-10}"
    local total=${#MENU_ITEMS[@]}
    
    local end_index=$((start_index + max_items))
    [[ $end_index -gt $total ]] && end_index=$total
    
    local i
    for ((i=start_index; i<end_index; i++)); do
        local item="${MENU_ITEMS[$i]}"
        if [[ $i -eq $MENU_SELECTED ]]; then
            echo -e "${MENU_PADDING}${C_HIGHLIGHT}${ICON_SELECTED} ${C_BOLD}${item}${C_RESET}"
        else
            echo -e "${MENU_PADDING}  ${item}"
        fi
    done
    
    [[ $start_index -gt 0 ]] && echo -e "${MENU_PADDING}${C_MUTED}  ↑ daha fazla${C_RESET}"
    [[ $end_index -lt $total ]] && echo -e "${MENU_PADDING}${C_MUTED}  ↓ daha fazla${C_RESET}"
}

# Help line
draw_help_line() {
    echo ""
    echo -e "${C_MUTED}↑↓ Gezin | Enter Seç | q Çık${C_RESET}"
}

# Safe navigation
menu_up() {
    [[ $MENU_SELECTED -gt 0 ]] && MENU_SELECTED=$((MENU_SELECTED - 1))
}

menu_down() {
    local total=${#MENU_ITEMS[@]}
    [[ $MENU_SELECTED -lt $((total - 1)) ]] && MENU_SELECTED=$((MENU_SELECTED + 1))
}

# Menu loop
menu_loop() {
    local total=${#MENU_ITEMS[@]}
    local max_visible=10
    local scroll_offset=0
    
    local KEY_UP=$'\e[A'
    local KEY_DOWN=$'\e[B'
    local KEY_ESC=$'\e'
    
    cursor_hide
    
    while true; do
        clear_screen
        draw_box "$MENU_TITLE"
        echo ""
        
        if [[ $MENU_SELECTED -lt $scroll_offset ]]; then
            scroll_offset=$MENU_SELECTED
        elif [[ $MENU_SELECTED -ge $((scroll_offset + max_visible)) ]]; then
            scroll_offset=$((MENU_SELECTED - max_visible + 1))
        fi
        
        draw_menu $scroll_offset $max_visible
        draw_help_line
        
        local key
        key=$(read_key)
        
        case "$key" in
            "$KEY_UP"|k) menu_up ;;
            "$KEY_DOWN"|j) menu_down ;;
            ""|$'\n')
                cursor_show
                MENU_RESULT=$MENU_SELECTED
                return 0
                ;;
            q|"$KEY_ESC")
                cursor_show
                MENU_RESULT=255
                return 0
                ;;
            n)
                cursor_show
                MENU_RESULT=254
                return 0
                ;;
            [1-9])
                local num=$((key - 1))
                if [[ $num -lt $total ]]; then
                    MENU_SELECTED=$num
                    cursor_show
                    MENU_RESULT=$MENU_SELECTED
                    return 0
                fi
                ;;
        esac
    done
}

# Input dialog - FIXED
input_dialog() {
    local prompt="$1"
    local default="${2:-}"
    
    # Terminal'i düzgün ayarla
    reset_terminal
    
    clear_screen
    draw_box "$prompt"
    echo ""
    
    local input_value=""
    
    if [[ -n "$default" ]]; then
        echo -ne "  ${C_PRIMARY}>${C_RESET} [$default]: "
    else
        echo -ne "  ${C_PRIMARY}>${C_RESET} "
    fi
    
    # Input al
    read -r input_value
    
    # Default değer
    if [[ -z "$input_value" ]] && [[ -n "$default" ]]; then
        input_value="$default"
    fi
    
    # Global değişkene kaydet
    INPUT_RESULT="$input_value"
    
    cursor_hide
}

# Confirm dialog - FIXED
confirm_dialog() {
    local message="$1"
    
    reset_terminal
    
    echo ""
    echo -ne "  ${C_WARNING}$message (e/h):${C_RESET} "
    
    local response
    read -rsn1 response
    echo ""
    
    cursor_hide
    
    [[ "${response,,}" == "e" || "${response,,}" == "y" ]]
}

# Show message with delay
show_message() {
    local type="$1"
    local message="$2"
    
    echo ""
    case "$type" in
        success) echo -e "  ${C_SUCCESS}✓ ${message}${C_RESET}" ;;
        error)   echo -e "  ${C_DANGER}✗ ${message}${C_RESET}" ;;
        warning) echo -e "  ${C_WARNING}! ${message}${C_RESET}" ;;
        info)    echo -e "  ${C_PRIMARY}ℹ ${message}${C_RESET}" ;;
    esac
    
    sleep 1
}

# Loading indicator
show_loading() {
    local message="${1:-İşleniyor...}"
    echo -ne "  ${C_MUTED}⏳ ${message}${C_RESET}"
}

# Clear loading
clear_loading() {
    echo -ne "\r\033[K"
}
