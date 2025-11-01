# 🚀 Auto Powerlevel10k

> **Automated setup for a beautiful, feature-rich zsh terminal with Powerlevel10k theme** ⚡

[![Shell](https://img.shields.io/badge/Shell-Zsh-blue?logo=linux&logoColor=white)](https://www.zsh.org/)
[![Theme](https://img.shields.io/badge/Theme-Powerlevel10k-yellow?logo=github&logoColor=white)](https://github.com/romkatv/powerlevel10k)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An automated installer that sets up **Oh My Zsh** with the **Powerlevel10k** theme, providing you with a beautiful, fast, and highly customizable terminal experience. Perfect for macOS and Linux systems.

---

## ✨ Features

- 🎨 **Beautiful Prompt**: Rainbow-colored Powerlevel10k theme with custom server name display
- ⚡ **Fast & Lightweight**: Optimized for performance with instant prompt support
- 🔧 **Auto-Configuration**: Automatic OS detection and dependency installation
- 🛡️ **Safe Installation**: Automatic backup of existing configurations before changes
- 🔄 **Easy Rollback**: Complete uninstall script to restore your previous setup
- 📦 **Cross-Platform**: Supports macOS (via Homebrew), Debian/Ubuntu, and RHEL/CentOS
- 🎯 **Smart Defaults**: Pre-configured with useful plugins and settings

---

## 📋 Requirements

### macOS
- [Homebrew](https://brew.sh/) installed
- `git`, `curl` (usually pre-installed)

### Linux (Debian/Ubuntu)
- `sudo` access
- `apt` package manager
- Internet connection

### Linux (RHEL/CentOS/Fedora)
- `sudo` access
- `yum` or `dnf` package manager
- Internet connection

---

## 🚀 Quick Start

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/borankux/auto-p10k.git
cd auto-p10k
```

2. **Run the installer:**
```bash
chmod +x install.sh
./install.sh
```

3. **Optionally set a custom server name:**
```bash
./install.sh "My Server"
```

4. **Open a new terminal or reload zsh:**
```bash
exec zsh
```

That's it! 🎉 Your terminal is now powered by Powerlevel10k.

---

## 📖 What Gets Installed

The installer automatically sets up:

- ✅ **zsh** shell (if not already installed)
- ✅ **Oh My Zsh** framework
- ✅ **Powerlevel10k** theme
- ✅ **Pre-configured plugins:**
  - `git` - Git aliases and functions
  - `z` - Smart directory jumping
  - `sudo` - Press ESC twice to prefix previous command with sudo
  - `zsh-autosuggestions` - Fish-like autosuggestions
  - `zsh-syntax-highlighting` - Command syntax highlighting

---

## 🎨 Customization

### Setting Server Name

The prompt includes a custom server name segment. Set it during installation or manually:

```bash
# During installation
./install.sh "Production Server"

# Or manually create/edit ~/.p10k-meta
echo 'SERVER_NAME="My Custom Label"' > ~/.p10k-meta
```

Then reload your shell:
```bash
source ~/.zshrc
```

### Customizing the Theme

Run the interactive configuration wizard:
```bash
p10k configure
```

Or manually edit `~/.p10k.zsh` to customize colors, segments, and behavior.

### Adding Plugins

Edit `~/.zshrc` and modify the `plugins` line:
```bash
plugins=(git z sudo zsh-autosuggestions zsh-syntax-highlighting docker kubectl)
```

Then reload:
```bash
source ~/.zshrc
```

---

## 🔄 Uninstallation

To completely remove the installation and restore your previous setup:

```bash
chmod +x revoke.sh
./revoke.sh
```

This script will:
- 🔙 Restore your default shell to bash
- 📁 Restore original `.zshrc` and `.p10k.zsh` from backups (if they existed)
- 🗑️ Remove `~/.oh-my-zsh` directory
- 🧹 Clean up metadata files

**Note:** Your original configs are backed up as `.bak` files before any changes are made.

---

## 📁 Project Structure

```
auto-p10k/
├── install.sh       # Main installation script
├── revoke.sh        # Uninstallation/rollback script
├── zshrc            # Oh My Zsh configuration file
├── p10k.zsh         # Powerlevel10k theme configuration
└── README.md        # This file
```

---

## 🔍 How It Works

### Installation Process

1. **OS Detection**: Automatically detects your operating system (macOS/Debian/RHEL)
2. **Dependency Check**: Verifies required tools are available
3. **zsh Installation**: Installs zsh if not present
4. **Oh My Zsh Setup**: Downloads and configures Oh My Zsh (unattended mode)
5. **Theme Installation**: Clones Powerlevel10k theme
6. **Config Deployment**: Copies configuration files (with backups)
7. **Shell Switch**: Changes default shell to zsh

### Safety Features

- ✅ Automatic backup of existing configs (`.bak` files)
- ✅ Idempotent installation (safe to run multiple times)
- ✅ Error handling with `set -euo pipefail`
- ✅ Detailed logging with timestamps

---

## 🛠️ Troubleshooting

### Issue: Font rendering problems

**Solution**: Install a Nerd Font. The theme uses Nerd Font v3 icons.

```bash
# macOS (Homebrew)
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font

# Then set it as your terminal font
```

### Issue: Slow prompt

**Solution**: The prompt is optimized for speed. If it's still slow:
- Check if you're in a very large Git repository
- Disable some right-side segments in `~/.p10k.zsh`
- Run `p10k configure` and choose "Fewer icons"

### Issue: Colors look wrong

**Solution**: 
- Ensure your terminal supports 256 colors
- Run `p10k configure` to regenerate color settings
- Check your terminal's color scheme settings

### Issue: Plugins not working

**Solution**: Some plugins require manual installation:
```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

Then reload: `source ~/.zshrc`

---

## 📝 Configuration Files

### `.zshrc`
- Oh My Zsh initialization
- Plugin configuration
- Powerlevel10k theme loading

### `.p10k.zsh`
- Powerlevel10k theme settings
- Prompt segments configuration
- Color schemes
- Custom `server_name` segment

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Oh My Zsh](https://ohmyz.sh/) - A delightful community-driven framework
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - A fast and beautiful prompt
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - Fish-like autosuggestions
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) - Command syntax highlighting

---

## ⭐ Star History

If you find this project useful, please consider giving it a star! ⭐

---

## 📞 Support

Found a bug or have a feature request? Please [open an issue](https://github.com/yourusername/auto-p10k/issues).

---

**Made with ❤️ for developers who love beautiful terminals**

