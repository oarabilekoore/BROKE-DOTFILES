#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/configs"

info() { echo -e "\e[32m[INFO]\e[0m $*"; }
error() { echo -e "\e[31m[ERROR]\e[0m $*" >&2; }

# 1. Install official packages
info "Installing pacman packages..."
if [[ -f "$SCRIPT_DIR/pkglist-pacman.txt" ]]; then
  sudo pacman -Syu --needed - <"$SCRIPT_DIR/pkglist-pacman.txt"
else
  error "pkglist-pacman.txt not found."
fi

# 2. Bootstrap yay if missing
if ! command -v yay >/dev/null 2>&1; then
  info "yay not found. Installing yay..."
  sudo pacman -S --needed base-devel git
  git clone https://aur.archlinux.org/yay.git /tmp/yay-install
  cd /tmp/yay-install
  makepkg -si --noconfirm
  rm -rf /tmp/yay-install
  cd "$SCRIPT_DIR"
fi

# 3. Install AUR packages
info "Installing yay packages..."
if [[ -f "$SCRIPT_DIR/pkglist-yay.txt" ]]; then
  yay -S --needed - <"$SCRIPT_DIR/pkglist-yay.txt"
else
  error "pkglist-yay.txt not found."
fi

# 4. Install Flatpak packages
info "Installing flatpak packages..."
if [[ -s "$SCRIPT_DIR/pkglist-flatpak.txt" ]]; then
  if ! command -v flatpak >/dev/null 2>&1; then
    info "flatpak not found. Installing flatpak via pacman..."
    sudo pacman -S --needed --noconfirm flatpak
  fi
  info "Adding Flathub remote..."
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  info "Installing flatpak apps..."
  xargs -r -a "$SCRIPT_DIR/pkglist-flatpak.txt" flatpak install -y flathub
else
  info "pkglist-flatpak.txt not found or empty. Skipping."
fi

# 5. Restore configurations
info "Restoring configuration files..."
if [[ -d "$BACKUP_DIR" ]]; then
  # The /. ensures hidden files like .config and .bashrc are copied
  cp -a "$BACKUP_DIR/." "$HOME/"
  info "Configurations pushed to $HOME."
else
  error "Config backup directory not found."
fi

# 6. Run system patches
PATCH_SCRIPT="$SCRIPT_DIR/.patches.sh"
if [[ -f "$PATCH_SCRIPT" ]]; then
  info "Executing system patches..."
  bash "$PATCH_SCRIPT"
fi

info "Installation sequence complete."
