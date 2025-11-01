#!/usr/bin/env bash
set -euo pipefail

# ---------- helper funcs ----------

msg() { printf "\n[%s] %s\n" "$(date +%H:%M:%S)" "$*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    msg "FATAL: required command '$1' not found."
    exit 1
  }
}

install_pkg_mac() {
  # macOS assumed to have brew already. if not, enjoy pain.
  if ! command -v brew >/dev/null 2>&1; then
    msg "Homebrew not found. Install it first."
    exit 1
  fi
  brew install "$@"
}

install_pkg_apt() {
  sudo apt update
  sudo apt install -y "$@"
}

install_pkg_yum() {
  sudo yum install -y "$@"
}

detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
    return
  fi
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    case "$ID" in
      ubuntu|debian) echo "debian"; return ;;
      centos|rhel|rocky|almalinux|fedora) echo "rhel"; return ;;
    esac
  fi
  echo "unknown"
}

ensure_zsh() {
  if command -v zsh >/dev/null 2>&1; then
    msg "zsh already installed: $(command -v zsh)"
    return
  fi

  case "$OS" in
    macos)
      msg "Installing zsh via brew"
      install_pkg_mac zsh
      ;;
    debian)
      msg "Installing zsh via apt"
      install_pkg_apt zsh git curl
      ;;
    rhel)
      msg "Installing zsh via yum"
      install_pkg_yum zsh git curl
      ;;
    *)
      msg "OS not recognized. Install zsh manually."
      exit 1
      ;;
  esac
}

install_oh_my_zsh() {
  if [[ -d "${HOME}/.oh-my-zsh" ]]; then
    msg "oh-my-zsh already present."
    return
  fi

  msg "Installing oh-my-zsh (unattended)..."
  # official installer supports --unattended
  RUNZSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  msg "oh-my-zsh installed."
}

install_powerlevel10k() {
  local theme_dir="${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"
  if [[ -d "$theme_dir" ]]; then
    msg "powerlevel10k already present."
    return
  fi

  msg "Cloning powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"
}

backup_file() {
  local f="$1"
  if [[ -f "$f" && ! -f "$f.bak" ]]; then
    cp "$f" "$f.bak"
    msg "Backed up $f to $f.bak"
  fi
}

write_server_label() {
  local label="$1"
  local metafile="${HOME}/.p10k-meta"

  # strip quotes/newlines just in case
  label="$(echo "$label" | tr -d '"' | tr -d '\n')"

  echo "SERVER_NAME=\"$label\"" > "$metafile"
  printf "\n[setup] SERVER_NAME set to '%s' in %s\n" "$label" "$metafile"
}


deploy_configs() {
  # we assume script is run from repo root where zshrc and p10k.zsh exist
  local SRC_DIR
  SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

  # .zshrc
  backup_file "${HOME}/.zshrc"
  cp "${SRC_DIR}/zshrc" "${HOME}/.zshrc"
  msg "Deployed .zshrc"

  # .p10k.zsh
  backup_file "${HOME}/.p10k.zsh"
  cp "${SRC_DIR}/p10k.zsh" "${HOME}/.p10k.zsh"
  msg "Deployed .p10k.zsh"
}

set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ "$SHELL" == "$zsh_path" ]]; then
    msg "Default shell already zsh"
    return
  fi

  # make sure shell is in /etc/shells
  if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
    msg "Adding $zsh_path to /etc/shells (sudo required)"
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  msg "Changing default shell to $zsh_path (you may be prompted for password)"
  chsh -s "$zsh_path"
}

# ---------- main flow ----------

OS=$(detect_os)
msg "Detected OS: $OS"

ensure_zsh
install_oh_my_zsh
install_powerlevel10k
deploy_configs
set_default_shell

msg "Done. Open a new terminal or run: exec zsh"
