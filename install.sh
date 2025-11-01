#!/usr/bin/env bash
set -euo pipefail

# ---------- helper funcs ----------

msg() { printf "\n[%s] %s\n" "$(date +%H:%M:%S)" "$*"; }
success() { printf "\n[%s] ✅ %s\n" "$(date +%H:%M:%S)" "$*"; }
error() { printf "\n[%s] ❌ %s\n" "$(date +%H:%M:%S)" "$*" >&2; }
warning() { printf "\n[%s] ⚠️  %s\n" "$(date +%H:%M:%S)" "$*"; }
info() { printf "\n[%s] ℹ️  %s\n" "$(date +%H:%M:%S)" "$*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    error "Required command '$1' not found."
    info "💡 Hint: Install '$1' using your system's package manager"
    info "   macOS: brew install $1"
    info "   Debian/Ubuntu: sudo apt install $1"
    info "   RHEL/CentOS: sudo yum install $1"
    exit 1
  }
}

install_pkg_mac() {
  # macOS assumed to have brew already. if not, enjoy pain.
  if ! command -v brew >/dev/null 2>&1; then
    error "Homebrew not found!"
    info "💡 Hint: Install Homebrew first by running:"
    info "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    info "   Visit https://brew.sh for more information"
    exit 1
  fi
  if ! brew install "$@"; then
    error "Failed to install packages: $*"
    info "💡 Hint: Try running 'brew update' first, then retry installation"
    exit 1
  fi
}

install_pkg_apt() {
  info "Updating package lists..."
  if ! sudo apt update; then
    error "Failed to update package lists"
    info "💡 Hint: Check your internet connection and try again"
    info "   If using sudo, ensure you have proper permissions"
    exit 1
  fi
  info "Installing packages: $*"
  if ! sudo apt install -y "$@"; then
    error "Failed to install packages: $*"
    info "💡 Hint: Check if packages exist: apt search <package-name>"
    info "   Ensure your package sources are up to date"
    exit 1
  fi
}

install_pkg_yum() {
  info "Installing packages: $*"
  if ! sudo yum install -y "$@"; then
    error "Failed to install packages: $*"
    info "💡 Hint: Try 'sudo dnf install' instead if on newer RHEL/Fedora"
    info "   Check if packages exist: yum search <package-name>"
    info "   Ensure your package sources are configured correctly"
    exit 1
  fi
}

detect_os() {
  # First handle macOS cleanly.
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "macos"
    return
  fi

  # Then handle Linuxes.
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release

    # normalize to lowercase because some distros scream in caps
    local id_lc=""
    if [[ -n "${ID:-}" ]]; then
      id_lc="$(echo "$ID" | tr '[:upper:]' '[:lower:]')"
    fi

    local id_like_lc=""
    if [[ -n "${ID_LIKE:-}" ]]; then
      id_like_lc="$(echo "$ID_LIKE" | tr '[:upper:]' '[:lower:]')"
    fi

    # direct known matches
    case "$id_lc" in
      ubuntu|debian)
        echo "debian"
        return
        ;;

      centos|rhel|rocky|almalinux|fedora|ol|redhat|alinux|anolis)
        # alinux (Alibaba Cloud Linux) and anolis are RHEL-family
        echo "rhel"
        return
        ;;
    esac

    # fallback via ID_LIKE (helps with custom/cloud distros)
    if [[ "$id_like_lc" == *"debian"* ]]; then
        echo "debian"
        return
    fi
    if [[ "$id_like_lc" == *"rhel"* || "$id_like_lc" == *"centos"* || "$id_like_lc" == *"fedora"* || "$id_like_lc" == *"rocky"* || "$id_like_lc" == *"almalinux"* || "$id_like_lc" == *"anolis"* || "$id_like_lc" == *"alinux"* ]]; then
        echo "rhel"
        return
    fi

    # couldn't classify but it's still Linux
    echo "linux"
    return
  fi

  # If we got here, we're in something cursed (BusyBox initrd, etc.)
  echo "unknown"
}


ensure_zsh() {
  if command -v zsh >/dev/null 2>&1; then
    msg "zsh already installed: $(command -v zsh)"
    return
  fi

  case "$OS" in
    macos)
      msg "Installing zsh/git/curl via brew"
      install_pkg_mac
      ;;

    debian)
      msg "Installing zsh/git/curl via apt"
      install_pkg_apt
      ;;

    rhel)
      msg "Installing zsh/git/curl via yum/dnf"
      # some rhel-ish distros use yum, some swapped to dnf, some alias yum->dnf
      if command -v yum >/dev/null 2>&1; then
        install_pkg_yum
      elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y zsh git curl
      else
        msg "No yum/dnf found on rhel-like system. Please install zsh manually."
        exit 1
      fi
      ;;

    linux)
      msg "Generic Linux detected, attempting apt/yum fallback"
      if command -v apt >/dev/null 2>&1; then
        install_pkg_apt
      elif command -v yum >/dev/null 2>&1; then
        install_pkg_yum
      elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y zsh git curl
      else
        msg "Couldn't find apt, yum or dnf. Manual intervention required."
        exit 1
      fi
      ;;

    *)
      msg "OS not recognized. Couldn't auto-install zsh."
      exit 1
      ;;
  esac
}



install_oh_my_zsh() {
  if [[ -d "${HOME}/.oh-my-zsh" ]]; then
    success "oh-my-zsh already present"
    return
  fi

  info "📥 Installing oh-my-zsh (unattended mode)..."
  # official installer supports --unattended
  if ! RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
    error "Failed to install oh-my-zsh"
    info "💡 Hint: Check your internet connection"
    info "   Try running: curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
    info "   If it fails, there may be network or DNS issues"
    exit 1
  fi

  success "oh-my-zsh installed successfully"
}

install_powerlevel10k() {
  local theme_dir="${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"
  if [[ -d "$theme_dir" ]]; then
    success "powerlevel10k already present"
    return
  fi

  info "🎨 Cloning powerlevel10k theme..."
  if ! git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir" 2>&1; then
    error "Failed to clone powerlevel10k"
    info "💡 Hint: Check your internet connection and git installation"
    info "   Verify: git --version"
    info "   Try manually: git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $theme_dir"
    exit 1
  fi
  success "powerlevel10k theme installed"
}


install_plugins() {
  # We're installing two plugins not bundled with Oh My Zsh by default:
  #   zsh-autosuggestions
  #   zsh-syntax-highlighting
  #
  # They go under $ZSH_CUSTOM/plugins/ so that your plugins=() line works.

  local custom_dir="${HOME}/.oh-my-zsh/custom/plugins"

  # autosuggestions
  if [[ -d "${custom_dir}/zsh-autosuggestions" ]]; then
    success "zsh-autosuggestions already present"
  else
    info "🔌 Installing zsh-autosuggestions plugin..."
    if ! git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${custom_dir}/zsh-autosuggestions" 2>&1; then
      error "Failed to clone zsh-autosuggestions"
      warning "Continuing without autosuggestions plugin..."
      info "💡 Hint: You can install it later manually"
    else
      success "zsh-autosuggestions installed"
    fi
  fi

  # syntax-highlighting
  if [[ -d "${custom_dir}/zsh-syntax-highlighting" ]]; then
    success "zsh-syntax-highlighting already present"
  else
    info "🔌 Installing zsh-syntax-highlighting plugin..."
    if ! git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "${custom_dir}/zsh-syntax-highlighting" 2>&1; then
      error "Failed to clone zsh-syntax-highlighting"
      warning "Continuing without syntax-highlighting plugin..."
      info "💡 Hint: You can install it later manually"
    else
      success "zsh-syntax-highlighting installed"
    fi
  fi
}


backup_file() {
  local f="$1"
  if [[ -f "$f" && ! -f "$f.bak" ]]; then
    if cp "$f" "$f.bak"; then
      success "Backed up $f to $f.bak"
    else
      error "Failed to backup $f"
      info "💡 Hint: Check file permissions and disk space"
      exit 1
    fi
  fi
}

write_server_label() {
  local label="$1"
  local metafile="${HOME}/.p10k-meta"

  # strip quotes/newlines just in case
  label="$(echo "$label" | tr -d '"' | tr -d '\n')"

  if echo "SERVER_NAME=\"$label\"" > "$metafile"; then
    success "Server label set to: '$label'"
  else
    warning "Failed to write server label (non-critical)"
    info "💡 Hint: You can manually set it later: echo 'SERVER_NAME=\"$label\"' > $metafile"
  fi
}


deploy_configs() {
  # we assume script is run from repo root where zshrc and p10k.zsh exist
  local SRC_DIR
  SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

  if [[ ! -f "${SRC_DIR}/zshrc" ]]; then
    error "Configuration file 'zshrc' not found in script directory"
    info "💡 Hint: Make sure you're running the script from the repository root"
    info "   Expected location: ${SRC_DIR}/zshrc"
    exit 1
  fi

  if [[ ! -f "${SRC_DIR}/p10k.zsh" ]]; then
    error "Configuration file 'p10k.zsh' not found in script directory"
    info "💡 Hint: Make sure you're running the script from the repository root"
    info "   Expected location: ${SRC_DIR}/p10k.zsh"
    exit 1
  fi

  # .zshrc
  info "📝 Deploying .zshrc configuration..."
  backup_file "${HOME}/.zshrc"
  if cp "${SRC_DIR}/zshrc" "${HOME}/.zshrc"; then
    success "Deployed .zshrc"
  else
    error "Failed to deploy .zshrc"
    info "💡 Hint: Check file permissions and disk space"
    exit 1
  fi

  # .p10k.zsh
  info "📝 Deploying .p10k.zsh configuration..."
  backup_file "${HOME}/.p10k.zsh"
  if cp "${SRC_DIR}/p10k.zsh" "${HOME}/.p10k.zsh"; then
    success "Deployed .p10k.zsh"
  else
    error "Failed to deploy .p10k.zsh"
    info "💡 Hint: Check file permissions and disk space"
    exit 1
  fi
}

set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ "$SHELL" == "$zsh_path" ]]; then
    success "Default shell already set to zsh"
    return
  fi

  # make sure shell is in /etc/shells
  if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
    info "➕ Adding $zsh_path to /etc/shells (sudo required)..."
    if ! echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null; then
      error "Failed to add zsh to /etc/shells"
      info "💡 Hint: You may need sudo permissions"
      info "   Try manually: echo '$zsh_path' | sudo tee -a /etc/shells"
      exit 1
    fi
  fi

  info "🔄 Changing default shell to $zsh_path (you may be prompted for password)..."
  if chsh -s "$zsh_path"; then
    success "Default shell changed to zsh"
  else
    error "Failed to change default shell"
    info "💡 Hint: You may need to enter your password"
    info "   Ensure $zsh_path is listed in /etc/shells"
    info "   Try manually: chsh -s $zsh_path"
    warning "You can manually change shell later"
  fi
}

# ---------- main flow ----------

OS=$(detect_os)
info "🔍 Detected OS: $OS"

if [[ "$OS" == "unknown" ]]; then
  warning "Could not automatically detect OS type"
  info "💡 Hint: Manual installation may be required"
fi

# Check if server label was provided as argument
if [[ -n "${1:-}" ]]; then
  write_server_label "$1"
fi

info "🚀 Starting installation process..."

ensure_zsh
install_oh_my_zsh
install_powerlevel10k
install_plugins
deploy_configs
set_default_shell

success "✨ Installation complete!"
info "📌 Next steps:"
info "   1. Open a new terminal, or"
info "   2. Run: exec zsh"
info "   3. Configure your prompt: p10k configure"
info ""
success "🎉 Enjoy your beautiful new terminal!"
