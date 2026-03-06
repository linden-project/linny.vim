# Proposal: Split linny_menu.vim Phase 2

## Problem

After the initial split of `linny_menu.vim` (from 2669 to 1358 lines), the main file still contains several distinct concerns that could be further modularized:

1. **Document operations** (~115 lines) - Creating, copying, archiving documents and configs
2. **Dropdown actions** (~200 lines) - Context menu actions and callbacks
3. **Popup/floating window** (~290 lines) - Vim popup / Neovim floating window abstraction

These are currently mixed together, making future Lua conversion harder and the code difficult to navigate.

## Proposed Solution

Extract three additional modules from `linny_menu.vim`:

### 1. linny_menu_documents.vim (~115 lines)
Document and config file operations:
- `linny_menu#copy_document()`
- `linny_menu#new_document_in_leaf()`
- `linny_menu#open_document_in_right_pane()`
- `linny_menu#replace_key_value_in_root_frontmatter_filelines()`
- `linny_menu#archiveL2config()`
- `s:createl2config()` → `linny_menu_documents#create_l2_config()`

### 2. linny_menu_actions.vim (~200 lines)
Dropdown menu actions and callbacks:
- `linny_menu#dropdown_item()`
- `linny_menu#dropdown_item_callcack()`
- `linny_menu#dropdown_taxo_item_callcack()`
- `linny_menu#dropdown_remove_taxo_item_callcack()`
- `linny_menu#dropdown_term_item_callcack()`
- `linny_menu#exec_content_menu()`

### 3. linny_menu_popup.vim (~290 lines)
Popup/floating window abstraction layer:
- `linny_menu#create_popup()` → `linny_menu_popup#create()`
- `linny_menu#close_pop()` → `linny_menu_popup#close()`
- `linny_menu#getoptions()` → `linny_menu_popup#getoptions()`
- `linny_menu#setoptions()` → `linny_menu_popup#setoptions()`
- All neovim-specific helper functions (`s:floatwin`, `s:options`, `s:draw_box`, etc.)

**Key change**: Refactor away from `finish` statements by using internal `if has('nvim')` checks.

## Technical Challenges

### 1. The `finish` Statement Pattern
Current code uses:
```vim
if !has('nvim')
    finish
endif
" neovim-only code
```

**Solution**: Move to internal conditionals:
```vim
function! linny_menu_popup#create(what, options) abort
    if has('popupwin')
        return popup_create(a:what, a:options)
    elseif has('nvim')
        return s:floatwin(s:to_list(a:what), s:options(#{}, a:options))
    endif
endfunction
```

### 2. Script-local Functions in Popup
The neovim popup implementation uses many `s:` helper functions. These can stay as `s:` in the new file since they're only called internally.

### 3. Callback References
Dropdown callbacks are referenced by string name in popup options:
```vim
callback: 'linny_menu#dropdown_item_callcack'
```
These string references need to be updated to the new module names.

### 4. Tab-local Variable Access
Document operations access `t:linny_menu_lastmaxsize` for window sizing. This is fine - tab variables are global within the tab.

## Expected Outcome

| File | Before | After | Change |
|------|--------|-------|--------|
| linny_menu.vim | 1358 | ~750 | -608 |
| linny_menu_documents.vim | 0 | ~115 | +115 |
| linny_menu_actions.vim | 0 | ~200 | +200 |
| linny_menu_popup.vim | 0 | ~290 | +290 |

Main file reduction: **~45% smaller** (from 1358 to ~750 lines)

## What Stays in linny_menu.vim

- Public API entry points (`openterm`, `openview`, `openandshow`, `start`, etc.)
- Keymap setup functions (`Setup_keymaps`, `Set_cursor`)
- `<SID>` functions (must stay for mapping references)
- Execute handler (`<SID>linny_menu_execute`) - calls into actions module
- Global remapping functions
- `s:job_start()` utility

## Risk Assessment

- **Documents module**: Low risk - pure file operations
- **Actions module**: Medium risk - callback string references need updating
- **Popup module**: Higher risk - refactoring `finish` pattern, but well-isolated

## Alternatives Considered

1. **Only extract documents** - Safest, but leaves 1240+ lines
2. **Extract documents + actions** - Medium improvement
3. **Full extraction (this proposal)** - Best modularity, prepares for Lua conversion
