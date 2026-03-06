## Context

The linny.vim menu system migration continues. Completed migrations:
- `linny_menu_state.vim` → `lua/linny/menu/state.lua`
- `linny_menu_util.vim` → `lua/linny/menu/util.lua`
- `linny_menu_items.vim` → `lua/linny/menu/items.lua`
- `linny_menu_views.vim` → `lua/linny/menu/views.lua`
- `linny_menu_widgets.vim` → `lua/linny/menu/widgets.lua`
- `linny_menu_actions.vim` → `lua/linny/menu/actions.lua` (partial)

The documents module (`autoload/linny_menu_documents.vim`, 235 lines) handles:
1. Document copying with frontmatter modification
2. Creating new documents in taxonomy/term leaves
3. Config file creation and archiving (L1/L2 configs)
4. Window layout management for opening files

## Goals / Non-Goals

**Goals:**
- Full migration of all document functions to Lua
- Maintain exact behavioral parity
- Delete VimScript file after migration

**Non-Goals:**
- Changing document operation behavior
- Modifying config file templates

## Decisions

### Decision 1: Full migration possible

Unlike actions module, documents module has no popup callbacks. All functions can be fully migrated to Lua.

### Decision 2: Window management via vim.cmd

Functions like `open_in_right_pane` use Vim commands for window layout. These will use:
- `vim.cmd('only')` for closing windows
- `vim.cmd('botright vs ' .. path)` for vertical splits
- `vim.fn.winnr()` for window numbers
- `vim.cmd(winnr .. 'wincmd w')` for window switching

### Decision 3: File operations via vim.fn

File reading/writing will use:
- `vim.fn.readfile(path)` for reading
- `vim.fn.writefile(lines, path)` for writing
- `vim.fn.filereadable(path)` for existence checks

### Decision 4: Reuse existing Lua modules

Document functions already call:
- `require('linny.wiki').word_to_filename()` - already in Lua
- `require('linny.menu.util').string_capitalize()` - already in Lua

Will also call VimScript functions via vim.fn:
- `vim.fn['linny#l2_config_filepath']()`
- `vim.fn['linny#generate_first_content']()`
- `vim.fn['linny#term_config']()`

## Risks / Trade-offs

**Risk: Window state management**
- Functions access `t:linny_menu_lastmaxsize` and similar tab-local state
- Mitigation: Use `vim.t.linny_menu_lastmaxsize` which works identically

**Risk: Complex window commands**
- `open_in_right_pane` has complex window switching logic
- Mitigation: Direct translation using vim.cmd, well-tested pattern
