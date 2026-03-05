# Linny Development Environment

Isolated NixVim setup for rewriting linny.vim to Lua.

## Quick Start

```bash
cd /home/pim/cLinden/linny-dev

# Enter the development shell
nix develop

# Start neovim
nvim

# Or start with Linny menu
nvim -c 'LinnyStart'
```

## Instant Changes

The plugin is loaded directly from `/home/pim/cLinden/linny.vim` at runtime.
**All file changes take effect immediately** - no rebuild needed!

- **Vimscript changes**: Press `<Space>rr` to reload, or restart nvim
- **Lua changes**: Press `<Space>rr` (clears module cache and reloads)

## Running Tests

```bash
# Inside nix develop, run headless
nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

# Or inside neovim interactively
<Space>rt
```

## Included Tools

- `nvim` - Configured Neovim with linny loaded
- `lua-language-server` - LSP for Lua development (type checking)
- `stylua` - Lua code formatter

## Directory Structure

```
linny-dev/
├── flake.nix           # NixVim configuration
├── tests/
│   ├── minimal_init.lua
│   └── linny_spec.lua  # Test files
└── .gitignore

/home/pim/cLinden/linny.vim/   # Source (edit here!)
├── lua/linny/                 # New Lua code (create this)
├── plugin/
├── autoload/
└── ...
```

## Workflow for Lua Rewrite

1. Create `lua/linny/` directory in linny.vim
2. Write Lua module (e.g., `lua/linny/wiki.lua`)
3. Test immediately in this environment
4. Run tests with `<Space>rt`
5. Gradually replace autoload functions with Lua equivalents
