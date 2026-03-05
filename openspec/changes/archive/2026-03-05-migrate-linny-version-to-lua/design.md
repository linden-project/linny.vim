## Context

Linny.vim currently uses Vimscript exclusively. The goal is to migrate to Lua for better maintainability and Neovim-native performance. The `linny_version#PluginVersion()` function is the simplest starting point - it just returns a string.

Current state:
- `autoload/linny_version.vim` contains a single function returning `'0.8.0'`
- Called by `linny_menu.vim` for footer display
- Tested by `linny_spec.lua` via `vim.fn` bridge
- `Rakefile` greps this file for version bumps

## Goals / Non-Goals

**Goals:**
- Establish `lua/linny/` module structure for future migrations
- Prove the migration pattern works end-to-end
- Update all callers to use Lua directly
- Remove the Vimscript file entirely

**Non-Goals:**
- Vim compatibility (Lua requires Neovim)
- Migrating other functions in this change
- Changing the version number itself

## Decisions

### 1. Module structure: `lua/linny/` with `init.lua`

Use standard Lua module pattern with `require('linny')` as entry point.

```
lua/
  linny/
    init.lua      -- module entry, re-exports submodules
    version.lua   -- version function
```

**Rationale**: This is the idiomatic Neovim plugin structure. Using `linny/` subdirectory allows `require('linny')` and `require('linny.version')` patterns.

**Alternative considered**: Flat `lua/linny.lua` - rejected because it doesn't scale for future migrations.

### 2. Vimscript caller update: use `luaeval()`

Update `linny_menu.vim` to call Lua via:
```vim
luaeval("require('linny.version').plugin_version()")
```

**Rationale**: `luaeval()` is the standard way to call Lua from Vimscript in Neovim. It's available in all supported Neovim versions.

**Alternative considered**: `v:lua.require()` - works but `luaeval()` is more readable for string returns.

### 3. Test update: use `require()` directly

Tests already run in Lua context, so use:
```lua
local version = require('linny.version').plugin_version()
```

**Rationale**: Direct Lua call is cleaner than going through `vim.fn` bridge.

### 4. Rakefile update: grep new file location

Change version grep from `autoload/linny_version.vim` to `lua/linny/version.lua`.

**Rationale**: Straightforward path update to match new file location.

## Risks / Trade-offs

**[Vim compatibility dropped]** → This change makes Linny Neovim-only. Acceptable since Lua migration is the goal and Vim users are not a target audience.

**[Breaking change for external callers]** → Anyone calling `linny_version#PluginVersion()` will break. Mitigated: this is an internal function, not a public API.
