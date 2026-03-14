# cmux Skill for Claude Code

A [Claude Code](https://claude.ai/claude-code) skill for managing [cmux](https://www.cmux.dev/) panels during software development — open files in Neovim, view git diffs with delta, and run commands in split panes, all by talking to Claude.

## What it does

Say things like:

| You say | What happens |
|---|---|
| "open the code" | Claude finds the relevant file and opens it in `nvim` in a right panel |
| "show me the diff" | Opens `git diff` in a bottom panel (rendered by delta) |
| "run the tests in a new pane" | Runs your test command in a split panel |
| "start the dev server" | Opens a right panel with your dev server running |
| "open both files side by side" | Two `nvim` panels side by side |

## Requirements

- [cmux](https://www.cmux.dev/) (native macOS terminal)
- [Neovim](https://neovim.io/) (`brew install neovim`)
- [delta](https://dandavison.github.io/delta/) for pretty diffs (`brew install git-delta`)
- Claude Code running inside a cmux workspace

## Installation

### 1. Clone into your Claude skills directory

```bash
git clone https://github.com/jhta/cmux-skill ~/.claude/skills/cmux
```

### 2. Symlink the cmux CLI (if not done yet)

```bash
sudo ln -sf "/Applications/cmux.app/Contents/Resources/bin/cmux" /usr/local/bin/cmux
```

### 3. (Optional) Source the helper functions in your shell

Add to `~/.zshrc` or `~/.bashrc`:

```bash
source ~/.claude/skills/cmux/scripts/cmux-helpers.sh
```

This gives you `cmux-split`, `cmux-vim`, `cmux-diff`, `cmux-show`, etc. directly in your terminal.

### 4. Enable socket access in cmux

cmux Settings → Security → Socket API → set to **"cmux processes only"** (default).

### 5. Run Claude Code from inside cmux

This ensures `CMUX_SOCKET_PATH`, `CMUX_WORKSPACE_ID`, and `CMUX_SURFACE_ID` are set so Claude can control your panels.

## Shell helpers

Once sourced, you can also use these directly in your terminal:

```bash
cmux-split right "nvim src/index.ts"   # open file in right panel
cmux-vim src/components/Button.tsx     # shorthand for nvim in right panel
cmux-diff                              # git diff in bottom panel
cmux-diff-staged                       # staged diff
cmux-show abc1234                      # show a commit
cmux-run "npm test"                    # run command, keep panel open after
cmux-tail logs/app.log                 # tail a log file
cmux-done "Build complete"             # send a macOS notification
```

## How splits work

cmux CLI pattern (two steps):

```bash
# 1. Create the split — returns "OK surface:3 workspace:1"
cmux new-split right

# 2. Send a command to that surface (trailing newline executes it)
cmux send --surface surface:3 "nvim src/index.ts
"
```

The `cmux-split` helper wraps both steps into one call.

## Delta git config

For best diff output, configure delta as your git pager:

```bash
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.dark true
git config --global delta.side-by-side true
git config --global delta.line-numbers true
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default
```

## File structure

```
cmux/
├── SKILL.md                  # Main skill definition (auto-loaded by Claude Code)
├── references/
│   └── socket-api.md         # Full cmux socket API reference
└── scripts/
    └── cmux-helpers.sh       # Bash helper functions
```
