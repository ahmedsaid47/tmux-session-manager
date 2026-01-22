#!/bin/bash
#
# TSM - Tmux Session Manager Installer
# https://github.com/ahmedsaid47/tmux-session-manager
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

REPO_URL="https://github.com/ahmedsaid47/tmux-session-manager"
RAW_URL="https://raw.githubusercontent.com/ahmedsaid47/tmux-session-manager/main"
INSTALL_DIR="${HOME}/.local/share/tsm"
BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-session-manager"

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}   ${BOLD}TSM - Tmux Session Manager Installer${NC}    ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() { echo -e "${CYAN}▶${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }

check_requirements() {
    print_step "Checking requirements..."
    
    if ! command -v tmux &>/dev/null; then
        print_error "tmux is not installed"
        echo "  Install: sudo apt install tmux"
        exit 1
    fi
    print_success "tmux found: $(tmux -V)"
    
    if command -v curl &>/dev/null; then
        DOWNLOADER="curl -sL"
    elif command -v wget &>/dev/null; then
        DOWNLOADER="wget -qO-"
    else
        print_error "curl or wget is required"
        exit 1
    fi
    print_success "Downloader ready"
}

create_directories() {
    print_step "Creating directories..."
    mkdir -p "$INSTALL_DIR"/{lib,lang,themes}
    mkdir -p "$BIN_DIR"
    mkdir -p "$CONFIG_DIR"
    print_success "Directories created"
}

download_files() {
    print_step "Downloading files..."
    
    $DOWNLOADER "$RAW_URL/tsm" > "$INSTALL_DIR/tsm"
    chmod +x "$INSTALL_DIR/tsm"
    
    for lib in core.sh config.sh lang.sh menu.sh utils.sh; do
        $DOWNLOADER "$RAW_URL/lib/$lib" > "$INSTALL_DIR/lib/$lib"
    done
    
    for lang in en.sh tr.sh; do
        $DOWNLOADER "$RAW_URL/lang/$lang" > "$INSTALL_DIR/lang/$lang"
    done
    
    for theme in default.sh minimal.sh; do
        $DOWNLOADER "$RAW_URL/themes/$theme" > "$INSTALL_DIR/themes/$theme"
    done
    
    print_success "Files downloaded"
}

create_symlink() {
    print_step "Creating symlink..."
    ln -sf "$INSTALL_DIR/tsm" "$BIN_DIR/tsm"
    print_success "Symlink: $BIN_DIR/tsm"
}

configure_shell() {
    print_step "Configuring shell..."
    
    local shell_config="$HOME/.bashrc"
    [[ "$(basename $SHELL)" == "zsh" ]] && shell_config="$HOME/.zshrc"
    
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_config"
        print_success "Added to PATH"
    fi
    
    if ! grep -q "tsm" "$shell_config" 2>/dev/null; then
        echo '' >> "$shell_config"
        echo '# TSM - Auto-start on SSH' >> "$shell_config"
        echo '[[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]] && tsm' >> "$shell_config"
        print_success "Auto-start configured"
    fi
}

configure_tmux() {
    print_step "Configuring tmux..."
    local tmux_conf="$HOME/.tmux.conf"
    
    if ! grep -q "TSM" "$tmux_conf" 2>/dev/null; then
        cat >> "$tmux_conf" << 'EOF'

# TSM settings
set -g history-limit 50000
set -g mouse on
setw -g mode-keys vi
EOF
        print_success "tmux configured"
    fi
}

print_completion() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}        ${BOLD}Installation Complete!${NC}              ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${CYAN}tsm${NC}         Start interactive menu"
    echo -e "  ${CYAN}tsm -n dev${NC}  Create new session"
    echo -e "  ${CYAN}tsm -l${NC}      List sessions"
    echo ""
    echo -e "  ${YELLOW}source ~/.bashrc${NC} to apply changes"
    echo ""
}

uninstall() {
    print_header
    rm -rf "$INSTALL_DIR" "$CONFIG_DIR"
    rm -f "$BIN_DIR/tsm"
    print_success "TSM uninstalled"
}

case "${1:-}" in
    --uninstall|-u) uninstall ;;
    --help|-h) echo "Usage: install.sh [--uninstall]" ;;
    *) print_header; check_requirements; create_directories; download_files; create_symlink; configure_shell; configure_tmux; print_completion ;;
esac
