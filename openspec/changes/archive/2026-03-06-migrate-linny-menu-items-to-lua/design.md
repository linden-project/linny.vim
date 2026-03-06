## Context

The linny.vim plugin is migrating from VimScript to Lua. Two modules have been successfully converted: `linny_menu_state.vim` and `linny_menu_util.vim`. The `linny_menu_items.vim` module is next in line - it contains 16 functions for constructing menu item data structures.

Key insight from previous migrations: Lua empty tables `{}` convert to Vim Lists, not Dictionaries. Must use `vim.empty_dict()` when returning empty dictionaries to VimScript callers.

## Goals / Non-Goals

**Goals:**
- Convert all 16 functions from `linny_menu_items.vim` to Lua
- Maintain exact behavioral compatibility with existing VimScript callers
- Follow established patterns from state.lua and util.lua migrations
- Add comprehensive unit tests

**Non-Goals:**
- Refactoring the menu item data structure
- Converting the caller files (linny_menu_render.vim, etc.) to Lua
- Performance optimization
- Adding new functionality

## Decisions

### 1. Module Location: `lua/linny/menu/items.lua`

Following the established pattern of `lua/linny/menu/{state,util}.lua`.

### 2. Tab-local State Access via `vim.t`

The module uses `t:linny_menu_items` for storing menu items. Lua accesses this via `vim.t.linny_menu_items`.

**Challenge**: The `append()` function modifies `t:linny_menu_items` in place. In Lua, we must be careful about table references.

**Decision**: Use direct assignment back to `vim.t.linny_menu_items` after modifications to ensure the tab-local variable is updated.

### 3. Item Structure as Lua Table

The VimScript item dictionary maps directly to a Lua table:
```lua
local item = {
  mode = 1,        -- 0=option, 1=text, 2=section, 3=heading, 4=footer
  event = '',
  text = '',
  option_type = '',
  option_data = {},
  key = '',
  weight = 0,
  help = ''
}
```

### 4. Calling Lua Functions from VimScript

Use `luaeval()` with `_A` parameter passing:
```vim
" No parameters:
call luaeval("require('linny.menu.items').add_empty_line()")

" With parameters:
call luaeval("require('linny.menu.items').add_document(_A[1], _A[2], _A[3], _A[4])", [a:title, a:abs_path, a:keyboard_key, a:type])
```

### 5. VimScript Callbacks from Lua

Functions like `add_document_taxo_key` call other VimScript functions (e.g., `linny#parse_json_file`). Use `vim.fn[]`:
```lua
local files_in_menu = vim.fn['linny#parse_json_file'](filepath, {})
```

## Risks / Trade-offs

**Risk**: Table reference issues with `vim.t.linny_menu_items`
→ Mitigation: Test thoroughly that modifications persist correctly

**Risk**: Empty dictionary/list conversion issues (learned from state.lua bug)
→ Mitigation: Use `vim.empty_dict()` for `option_data` field in `item_default()`

**Trade-off**: Slightly more verbose VimScript call sites with `luaeval()`
→ Acceptable: This is temporary until callers are also migrated to Lua
