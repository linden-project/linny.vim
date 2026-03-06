## Context

Current state:
- `autoload/linny_menu_util.vim` contains 9 pure utility functions
- No dependencies on other linny_menu_* modules (explicitly noted in file header)
- Functions are called from `linny_menu.vim`, `linny_menu_render.vim`, `linny_menu_items.vim`, `linny_menu_documents.vim`
- Some functions call each other internally (`calc_active_view_arrow` calls `string_of_length_with_char`, `cmdmsg` calls `slimit`)

## Goals / Non-Goals

**Goals:**
- Migrate all utility functions to Lua
- Keep all callers working via `luaeval()`
- Add unit tests for pure functions
- Extend existing `lua/linny/menu/` directory structure

**Non-Goals:**
- Migrating caller modules (separate changes)
- Changing function behavior or API

## Decisions

### 1. Module location: `lua/linny/menu/util.lua`

Extends the existing `lua/linny/menu/` directory:
```
lua/linny/menu/
  init.lua     -- exports menu submodules
  state.lua    -- state management (already done)
  util.lua     -- utility functions (this change)
```

**Rationale**: Consistent with the established `linny.menu.*` namespace.

### 2. Function naming: snake_case

| Vimscript | Lua |
|-----------|-----|
| `linny_menu_util#prepad()` | `prepad()` |
| `linny_menu_util#expand_text()` | `expand_text()` |
| `linny_menu_util#slimit()` | `slimit()` |
| `linny_menu_util#cmdmsg()` | `cmdmsg()` |
| `linny_menu_util#errmsg()` | `errmsg()` |
| `linny_menu_util#highlight()` | `highlight()` |
| `linny_menu_util#string_capitalize()` | `string_capitalize()` |
| `linny_menu_util#string_of_length_with_char()` | `string_of_length_with_char()` |
| `linny_menu_util#calc_active_view_arrow()` | `calc_active_view_arrow()` |

### 3. Use Lua string functions where possible

- `string.rep()` instead of loop for `string_of_length_with_char()`
- `string.upper()` and `string.sub()` for `string_capitalize()`
- `vim.fn.strdisplaywidth()` for display width calculations (same as Vimscript)

### 4. Use `vim.fn` for Vim-specific functions

```lua
vim.fn.strdisplaywidth(text, col)
vim.fn.strcharpart(text, start, len)
vim.fn.strchars(text)
```

**Rationale**: These functions have no pure Lua equivalent and need Vim's character handling.

### 5. Use `vim.cmd` for echo commands

```lua
vim.cmd('redraw')
vim.cmd('echohl ' .. highlight)
vim.cmd('echo ' .. vim.fn.string(content))
vim.cmd('echohl NONE')
```

**Rationale**: Direct translation of Vimscript echo commands.

### 6. Skip `expand_text()` evaluation in Lua

The `expand_text()` function evaluates `%{script}` expressions using Vimscript `eval()`. Keep using `vim.fn.eval()` for this:

```lua
local result = vim.fn.eval(script)
```

**Rationale**: These expressions are Vimscript, not Lua, so we need Vim's eval.

## Risks / Trade-offs

**[String indexing]** → Lua strings are 1-indexed, Vim strings are 0-indexed. Need careful translation of `strpart()`, `strcharpart()` calls.

**[Display width]** → Must use `vim.fn.strdisplaywidth()` for accurate width calculation with multi-byte characters.

**[Eval security]** → `expand_text()` uses eval, same security model as before.
