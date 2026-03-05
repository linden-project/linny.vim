## Context

Vim plugins have a specific load order: `plugin/` files load at startup, while `autoload/` files load lazily when their functions are first called. Two variables are accessed before initialization:

1. `g:linnycfg_setup_autocommands` - used in `plugin/linny.vim` before autoload is loaded
2. `g:linny_wikitags_register` - used in `linny#RegisterLinnyWikitag()` before `linny#Init()` is called

## Goals / Non-Goals

**Goals:**
- Fix all startup errors
- Preserve user's ability to override defaults in their vimrc

**Non-Goals:**
- Restructure the entire configuration system
- Change default behavior

## Decisions

### Decision 1: Use `get()` with default value

For all variables that may be accessed before initialization, use `get(g:, 'varname', default)`.

This approach:
- Provides a default value inline
- Respects user overrides set before plugin load
- Requires minimal code change
- Is idiomatic Vimscript

### Decision 2: Initialize wikitags register in RegisterLinnyWikitag

Add initialization at the start of `linny#RegisterLinnyWikitag()`:
```vim
let g:linny_wikitags_register = get(g:, 'linny_wikitags_register', {})
```

This ensures the dict exists before `has_key()` is called.
