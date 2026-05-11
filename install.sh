#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Error: this script only supports Debian-based systems (apt-get not found)." >&2
  exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

echo "==> Installing system packages"
$SUDO apt-get update
$SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y \
  git \
  curl \
  ca-certificates \
  build-essential \
  unzip \
  fzf \
  zoxide \
  neovim \
  lua5.4 \
  luarocks

# echo "==> Installing lua packages"
# $SUDO luarocks install xml2lua

# echo "==> Installing oh-my-zsh"
# if [ ! -d "$HOME/.oh-my-zsh" ]; then
#   RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
#     sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# fi
#
#
# echo "==> Installing .zshrc"
# if [ -e "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
#   cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%s)"
# fi
# cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
#
# echo "==> Setting zsh as default shell"
# ZSH_BIN="$(command -v zsh)"
# if ! grep -qx "$ZSH_BIN" /etc/shells 2>/dev/null; then
#   echo "$ZSH_BIN" | $SUDO tee -a /etc/shells >/dev/null
# fi
# current_shell="$(getent passwd "$USER" | cut -d: -f7)"
# if [ "$(basename "$current_shell")" != "zsh" ]; then
#   $SUDO chsh -s "$ZSH_BIN" "$USER"
# fi

echo "==> Cloning neovim configuration"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
mkdir -p "$HOME/.config"
if [ -d "$NVIM_CONFIG_DIR" ]; then
  mv "$NVIM_CONFIG_DIR" "${NVIM_CONFIG_DIR}.bak.$(date +%s)"
fi
git clone git@github.com:serzhby/nvim.git "$NVIM_CONFIG_DIR"

echo "==> Done. Start a new shell or run: exec zsh"
