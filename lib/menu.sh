#!/bin/bash
# Menu system for TSM
# Safe for set -e environments

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
    if [[ $end_index -gt $total ]]; then
        end_index=$total
    fi
    
    local i
    for ((i=start_index; i<end_index; i++)); do
        local item="${MENU_ITEMS[$i]}"
        if [[ $i -eq $MENU_SELECTED ]]; then
            echo -e "${MENU_PADDING}${C_HIGHLIGHT}${ICON_SELECTED} ${C_BOLD}${item}${C_RESET}"
        else
            echo -e "${MENU_PADDING}  ${item}"
        fi
    done
    
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

# Safe decrement
menu_up() {
    if [[ $MENU_SELECTED -gt 0 ]]; then
        MENU_SELECTED=$((MENU_SELECTED - 1))
    fi
}

# Safe increment
menu_down() {
    local total=${#MENU_ITEMS[@]}
    local max=$((total - 1))
    if [[ $MENU_SELECTED -lt $max ]]; then
        MENU_SELECTED=$((MENU_SELECTED + 1))
    fi
}

# Interactive menu loop - returns selection via MENU_RESULT variable
menu_loop() {
    local total=${#MENU_ITEMS[@]}
    local max_visible=10
    local scroll_offset=0
    
    # Arrow key sequences
    local KEY_UP=$'\e[A'
    local KEY_DOWN=$'\e[B'
    local KEY_HOME=$'\e[H'
    local KEY_END=$'\e[F'
    local KEY_ESC=$'\e'
    
    cursor_hide
    
    while true; do
        clear_screen
        draw_box "$MENU_TITLE"
        echo ""
        
        if [[ -n "$MENU_FILTER" ]]; then
            echo -e "${MENU_PADDING}${ICON_SEARCH} ${C_PRIMARY}$MENU_FILTER${C_RESET}"
            echo ""
        fi
        
        # Calculate scroll
        if [[ $MENU_SELECTED -lt $scroll_offset ]]; then
            scroll_offset=$MENU_SELECTED
        elif [[ $MENU_SELECTED -ge $((scroll_offset + max_visible)) ]]; then
            scroll_offset=$((MENU_SELECTED - max_visible + 1))
        fi
        
        draw_menu $scroll_offset $max_visible
        draw_help_line
        
        # Read key
        local key
        key=$(read_key)
        
        # Handle key
        case "$key" in
            "$KEY_UP"|k)
                menu_up
                ;;
            "$KEY_DOWN"|j)
                menu_down
                ;;
            "$KEY_HOME"|g)
                MENU_SELECTED=0
                ;;
            "$KEY_END"|G)
                MENU_SELECTED=$((total - 1))
                ;;
            ""|$'\n')  # Enter key
                cursor_show
                MENU_RESULT=$MENU_SELECTED
                return 0
                ;;
            q)
                cursor_show
                MENU_RESULT=255
                return 0
                ;;
            "$KEY_ESC")
                # Check if it's just ESC (not arrow key)
                cursor_show
                MENU_RESULT=255
                return 0
                ;;
            "?")
                show_help_menu
                ;;
            "/")
                menu_search
                total=${#MENU_ITEMS[@]}
                ;;
            n)
                cursor_show
                MENU_RESULT=254
                return 0
                ;;
            d)
                cursor_show
                MENU_RESULT=253
                return 0
                ;;
            r)
                cursor_show
                MENU_RESULT=252
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
            *)
                # Ignore unknown keys
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
        local filtered=()
        local filter_lower="${MENU_FILTER,,}"
        
        local item
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
    local response
    echo ""
    echo -ne "${MENU_PADDING}${C_WARNING}${message}? (y/N)${C_RESET} "
    read -rsn1 response
    echo ""
    if [[ "${response,,}" == "y" ]]; then
        return 0
    else
        return 1
    fi
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
        if [[ -z "$result" ]]; then
            result="$default"
        fi
    else
        echo -ne "${MENU_PADDING}${prompt}: "
        read -r result
    fi
    cursor_hide
    
    echo "$result"
}

# Show message
show_message() {
    local type="$1"
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
