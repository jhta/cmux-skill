#!/usr/bin/env bash
set -e

SKILL_DIR="$HOME/.claude/skills/cmux"
REPO="https://github.com/jhta/cmux-skill"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  cmux skill installer for Claude Code"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Homebrew ──────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "⚠️  Homebrew not found. Install it first: https://brew.sh"
  exit 1
fi

# ── Neovim ────────────────────────────────────────────────────────────────────
if ! command -v nvim &>/dev/null; then
  echo "→ Installing Neovim..."
  brew install neovim
else
  echo "✓ Neovim $(nvim --version | head -1 | awk '{print $2}')"
fi

# ── delta ─────────────────────────────────────────────────────────────────────
if ! command -v delta &>/dev/null; then
  echo "→ Installing delta..."
  brew install git-delta
else
  echo "✓ delta $(delta --version | awk '{print $2}')"
fi

# ── cmux CLI symlink ──────────────────────────────────────────────────────────
CMUX_BIN="/Applications/cmux.app/Contents/Resources/bin/cmux"
if [[ -f "$CMUX_BIN" ]]; then
  if [[ ! -f /usr/local/bin/cmux ]]; then
    echo "→ Symlinking cmux CLI..."
    sudo ln -sf "$CMUX_BIN" /usr/local/bin/cmux
  else
    echo "✓ cmux CLI already symlinked"
  fi
else
  echo "⚠️  cmux.app not found in /Applications — skipping CLI symlink."
  echo "   Download cmux at https://www.cmux.dev/ then re-run this script."
fi

# ── Clone skill ───────────────────────────────────────────────────────────────
if [[ -d "$SKILL_DIR/.git" ]]; then
  echo "→ Updating existing skill..."
  git -C "$SKILL_DIR" pull --ff-only
elif [[ -d "$SKILL_DIR" ]]; then
  echo "⚠️  $SKILL_DIR exists but is not a git repo — skipping clone."
else
  echo "→ Installing skill to $SKILL_DIR..."
  mkdir -p "$(dirname "$SKILL_DIR")"
  git clone "$REPO" "$SKILL_DIR"
fi

# ── Shell helpers (zshrc / bashrc) ────────────────────────────────────────────
SOURCE_LINE="source \$HOME/.claude/skills/cmux/scripts/cmux-helpers.sh"
SHELL_RC=""

if [[ "$SHELL" == */zsh ]]; then
  SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == */bash ]]; then
  SHELL_RC="$HOME/.bashrc"
fi

if [[ -n "$SHELL_RC" ]]; then
  if grep -qF "cmux-helpers.sh" "$SHELL_RC" 2>/dev/null; then
    echo "✓ Shell helpers already sourced in $SHELL_RC"
  else
    echo "→ Adding helpers to $SHELL_RC..."
    echo "" >> "$SHELL_RC"
    echo "# cmux skill helpers" >> "$SHELL_RC"
    echo "$SOURCE_LINE" >> "$SHELL_RC"
  fi
else
  echo "⚠️  Unknown shell — add this manually to your rc file:"
  echo "   $SOURCE_LINE"
fi

# ── Git delta config ──────────────────────────────────────────────────────────
echo "→ Configuring git to use delta..."
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.dark true
git config --global delta.side-by-side true
git config --global delta.line-numbers true
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default
echo "✓ Git delta config applied"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Done! Reload your shell to activate:"
echo "     source ${SHELL_RC:-~/.zshrc}"
echo ""
echo "  Then run Claude Code inside cmux and"
echo "  say things like:"
echo "    • \"open the code\""
echo "    • \"show me the diff\""
echo "    • \"run the tests in a new pane\""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
