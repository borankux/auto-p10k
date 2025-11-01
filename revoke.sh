#!/usr/bin/env bash
set -euo pipefail

msg() { printf "\n[%s] %s\n" "$(date +%H:%M:%S)" "$*"; }
success() { printf "\n[%s] ✅ %s\n" "$(date +%H:%M:%S)" "$*"; }
error() { printf "\n[%s] ❌ %s\n" "$(date +%H:%M:%S)" "$*" >&2; }
warning() { printf "\n[%s] ⚠️  %s\n" "$(date +%H:%M:%S)" "$*"; }
info() { printf "\n[%s] ℹ️  %s\n" "$(date +%H:%M:%S)" "$*"; }

restore_shell() {
  # Try to switch user back to bash.
  # If /bin/bash is not valid for some cursed reason, we just warn.
  local bash_path="/bin/bash"

  if command -v bash >/dev/null 2>&1; then
    bash_path="$(command -v bash)"
  fi

  if [[ -x "$bash_path" ]]; then
    if [[ "$SHELL" != "$bash_path" ]]; then
      info "🔄 Changing default shell back to $bash_path..."
      # ensure it's in /etc/shells
      if ! grep -q "$bash_path" /etc/shells 2>/dev/null; then
        info "➕ Adding $bash_path to /etc/shells (sudo may be required)..."
        if ! echo "$bash_path" | sudo tee -a /etc/shells >/dev/null; then
          error "Failed to add bash to /etc/shells"
          info "💡 Hint: You may need sudo permissions"
          info "   Try manually: echo '$bash_path' | sudo tee -a /etc/shells"
          warning "Continuing with shell restore..."
        fi
      fi
      if chsh -s "$bash_path"; then
        success "Default shell changed back to $bash_path"
      else
        error "Failed to change default shell to $bash_path"
        info "💡 Hint: You may need to enter your password"
        info "   Ensure $bash_path is listed in /etc/shells"
        info "   Try manually: chsh -s $bash_path"
        warning "You may need to change shell manually after this script completes"
      fi
    else
      success "Default shell already $bash_path"
    fi
  else
    warning "Couldn't find a valid bash path to restore shell"
    info "💡 Hint: bash may not be installed on this system"
    info "   Current shell will remain: $SHELL"
    info "   To change manually, use: chsh -s <path-to-shell>"
  fi
}

restore_configs() {
  # If we had backups, put them back. If not, just remove our stuff.

  info "📁 Restoring configuration files..."

  # Handle .zshrc
  if [[ -f "${HOME}/.zshrc.bak" ]]; then
    info "🔄 Restoring original .zshrc from backup..."
    if mv "${HOME}/.zshrc.bak" "${HOME}/.zshrc"; then
      success "Restored .zshrc from backup"
    else
      error "Failed to restore .zshrc from backup"
      info "💡 Hint: Check file permissions"
      info "   Backup file still exists at: ${HOME}/.zshrc.bak"
    fi
  else
    if [[ -f "${HOME}/.zshrc" ]]; then
      info "🗑️  Removing deployed .zshrc (no backup found)..."
      if rm -f "${HOME}/.zshrc"; then
        success "Removed .zshrc"
      else
        error "Failed to remove .zshrc"
        info "💡 Hint: Check file permissions"
      fi
    else
      info "No .zshrc found to restore or remove"
    fi
  fi

  # Handle .p10k.zsh
  if [[ -f "${HOME}/.p10k.zsh.bak" ]]; then
    info "🔄 Restoring original .p10k.zsh from backup..."
    if mv "${HOME}/.p10k.zsh.bak" "${HOME}/.p10k.zsh"; then
      success "Restored .p10k.zsh from backup"
    else
      error "Failed to restore .p10k.zsh from backup"
      info "💡 Hint: Check file permissions"
      info "   Backup file still exists at: ${HOME}/.p10k.zsh.bak"
    fi
  else
    if [[ -f "${HOME}/.p10k.zsh" ]]; then
      info "🗑️  Removing deployed .p10k.zsh (no backup found)..."
      if rm -f "${HOME}/.p10k.zsh"; then
        success "Removed .p10k.zsh"
      else
        error "Failed to remove .p10k.zsh"
        info "💡 Hint: Check file permissions"
      fi
    else
      info "No .p10k.zsh found to restore or remove"
    fi
  fi

  # Remove per-host label metadata
  if [[ -f "${HOME}/.p10k-meta" ]]; then
    info "🗑️  Removing .p10k-meta..."
    if rm -f "${HOME}/.p10k-meta"; then
      success "Removed .p10k-meta"
    else
      error "Failed to remove .p10k-meta"
      info "💡 Hint: Check file permissions"
    fi
  fi
}

remove_oh_my_zsh() {
  local omz_dir="${HOME}/.oh-my-zsh"

  if [[ -d "$omz_dir" ]]; then
    info "🗑️  Removing ~/.oh-my-zsh (this deletes powerlevel10k theme too)..."
    if rm -rf "$omz_dir"; then
      success "Removed ~/.oh-my-zsh"
    else
      error "Failed to remove ~/.oh-my-zsh"
      info "💡 Hint: Check directory permissions"
      info "   You may need to remove it manually: rm -rf $omz_dir"
      warning "Some files may remain in ~/.oh-my-zsh"
    fi
  else
    info "~/.oh-my-zsh not found, skipping"
  fi
}

main() {
  info "🔄 Starting revoke (rollback) process..."

  restore_shell
  restore_configs
  remove_oh_my_zsh

  success "✨ Revoke complete!"
  info "📌 Next steps:"
  info "   1. Open a new terminal, or"
  info "   2. If you're still in zsh, run: exec bash"
  info ""
  warning "Note: If shell change didn't work, you may need to log out and log back in"
  success "🎉 Your system has been restored to the previous state!"
}

main "$@"
