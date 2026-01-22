# 🖥️ TSM - Tmux Session Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/Bash-4.0+-green.svg)](https://www.gnu.org/software/bash/)

Interactive tmux session manager with arrow-key navigation. Perfect for SSH and mosh connections.

## ✨ Features

- 🎮 **Arrow-key navigation** - No need to remember commands
- 🌍 **Multi-language** - Auto-detects system language (EN/TR)
- 🎨 **Themes** - Modern (emoji) and minimal (ASCII) modes
- 📜 **Scroll support** - Works great with mosh
- ⚡ **Fast** - Pure bash, no dependencies except tmux
- 🔧 **Configurable** - Customize via config file

## 📸 Preview

```
╔══════════════════════════════════════════╗
║       🖥️  TMUX SESSION MANAGER          ║
╠══════════════════════════════════════════╣
║  📋 Sessions:                            ║
║                                          ║
║   ▸ main         (3 windows)  ●          ║
║     dev          (2 windows)             ║
║     server       (1 window)              ║
║                                          ║
╠══════════════════════════════════════════╣
║ ↑↓ Navigate  Enter Select  n New  d Del  ║
╚══════════════════════════════════════════╝
```

## 🚀 Quick Install

```bash
curl -sL https://raw.githubusercontent.com/ahmedsaid47/tmux-session-manager/main/install.sh | bash
```

## 📖 Usage

```bash
tsm                 # Interactive menu
tsm -n project      # Create new session
tsm -l              # List sessions
tsm -a              # Attach to last session
tsm --help          # Show help
```

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `↑/↓` | Navigate sessions |
| `Enter` | Attach to session |
| `n` | New session |
| `d` | Delete session |
| `r` | Rename session |
| `/` | Search sessions |
| `?` | Help |
| `q` | Quit |

## ⚙️ Configuration

Config file: `~/.config/tmux-session-manager/config.conf`

```conf
language=auto       # auto, en, tr
theme=default       # default, minimal
show_preview=true   # Show session details
```

## 🔧 Manual Installation

```bash
git clone https://github.com/ahmedsaid47/tmux-session-manager.git
cd tmux-session-manager
./install.sh
```

## 🗑️ Uninstall

```bash
curl -sL https://raw.githubusercontent.com/ahmedsaid47/tmux-session-manager/main/install.sh | bash -s -- --uninstall
```

## 📋 Requirements

- tmux 2.0+
- bash 4.0+ (macOS may need update)
- curl or wget

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

## 📄 License

MIT License - see [LICENSE](LICENSE)

## 🙏 Credits

Created by [@ahmedsaid47](https://github.com/ahmedsaid47)
