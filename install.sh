#!/usr/bin/env bash
#
# install.sh
# ----------
# One-command installer for HRL GOD's Command Line For Antigravity
#

set -euo pipefail

echo "==================================================================="
echo "     ⚡ Installing HRL GOD's Command Line For Antigravity ⚡       "
echo "==================================================================="

INSTALL_DIR="${HOME}/.hrl-god"
BIN_DIR="${HOME}/.local/bin"

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

# Copy files
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -R "$REPO_ROOT"/* "$INSTALL_DIR/"

# Make scripts executable
chmod +x "$INSTALL_DIR/bin/hrl-god"
chmod +x "$INSTALL_DIR/hrl_god_cli.py"
chmod +x "$INSTALL_DIR/scripts/"*.py 2>/dev/null || true
chmod +x "$INSTALL_DIR/scripts/"*.sh 2>/dev/null || true
chmod +x "$INSTALL_DIR/scripts/"*.swift 2>/dev/null || true

# Symlink to ~/.local/bin/hrl-god
ln -sf "$INSTALL_DIR/bin/hrl-god" "$BIN_DIR/hrl-god"

echo "[✓] Successfully installed to $INSTALL_DIR"
echo "[✓] Executable linked to $BIN_DIR/hrl-god"

# Shell PATH guidance
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo ""
    echo "[!] Notice: $BIN_DIR is not in your current PATH."
    echo "    Add this line to your ~/.zshrc or ~/.bash_profile:"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo ""
echo "[*] You can now run:"
echo "    hrl-god --help"
echo "    hrl-god organize"
echo "==================================================================="
