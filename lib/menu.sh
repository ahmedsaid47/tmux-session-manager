#!/bin/bash
# Menu system for TSM

# Menu state
declare -a MENU_ITEMS
declare -a MENU_ACTIONS
MENU_SELECTED=0
MENU_TITLE=""
MENU_FILTER=""

# Draw box around text
draw_box() {
    local title="$1"
    local width="${MENU_WIDTH:-44}"
    
    # Top border
    echo -e "${C_PRIMARY}${BOX_TL}$(printf '%*s' $((width-2)) '' | tr ' ' "$BOX_H")${BOX_TR}${C_RESET}"
    
    # Title
    local title_len=${#title}
    local padding=$(( (width - 2 - title_len) / 2 ))
    echo -e "${C_PRIMARY}${BOX_V}${C_RESET}$(printf '%*s' $padding '')${C_BOLD}$title${C_RESET}$(printf '%*s' $((width - 2 - padding - title_len)) '')${C_PRIMARY}${BOX_V}${C_RESET}"
    
    # Bottom border
    echo -e "${C_PRIMARY}${BOX_BL}$(printf '%*s' $((width-2)) '' | tr ' ' "$BOX_H")${BOX_BR}${C_RESET}"
}

# Draw menu items
draw_menu() {
    local start_index="${1:-0}"
    local max_items="${2:-10}"
    local total=${#MENU_ITEMS[@]}
    
    # Calculate visible range
    local end_index=$((start_index + max_items))
    [[ $end_index -gt $total ]] && end_index=$total
    
    # Draw items
    for ((i=start_index; i<end_index; i++)); do
        local item="${MENU_ITEMS[$i]}"
        if [[ $i -eq $MENU_SELECTED ]]; then
            echo -e "${MENU_PADDING}${C_HIGHLIGHT}${ICON_SELECTED} ${C_BOLD}${item}${C_RESET}"
        else
            echo -e "${MENU_PADDING}  ${item}"
        fi
    done
    
    # Show scroll indicators if needed
    if [[ $start_index -gt 0 ]]; then
        echo -e "${MENU_PADDING}${C_MUTED}  ↑ more${C_RESET}"
    fi
    if [[ $end_index -lt $total ]]; then
        echo -e "${MENU_PADDING}${C_MUTED}  ↓ more${C_RESET}"
    fi
}

# Draw help line
draw_help_line() {
    echo ""
    echo -e "${C_MUTED}${L_HELP_NAV} | ${L_HELP_SELECT} | ${L_HELP_BACK} | ${L_HELP_SEARCH} | ${L_HELP_HELP}${C_RESET}"
}

# Interactive menu loop
menu_loop() {
    local total=${#MENU_ITEMS[@]}
    local max_visible=10
    local scroll_offset=0
    
    cursor_hide
    
    while true; do
        clear_screen
        
        # Draw title
        draw_box "$MENU_TITLE"
        echo ""
        
        # Show filter if active
        if [[ -n "$MENU_FILTER" ]]; then
            echo -e "${MENU_PADDING}${ICON_SEARCH} ${C_PRIMARY}$MENU_FILTER${C_RESET}"
            echo ""
        fi
        
        # Calculate scroll offset
        if [[ $MENU_SELECTED -lt $scroll_offset ]]; then
            scroll_offset=$MENU_SELECTED
        elif [[ $MENU_SELECTED -ge $((scroll_offset + max_visible)) ]]; then
            scroll_offset=$((MENU_SELECTED - max_visible + 1))
        fi
        
        # Draw menu
        draw_menu $scroll_offset $max_visible
        
        # Draw help
        draw_help_line
        
        # Read input
        local key
        key=$(read_key)
        
        # Arrow key escape sequences
        local UP=$'\e[A'
        local DOWN=$'\e[B'
        local HOME=$'\e[H'
        local END=$'\e[F'
        local ESC=$'\e'
        
        case "$key" in
            "$UP"|k)  # Up arrow or k
                [[ $MENU_SELECTED -gt 0 ]] && ((MENU_SELECTED--)) || true
                ;;
            "$DOWN"|j)  # Down arrow or j
                [[ $MENU_SELECTED -lt $((total-1)) ]] && ((MENU_SELECTED++)) || true
                ;;
            "$HOME"|g)  # Home or g
                MENU_SELECTED=0
                ;;
            "$END"|G)  # End or G
                MENU_SELECTED=$((total-1))
                ;;
            "")  # Enter
                cursor_show
                return $MENU_SELECTED
                ;;
            q|"$ESC")  # q or Escape alone
                cursor_show
                return 255
                ;;
            "?")  # Help
                show_help_menu
                ;;
            "/")  # Search
                menu_search
                ;;
            n)  # New session shortcut
                cursor_show
                return 254
                ;;
            d)  # Delete session shortcut
                cursor_show
                return 253
                ;;
            r)  # Rename session shortcut
                cursor_show
                return 252
                ;;
            [1-9])  # Quick select
                local num=$((key - 1))
                if [[ $num -lt $total ]]; then
                    MENU_SELECTED=$num
                    cursor_show
                    return $MENU_SELECTED
                fi
                ;;
        esac
    done
}

# Search in menu
menu_search() {
    echo ""
    echo -ne "${MENU_PADDING}${ICON_SEARCH} ${L_SEARCH}: "
    cursor_show
    read -r MENU_FILTER
    cursor_hide
    
    if [[ -n "$MENU_FILTER" ]]; then
        # Filter items
        local filtered=()
        local filter_lower="${MENU_FILTER,,}"
        
        for item in "${MENU_ITEMS[@]}"; do
            local item_lower="${item,,}"
            if [[ "$item_lower" == *"$filter_lower"* ]]; then
                filtered+=("$item")
            fi
        done
        
        if [[ ${#filtered[@]} -gt 0 ]]; then
            MENU_ITEMS=("${filtered[@]}")
            MENU_SELECTED=0
        else
            MENU_FILTER=""
        fi
    fi
}

# Show help menu
show_help_menu() {
    clear_screen
    draw_box "$L_HELP_TITLE"
    echo ""
    echo -e "${MENU_PADDING}${L_HELP_NAV}"
    echo -e "${MENU_PADDING}${L_HELP_SELECT}"
    echo -e "${MENU_PADDING}${L_HELP_BACK}"
    echo -e "${MENU_PADDING}${L_HELP_SEARCH}"
    echo -e "${MENU_PADDING}${L_HELP_NUMBERS}"
    echo -e "${MENU_PADDING}${L_HELP_HELP}"
    echo ""
    echo -e "${MENU_PADDING}${C_MUTED}${L_PRESS_ENTER}${C_RESET}"
    read -rsn1
}

# Confirmation dialog
confirm_dialog() {
    local message="$1"
    echo ""
    echo -ne "${MENU_PADDING}${C_WARNING}${message}? (y/N)${C_RESET} "
    read -rsn1 response
    echo ""
    [[ "${response,,}" == "y" ]]
}

# Input dialog
input_dialog() {
    local prompt="$1"
    local default="${2:-}"
    local result
    
    echo ""
    cursor_show
    if [[ -n "$default" ]]; then
        echo -ne "${MENU_PADDING}${prompt} [$default]: "
        read -r result
        result="${result:-$default}"
    else
        echo -ne "${MENU_PADDING}${prompt}: "
        read -r result
    fi
    cursor_hide
    
    echo "$result"
}

# Show message
show_message() {
    local type="$1"  # success, error, warning
    local message="$2"
    
    case "$type" in
        success)
            echo -e "${MENU_PADDING}${C_SUCCESS}${ICON_SUCCESS} ${message}${C_RESET}"
            ;;
        error)
            echo -e "${MENU_PADDING}${C_DANGER}${ICON_ERROR} ${message}${C_RESET}"
            ;;
        warning)
            echo -e "${MENU_PADDING}${C_WARNING}${ICON_WARNING} ${message}${C_RESET}"
            ;;
    esac
    sleep 1
}
