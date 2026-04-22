#!/usr/bin/env bash
# One-shot setup for macOS, Debian/Ubuntu, and Arch Linux — safe to re-run
# curl -fsSL https://raw.githubusercontent.com/Sam-Lane/dots/main/install.sh | bash
set -euo pipefail

DOTS_DIR="$HOME/dots"
DOTS_REPO="https://github.com/Sam-Lane/dots.git"

# ── Helpers ───────────────────────────────────────────────────────────────────

info()    { echo "[info]  $*"; }
success() { echo "[ok]    $*"; }
error()   { echo "[error] $*" >&2; exit 1; }

have() { command -v "$1" &>/dev/null; }

# ── Platform detection ────────────────────────────────────────────────────────

detect_platform() {
  case "$(uname -s)" in
    Darwin)
      OS="macos"
      ;;
    Linux)
      if [[ -f /etc/arch-release ]]; then
        OS="arch"
      elif [[ -f /etc/debian_version ]]; then
        OS="debian"
      else
        error "Unsupported Linux distro. Only Arch and Debian/Ubuntu are supported."
      fi
      ;;
    *)
      error "Unsupported OS: $(uname -s)"
      ;;
  esac
  info "Detected OS: $OS ($(uname -m))"
}

# ── macOS ─────────────────────────────────────────────────────────────────────

install_macos() {
  # Homebrew — handles both Apple Silicon (/opt/homebrew) and Intel (/usr/local)
  if ! have brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    success "Homebrew already installed"
  fi

  local pkgs=(
    neovim
    zsh tmux
    ripgrep fzf lazygit
    node python3 go
    php composer        # LSP: phpactor
    terraform           # LSP: terraformls
    starship
    git wget curl
  )

  for pkg in "${pkgs[@]}"; do
    if brew list "$pkg" &>/dev/null 2>&1; then
      success "$pkg already installed"
    else
      info "Installing $pkg..."
      brew install "$pkg"
    fi
  done

  # Neovim providers
  pip3 install --quiet pynvim
  npm install -g neovim --silent
}

# ── Debian / Ubuntu ───────────────────────────────────────────────────────────

install_debian() {
  # sudo strips env vars by default, so pass DEBIAN_FRONTEND inline on every
  # apt-get call rather than relying on the inherited environment.
  local APT="sudo DEBIAN_FRONTEND=noninteractive apt-get"

  info "Updating package lists..."
  $APT update -qq

  # Neovim: the default apt package is often too old (0.6.x).
  # Use the unstable PPA to get a recent stable release.
  if ! have nvim; then
    info "Adding neovim PPA for latest stable release..."
    $APT install -y software-properties-common
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    $APT update -qq
  fi

  local pkgs=(
    neovim
    zsh tmux
    ripgrep fzf
    nodejs npm
    python3 python3-pip
    golang
    php composer        # LSP: phpactor
    lsb-release         # used below for terraform repo
    build-essential     # required for telescope-fzf-native (needs make + cc)
    git wget curl
  )

  info "Installing apt packages..."
  $APT install -y "${pkgs[@]}"

  # Terraform — HashiCorp apt repo
  if ! have terraform; then
    info "Installing terraform..."
    local codename
    codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"
    wget -O- https://apt.releases.hashicorp.com/gpg \
      | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com ${codename} main" \
      | sudo tee /etc/apt/sources.list.d/hashicorp.list
    $APT update -qq
    $APT install -y terraform
  else
    success "terraform already installed"
  fi

  # Lazygit — not in apt, pull latest release from GitHub
  if ! have lazygit; then
    info "Installing lazygit..."
    local version
    version="$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
      | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')"
    local lg_arch
    case "$(uname -m)" in
      x86_64)  lg_arch="Linux_x86_64" ;;
      aarch64) lg_arch="Linux_arm64" ;;
      *) error "Unsupported arch for lazygit: $(uname -m)" ;;
    esac
    curl -Lo /tmp/lazygit.tar.gz \
      "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_${lg_arch}.tar.gz"
    sudo tar -xzf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit
    rm /tmp/lazygit.tar.gz
  else
    success "lazygit already installed"
  fi

  # Starship — not in apt
  if ! have starship; then
    info "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
  else
    success "starship already installed"
  fi

  # Neovim providers
  pip3 install --quiet pynvim
  npm install -g neovim --silent
}

# ── Arch Linux ────────────────────────────────────────────────────────────────

install_arch() {
  info "Syncing package databases..."
  sudo pacman -Sy --noconfirm

  local pkgs=(
    neovim
    zsh tmux
    ripgrep fzf lazygit
    nodejs npm
    python python-pip python-pynvim  # python-pynvim = neovim provider
    go
    php composer        # LSP: phpactor
    terraform           # LSP: terraformls
    starship
    base-devel          # required for telescope-fzf-native (needs make + cc)
    git wget curl
  )

  info "Installing pacman packages..."
  sudo pacman -S --noconfirm --needed "${pkgs[@]}"

  # Neovim node provider
  npm install -g neovim --silent
}

# ── Rust (all platforms) ──────────────────────────────────────────────────────

install_rust() {
  if ! have rustup; then
    info "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
  else
    success "Rust already installed"
  fi
}

# ── Dots repo ─────────────────────────────────────────────────────────────────

clone_dots() {
  if [[ -d "$DOTS_DIR/.git" ]]; then
    # Skip pull if there is no remote (e.g. local dev / Docker test environment)
    if git -C "$DOTS_DIR" remote get-url origin &>/dev/null 2>&1; then
      info "Dots repo already cloned, pulling latest..."
      git -C "$DOTS_DIR" pull --ff-only
    else
      info "Dots dir exists with no remote, skipping pull..."
    fi
  else
    info "Cloning dots repo to $DOTS_DIR..."
    git clone "$DOTS_REPO" "$DOTS_DIR"
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

detect_platform

case "$OS" in
  macos)  install_macos ;;
  debian) install_debian ;;
  arch)   install_arch ;;
esac

install_rust
clone_dots

info "Setting up config symlinks..."
bash "$DOTS_DIR/config_setup.sh"

echo ""
echo "Setup complete. Open a new terminal or run: source ~/.zshrc"
echo "Then open nvim — lazy.nvim will install plugins on first launch."
