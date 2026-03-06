## Context

Current state:
- `autoload/linny_menu_state.vim` contains 7 functions for tab state management
- Tab-local variables (`t:linny_menu_*`) track per-tab menu state
- Global variable `g:linnytabnr` provides unique tab numbering
- Functions depend on `linny#l1_state_filepath()`, `linny#l2_state_filepath()`, `linny#parse_json_file()`, `linny#write_json_file()` from `autoload/linny.vim`
- Called from `linny_menu.vim`, `linny_menu_render.vim`, `linny_menu_window.vim`, `linny_menu_views.vim`

## Goals / Non-Goals

**Goals:**
- Migrate all state functions to Lua
- Maintain tab-local state using `vim.t`
- Keep all callers working via `luaeval()`
- Add unit tests for testable functions
- Establish `lua/linny/menu/` directory structure for future menu module migrations

**Non-Goals:**
- Migrating `linny#parse_json_file()` or `linny#write_json_file()` (stay in linny.vim)
- Migrating other linny_menu_*.vim files (separate changes)
- Changing the state file format or paths

## Decisions

### 1. Module location: `lua/linny/menu/state.lua`

Create a `menu` subdirectory to organize menu-related modules:
```
lua/linny/
  menu/
    init.lua     -- exports menu submodules
    state.lua    -- state management (this change)
```

**Rationale**: Prepares for migrating other `linny_menu_*.vim` files. The `linny_menu_*` namespace maps to `linny.menu.*` in Lua.

### 2. Use `vim.t` for tab-local variables

```lua
vim.t.linny_menu_items = {}
vim.t.linny_menu_cursor = 0
```

**Rationale**: `vim.t` is the standard Neovim API for tab-local variables, directly equivalent to Vimscript's `t:` scope.

### 3. Use `vim.g` for global tab counter

```lua
vim.g.linnytabnr = vim.g.linnytabnr + 1
```

**Rationale**: Maintains compatibility with existing Vimscript code that may read `g:linnytabnr`.

### 4. Use `vim.fn[]` for Vimscript callbacks

```lua
local filepath = vim.fn['linny#l1_state_filepath'](term)
local state = vim.fn['linny#parse_json_file'](filepath, {})
vim.fn['linny#write_json_file'](filepath, state)
```

**Rationale**: The `linny#` functions in `autoload/linny.vim` are not yet migrated to Lua. Using `vim.fn[]` allows calling them from Lua. This will be simplified when those functions are migrated.

### 5. Update callers via `luaeval()`

```vim
" Before
call linny_menu_state#tab_init()

" After
call luaeval("require('linny.menu.state').tab_init()")
```

**Rationale**: Consistent with how other migrated modules are called. Keeps Vimscript callers working without modification to their logic.

### 6. Function naming: snake_case

| Vimscript | Lua |
|-----------|-----|
| `linny_menu_state#tab_init()` | `tab_init()` |
| `linny_menu_state#new_tab_nr()` | `new_tab_nr()` |
| `linny_menu_state#term_leaf_state()` | `term_leaf_state()` |
| `linny_menu_state#term_value_leaf_state()` | `term_value_leaf_state()` |
| `linny_menu_state#write_term_leaf_state()` | `write_term_leaf_state()` |
| `linny_menu_state#write_term_value_leaf_state()` | `write_term_value_leaf_state()` |
| `linny_menu_state#reset()` | `reset()` |

**Rationale**: Follows existing Lua module conventions in the codebase.

## Risks / Trade-offs

**[Vimscript dependencies]** → Functions still depend on `linny#` Vimscript functions. This will be resolved when those are migrated to Lua.

**[Tab variable initialization order]** → `tab_init()` must be called before accessing `vim.t.linny_menu_*` variables. Same constraint as current Vimscript implementation.

**[Global state mutation]** → `new_tab_nr()` mutates `vim.g.linnytabnr`. This is intentional to maintain unique numbering across tabs.
