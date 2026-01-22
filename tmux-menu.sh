#!/bin/bash

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

show_menu() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}     ${BOLD}🖥️  TMUX OTURUM YÖNETİCİSİ${NC}          ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    # Oturumları al
    sessions=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && sessions+=("$line")
    done < <(tmux list-sessions -F "#{session_name}|#{session_windows} pencere|#{?session_attached,🟢 aktif,⚪ pasif}" 2>/dev/null)
    
    # Menü öğeleri
    items=()
    items+=("➕ Yeni Oturum Oluştur")
    for s in "${sessions[@]}"; do
        IFS='|' read -r name windows status <<< "$s"
        items+=("📂 $name ($windows, $status)")
    done
    items+=("🗑️  Oturum Sil")
    items+=("🚪 Çıkış")
    
    selected=0
    total=${#items[@]}
    
    while true; do
        # Menüyü çiz
        echo -e "${YELLOW}↑↓ Seç | Enter Onayla${NC}\n"
        
        for i in "${!items[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo -e "  ${GREEN}▶ ${BOLD}${items[$i]}${NC}"
            else
                echo -e "    ${items[$i]}"
            fi
        done
        
        # Tuş oku
        read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 key
            case $key in
                '[A') ((selected > 0)) && ((selected--)) ;;  # Yukarı
                '[B') ((selected < total-1)) && ((selected++)) ;;  # Aşağı
            esac
        elif [[ $key == "" ]]; then  # Enter
            handle_selection "$selected" "${sessions[@]}"
            return
        fi
        
        # Ekranı temizle ve başa dön
        tput cuu $((total + 2))
        tput ed
    done
}

handle_selection() {
    local sel=$1
    shift
    local sessions=("$@")
    
    if [[ $sel -eq 0 ]]; then
        # Yeni oturum
        echo ""
        read -p "Oturum adı: " name
        [[ -n "$name" ]] && tmux new-session -s "$name"
        
    elif [[ $sel -eq $((${#sessions[@]} + 1)) ]]; then
        # Sil
        delete_menu "${sessions[@]}"
        
    elif [[ $sel -eq $((${#sessions[@]} + 2)) ]]; then
        # Çıkış
        echo -e "\n${YELLOW}Güle güle!${NC}"
        exit 0
        
    else
        # Oturuma bağlan
        session_line="${sessions[$((sel-1))]}"
        session_name="${session_line%%|*}"
        tmux attach -t "$session_name"
    fi
}

delete_menu() {
    local sessions=("$@")
    
    if [[ ${#sessions[@]} -eq 0 ]]; then
        echo -e "\n${RED}Silinecek oturum yok!${NC}"
        sleep 1
        show_menu
        return
    fi
    
    clear
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC}        ${BOLD}🗑️  OTURUM SİL${NC}                   ${RED}║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    items=()
    for s in "${sessions[@]}"; do
        name="${s%%|*}"
        items+=("❌ $name")
    done
    items+=("↩️  Geri")
    
    selected=0
    total=${#items[@]}
    
    while true; do
        echo -e "${YELLOW}↑↓ Seç | Enter Sil${NC}\n"
        
        for i in "${!items[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo -e "  ${RED}▶ ${BOLD}${items[$i]}${NC}"
            else
                echo -e "    ${items[$i]}"
            fi
        done
        
        read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 key
            case $key in
                '[A') ((selected > 0)) && ((selected--)) ;;
                '[B') ((selected < total-1)) && ((selected++)) ;;
            esac
        elif [[ $key == "" ]]; then
            if [[ $selected -eq $((total-1)) ]]; then
                show_menu
                return
            else
                session_line="${sessions[$selected]}"
                session_name="${session_line%%|*}"
                tmux kill-session -t "$session_name" 2>/dev/null
                echo -e "\n${GREEN}✓ '$session_name' silindi${NC}"
                sleep 1
                show_menu
                return
            fi
        fi
        
        tput cuu $((total + 2))
        tput ed
    done
}

# Başlat
show_menu
