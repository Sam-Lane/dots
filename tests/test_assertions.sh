#!/usr/bin/env bash
# Post-install assertions — run inside the Docker container after install.sh
set -euo pipefail

PASS=0
FAIL=0

pass() { echo "[PASS] $*"; ((PASS++)); }
fail() { echo "[FAIL] $*"; ((FAIL++)); }

# Make cargo binaries available if rust was installed
# shellcheck source=/dev/null
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

echo ""
echo "═══════════════════════════════════════"
echo "  Dots install assertions"
echo "═══════════════════════════════════════"

# ── Commands ─────────────────────────────────────────────────────────────────

echo ""
echo "── Commands ─────────────────────────────"

for cmd in nvim rg fzf lazygit starship go node python3 git; do
  if command -v "$cmd" &>/dev/null; then
    pass "$cmd found at $(command -v "$cmd")"
  else
    fail "$cmd not found in PATH"
  fi
done

# ── Symlinks ──────────────────────────────────────────────────────────────────

echo ""
echo "── Symlinks ─────────────────────────────"

for link in \
  "$HOME/.zshrc" \
  "$HOME/.vimrc" \
  "$HOME/.tmux.conf" \
  "$HOME/.config/nvim" \
  "$HOME/.config/starship.toml"
do
  if [[ -L "$link" ]]; then
    pass "symlink: $link -> $(readlink "$link")"
  else
    fail "missing symlink: $link"
  fi
done

# ── Neovim config loads ───────────────────────────────────────────────────────

echo ""
echo "── Neovim startup ───────────────────────"

startup_errors=$(nvim --headless +qa 2>&1 || true)
if [[ -z "$startup_errors" ]]; then
  pass "neovim starts cleanly (no errors in init.lua)"
else
  # Lazy bootstrapping prints some output on first run — only fail on E* errors
  if echo "$startup_errors" | grep -qE "^E[0-9]+:"; then
    fail "neovim startup errors: $startup_errors"
  else
    pass "neovim starts (lazy bootstrap output suppressed)"
  fi
fi

# ── Neovim provider health check ─────────────────────────────────────────────

echo ""
echo "── Neovim health check (provider) ───────"

HEALTH_LOG=$(mktemp)

# Run checkhealth for providers and write the buffer to a temp file
nvim --headless \
  -c "checkhealth provider" \
  -c "silent! w! ${HEALTH_LOG}" \
  -c "qa!" 2>/dev/null || true

if [[ -s "$HEALTH_LOG" ]]; then
  # Show the full report for visibility
  cat "$HEALTH_LOG"
  echo ""

  # Fail if any ERROR lines are present
  if grep -q "ERROR" "$HEALTH_LOG"; then
    fail "neovim provider health check has errors (see above)"
  else
    pass "neovim provider health check passed"
  fi
else
  fail "neovim health check produced no output"
fi

rm -f "$HEALTH_LOG"

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════"
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo "═══════════════════════════════════════"
echo ""

[[ $FAIL -eq 0 ]]
