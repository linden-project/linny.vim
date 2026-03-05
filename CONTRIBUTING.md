# Contributing Guide

A complete contribution guideline needs to be written. For now:

- Please be polite
- One fix per PR
- One addition per PR
- Give enought information in issues

## Developer Environment with Nix

The project includes a Nix flake that provides a complete, isolated development environment with a preconfigured Neovim.

### Prerequisites

- [Nix](https://nixos.org/download/) with flakes enabled

To enable flakes, add to `~/.config/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

### Getting Started

Enter the development shell:
```bash
nix develop
```

This gives you:
- **Neovim** with linny.vim loaded from source (live reload enabled)
- **lua-language-server** for Lua LSP support
- **stylua** for code formatting
- **Plenary** for running tests
- **Treesitter** with all grammars

### Usage

Start Neovim:
```bash
nvim
```

Or start directly with the Linny menu:
```bash
nvim -c 'LinnyStart'
```

### Keymaps

Inside Neovim:
- `<Space>rr` - Reload linny (clears Lua cache, re-sources files)
- `<Space>rt` - Run plenary tests

### Alternative: Run Without Shell

You can also run the configured Neovim directly without entering the shell:
```bash
nix run
```

### Notes

- The environment is fully isolated using separate XDG directories (`.dev/`)
- Changes to plugin source files take effect after using `<Space>rr` to reload
- Your regular Neovim configuration is not affected
