#!/usr/bin/env bash
set -euo pipefail

msg() { printf "\n[%s] %s\n" "$(date +%H:%M:%S)" "$*"; }

restore_shell() {
  # Try to switch user back to bash.
  # If /bin/bash is not valid for some cursed reason, we just warn.
  local bash_path="/bin/bash"

  if command -v bash >/dev/null 2>&1; then
    bash_path="$(command -v bash)"
  fi

  if [[ -x "$bash_path" ]]; then
    if [[ "$SHELL" != "$bash_path" ]]; then
      msg "Changing default shell back to $bash_path"
      # ensure it's in /etc/shells
      if ! grep -q "$bash_path" /etc/shells 2>/dev/null; then
        msg "Adding $bash_path to /etc/shells (sudo may be required)"
        echo "$bash_path" | sudo tee -a /etc/shells >/dev/null
      fi
      chsh -s "$bash_path"
    else
      msg "Default shell already $bash_path"
    fi
  else
    msg "WARNING: couldn't find a valid bash path to restore shell."
  fi
}

restore_configs() {
  # If we had backups, put them back. If not, just remove our stuff.

  # Handle .zshrc
  if [[ -f "${HOME}/.zshrc.bak" ]]; then
    msg "Restoring original .zshrc from backup"
    mv "${HOME}/.zshrc.bak" "${HOME}/.zshrc"
  else
    if [[ -f "${HOME}/.zshrc" ]]; then
      msg "Removing deployed .zshrc"
      rm -f "${HOME}/.zshrc"
    fi
  fi

  # Handle .p10k.zsh
  if [[ -f "${HOME}/.p10k.zsh.bak" ]]; then
    msg "Restoring original .p10k.zsh from backup"
    mv "${HOME}/.p10k.zsh.bak" "${HOME}/.p10k.zsh"
  else
    if [[ -f "${HOME}/.p10k.zsh" ]]; then
      msg "Removing deployed .p10k.zsh"
      rm -f "${HOME}/.p10k.zsh"
    fi
  fi

  # Remove per-host label metadata
  if [[ -f "${HOME}/.p10k-meta" ]]; then
    msg "Removing .p10k-meta"
    rm -f "${HOME}/.p10k-meta"
  fi
}

remove_oh_my_zsh() {
  local omz_dir="${HOME}/.oh-my-zsh"

  if [[ -d "$omz_dir" ]]; then
    msg "Removing ~/.oh-my-zsh (this deletes powerlevel10k theme too)"
    rm -rf "$omz_dir"
  else
    msg "~/.oh-my-zsh not found, skipping"
  fi
}

main() {
  msg "Starting revoke (rollback) process"

  restore_shell
  restore_configs
  remove_oh_my_zsh

  msg "Revoke complete. Open a new terminal. If you're still in zsh, run: exec bash"
}

main "$@"
