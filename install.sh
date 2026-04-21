#!/usr/bin/env bash
set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
    local src="$DOTS_DIR/$1"
    local dst="$2"

    mkdir -p "$(dirname "$dst")"

    if [[ -e "$dst" && ! -L "$dst" ]]; then
        echo "  backing up $dst -> $dst.bak"
        mv "$dst" "$dst.bak"
    fi

    ln -sf "$src" "$dst"
    echo "  linked $dst -> $src"
}

echo "Installing dotfiles from $DOTS_DIR"

link zshrc       "$HOME/.zshrc"
link vimrc       "$HOME/.vimrc"
link tmux.conf   "$HOME/.tmux.conf"
link helpers.sh  "$HOME/.local/bin/helpers.sh"  # sourced by zshrc, not executed directly

echo "Done."
