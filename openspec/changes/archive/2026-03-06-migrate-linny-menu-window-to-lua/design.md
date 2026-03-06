## Context

The linny.vim plugin is migrating menu functionality from VimScript to Lua. Already migrated: `state`, `util`, `items`, `views`, `widgets`, `actions`, `documents`. The `linny_menu_window.vim` file contains window/buffer management with 11 functions.

Current file structure:
- `autoload/linny_menu_window.vim` (227 lines) - window management
- `lua/linny/menu/` - existing Lua modules

## Goals / Non-Goals

**Goals:**
- Migrate all window management functions to `lua/linny/menu/window.lua`
- Maintain exact behavior parity with VimScript implementation
- Follow established module patterns from prior migrations
- Keep popup-dependent callbacks in VimScript if needed

**Non-Goals:**
- Refactoring window management logic
- Adding new window features
- Migrating `linny_menu.vim` or other files in this change

## Decisions

### 1. Full migration approach
Migrate all functions to Lua. The window module has no popup callbacks (unlike actions), so full migration is possible.

**Rationale:** Window functions use standard Neovim APIs (`vim.fn`, `vim.cmd`, `vim.t`) which work well from Lua.

### 2. Function mapping
| VimScript | Lua |
|-----------|-----|
| `linny_menu_window#exist()` | `M.exist()` |
| `linny_menu_window#close_window()` | `M.close_window()` |
| `linny_menu_window#open_window(size)` | `M.open_window(size)` |
| `linny_menu_window#render(items)` | `M.render(items)` |
| `linny_menu_window#start()` | `M.start()` |
| `linny_menu_window#open()` | `M.open()` |
| `linny_menu_window#close()` | `M.close()` |
| `linny_menu_window#toggle()` | `M.toggle()` |
| `linny_menu_window#refresh()` | `M.refresh()` |
| `linny_menu_window#open_home()` | `M.open_home()` |
| `linny_menu_window#open_file(filepath)` | `M.open_file(filepath)` |

### 3. Tab-local state via vim.t
Use `vim.t.linny_menu_bid`, `vim.t.linny_menu_name`, `vim.t.linny_menu`, `vim.t.linny_menu_lastmaxsize` for tab-local state.

### 4. VimScript interop
Functions that call other VimScript functions (`linny_menu#openterm`, `linny_menu#openandshow`, `linny#Init`, `linny#make_index`) will use `vim.fn[]` calls.

## Risks / Trade-offs

**Risk:** `toggle()` calls `Select_items()`, `Menu_expand()`, `Setup_keymaps()` which are global VimScript functions
→ Mitigation: Use `vim.fn.Select_items()` etc. to call them from Lua

**Risk:** Buffer option setting may differ between Vim and Neovim
→ Mitigation: Use `vim.cmd('setlocal ...')` to maintain compatibility
