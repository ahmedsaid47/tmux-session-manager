# 🖥️ Tmux Session Manager

SSH/Mosh bağlantılarında tmux oturumlarını **sadece yön tuşları ve Enter** ile yönetin.

![Demo](https://raw.githubusercontent.com/ahmedsaid47/tmux-session-manager/main/demo.gif)

## ✨ Özellikler

- 📂 **Mevcut oturumlara bağlan** - Aktif/pasif durumu görün
- ➕ **Yeni oturum oluştur** - İsim vererek
- 🗑️ **Oturum sil** - Kolay silme menüsü
- 🔄 **Bağlantı kopsa bile** - İşlemler devam eder
- 📜 **Scroll desteği** - Mosh'ta bile çalışır (50K satır geçmiş)
- 🖱️ **Mouse desteği** - Tıklayarak gezin

## 🚀 Kurulum

```bash
curl -sL https://raw.githubusercontent.com/ahmedsaid47/tmux-session-manager/main/install.sh | bash
```

## 📖 Kullanım

SSH ile bağlandığınızda otomatik açılır:

```
╔════════════════════════════════════════╗
║     🖥️  TMUX OTURUM YÖNETİCİSİ          ║
╚════════════════════════════════════════╝

↑↓ Seç | Enter Onayla

  ▶ ➕ Yeni Oturum Oluştur
    📂 main (1 pencere, 🟢 aktif)
    📂 dev (3 pencere, ⚪ pasif)
    🗑️  Oturum Sil
    🚪 Çıkış
```

### Tuşlar

| Tuş | İşlev |
|-----|-------|
| `↑` `↓` | Seçim yap |
| `Enter` | Onayla |

### Tmux İçinde

| Kısayol | İşlev |
|---------|-------|
| `Ctrl+b s` | Oturum seçici |
| `Ctrl+b u` | Scroll modu |
| `Ctrl+b d` | Oturumdan ayrıl |

## 🔧 Manuel Çalıştırma

```bash
~/.tmux-menu.sh
```

## 📝 Gereksinimler

- tmux
- bash 4+

## 📄 Lisans

MIT

---

⭐ Beğendiyseniz yıldız verin!
