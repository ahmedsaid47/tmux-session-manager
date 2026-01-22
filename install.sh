#!/bin/bash

# Tmux Session Manager - Kurulum Scripti
# https://github.com/ahmedsaid47/tmux-session-manager

set -e

echo "🚀 Tmux Session Manager kuruluyor..."

# Scripti indir
curl -sL https://raw.githubusercontent.com/ahmedsaid47/tmux-session-manager/main/tmux-menu.sh -o ~/.tmux-menu.sh
chmod +x ~/.tmux-menu.sh

# Tmux config ekle
cat >> ~/.tmux.conf << 'TMUXCONF'
# Tmux Session Manager ayarları
set -g history-limit 50000
set -g mouse on
set -g status-style 'bg=blue fg=white'
set -g status-left '[#S] '
setw -g mode-keys vi
bind s choose-tree -sZ
bind u copy-mode
TMUXCONF

# Bashrc'ye ekle (eğer yoksa)
if ! grep -q "tmux-menu.sh" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'BASHRC'

# Tmux Session Manager - SSH bağlantısında otomatik başlat
if [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
    ~/.tmux-menu.sh
fi
BASHRC
fi

echo "✅ Kurulum tamamlandı!"
echo "�� Yeni SSH bağlantısında menü otomatik açılacak."
echo "📖 Manuel çalıştır: ~/.tmux-menu.sh"
