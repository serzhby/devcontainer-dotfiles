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
  zsh \
  git \
  curl \
  ca-certificates \
  build-essential \
  unzip \
  fzf \
  zoxide \
  zsh-autosuggestions \
  zsh-syntax-highlighting

echo "==> Installing oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "==> Installing neovim"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  NVIM_DIR="nvim-linux-x86_64" ;;
  aarch64) NVIM_DIR="nvim-linux-arm64" ;;
  *)       echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac
NVIM_TARBALL="${NVIM_DIR}.tar.gz"
TMP_TGZ="$(mktemp --suffix=.tar.gz)"
trap 'rm -f "$TMP_TGZ"' EXIT
curl -fsSL -o "$TMP_TGZ" \
  "https://github.com/neovim/neovim/releases/latest/download/${NVIM_TARBALL}"
$SUDO rm -rf "/opt/${NVIM_DIR}"
$SUDO tar -C /opt -xzf "$TMP_TGZ"
$SUDO ln -sf "/opt/${NVIM_DIR}/bin/nvim" /usr/local/bin/nvim

echo "==> Installing .zshrc"
if [ -e "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%s)"
fi
cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

echo "==> Cloning neovim configuration"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
mkdir -p "$HOME/.config"
if [ -d "$NVIM_CONFIG_DIR" ]; then
  mv "$NVIM_CONFIG_DIR" "${NVIM_CONFIG_DIR}.bak.$(date +%s)"
fi
git clone git@github.com-serzhby:serzhby/nvim.git "$NVIM_CONFIG_DIR"

echo "==> Setting zsh as default shell"
ZSH_BIN="$(command -v zsh)"
if ! grep -qx "$ZSH_BIN" /etc/shells 2>/dev/null; then
  echo "$ZSH_BIN" | $SUDO tee -a /etc/shells >/dev/null
fi
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_BIN" ]; then
  $SUDO chsh -s "$ZSH_BIN" "$USER"
fi

echo "==> Done. Start a new shell or run: exec zsh"
