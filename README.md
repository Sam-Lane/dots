# dots

My personal dotfiles — a zero-config macOS / Linux setup that installs packages, links configs, and bootstraps a complete dev environment.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/Sam-Lane/dots/main/install.sh | bash
```

Or clone and run manually:

```sh
git clone https://github.com/Sam-Lane/dots.git ~/dots && cd ~/dots
bash install.sh
```

Supported platforms: macOS (Homebrew), Debian/Ubuntu, Arch Linux.

## What it does

| Category | Details |
|---|---|
| **Shell** | Zsh with [Starship](https://starship.rs) prompt |
| **Editor** | Neovim (lazy.nvim plugin manager, LSP, treesitter, telescope, Copilot) |
| **Terminal** | Tmux with TPM and custom keybindings |
| **Languages** | Node.js, Python, Go, PHP, Rust, Terraform |
| **CLI tools** | ripgrep, fzf, lazygit, jq, wget, curl |
| **AI tooling** | Claude Code (`claude-code` CLI + skills/agents/commands) |
| **Config symlinks** | `~/.zshrc`, `~/.vimrc`, `~/.tmux.conf`, `starship.toml`, Neovim, Claude config |

The installer is idempotent and safe to re-run — it skips anything already installed.

## After install

1. Open a new terminal (or `source ~/.zshrc`)
2. Run `nvim` — lazy.nvim installs plugins on first launch
3. Done.
