## Context

Current state:
- `autoload/linny_menu.vim` is 2669 lines with ~90 functions
- 22 script-local functions (`s:`) that are "private"
- 14 tab-local variables (`t:`) for per-tab menu state
- Functions are tightly coupled but have logical groupings

## Goals / Non-Goals

**Goals:**
- Split into ~10 smaller, focused modules
- Convert all `s:` functions to public autoload functions
- Preserve tab-local state behavior
- Maintain identical functionality

**Non-Goals:**
- Lua conversion (separate changes)
- Adding unit tests (during Lua conversion)
- Refactoring logic or changing behavior

## Decisions

### 1. Module structure

| Module | Responsibility | Key functions |
|--------|----------------|---------------|
| `linny_menu_state` | Tab state (`t:` vars), init | `tabInitState`, getters/setters |
| `linny_menu_window` | Buffer/window management | `Window_*`, `open`, `close`, `toggle` |
| `linny_menu_items` | Menu item construction | `add_item_*`, `item_default`, `list` |
| `linny_menu_render` | Menu level rendering | `menu_level0/1/2`, `render_view`, partials |
| `linny_menu_views` | View cycling/selection | `cycle_l*_view`, `dropdown_l*_view`, `get_views*` |
| `linny_menu_widgets` | Dashboard widgets | `widget_*` |
| `linny_menu_keymaps` | Keyboard handling | `Setup_keymaps`, `Set_cursor`, `RemapGlobal*` |
| `linny_menu_actions` | Content actions | `dropdown_item`, `exec_content_menu`, SID handlers |
| `linny_menu_documents` | Document operations | `copy_document`, `new_document_in_leaf`, config |
| `linny_menu_util` | Utilities | `string_capitalize`, `Slimit`, `PrePad`, etc. |

### 2. Function renaming pattern

Script-local functions become public with module prefix:

```vim
" Before (in linny_menu.vim)
function! s:add_item_document(...)

" After (in linny_menu_items.vim)
function! linny_menu_items#add_item_document(...)
```

### 3. Tab-local state handling

Keep all `t:linny_menu_*` variables. Access patterns:
- Direct access remains (e.g., `let t:linny_menu_taxonomy = "foo"`)
- No wrapper functions needed for this refactor
- State centralization can happen during Lua conversion

### 4. Backward compatibility via linny_menu.vim

Keep a minimal `linny_menu.vim` that re-exports commonly called functions:

```vim
" autoload/linny_menu.vim (compatibility shim)
function! linny_menu#start()
  return linny_menu_window#start()
endfunction

function! linny_menu#open()
  return linny_menu_window#open()
endfunction
" ... etc for public API
```

This ensures external callers (plugin/linny.vim, etc.) don't need changes.

### 5. Internal helper functions

Some functions are only used internally. These stay public but are clearly internal:
- `Window_exist()` → `linny_menu_window#exist()`
- `Window_close()` → `linny_menu_window#close_window()`
- `NewLinnyTabNr()` → `linny_menu_state#new_tab_nr()`

### 6. SID function handling

`<SID>` functions (like `<SID>linny_menu_enter()`) are special - they're referenced in mappings. Options:
- Keep in keymaps module with `<SID>` prefix
- Reference via `<SNR>` or script number

For simplicity, keep them in `linny_menu_keymaps.vim` with `<SID>` prefix.

## Risks / Trade-offs

**[Many call sites]** → ~200+ internal function calls need updating. Mitigate with careful grep and search-replace.

**[Testing without unit tests]** → Manual testing required. Test each menu level, navigation, actions.

**[SID mappings]** → Need to ensure keymaps still work after split. Test keyboard shortcuts.

## Execution Order

1. Create all new empty module files
2. Move utility functions first (no dependencies)
3. Move state functions
4. Move items functions
5. Move window functions
6. Move render functions (depends on items, state)
7. Move views functions
8. Move widgets functions
9. Move keymaps functions
10. Move actions functions
11. Move documents functions
12. Create compatibility shim in linny_menu.vim
13. Delete original content from linny_menu.vim
14. Test thoroughly
