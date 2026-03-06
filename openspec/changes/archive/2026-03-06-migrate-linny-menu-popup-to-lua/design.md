## Context

The `linny_menu_popup.vim` file provides cross-platform popup/floating window abstraction that works in both Vim (using popup_*) and Neovim (using nvim_open_win). It's currently called via `linny_menu_popup#function()` from other VimScript files.

The file contains ~270 lines with public functions (create, close, getoptions, setoptions) and Neovim-specific helpers for floating window management including box drawing, buffer management, and keymap setup.

## Goals / Non-Goals

**Goals:**
- Create Lua module `lua/linny/menu/popup.lua` with equivalent functionality
- Maintain cross-platform compatibility (Vim popup API vs Neovim floating windows)
- Enable Lua modules to call popup functions directly
- Update VimScript callers to use `luaeval()` pattern
- Delete the VimScript file after migration

**Non-Goals:**
- Changing popup behavior or appearance
- Refactoring the popup API
- Adding new popup features

## Decisions

### 1. Module Structure
Create `lua/linny/menu/popup.lua` exporting: `create()`, `close()`, `getoptions()`, `setoptions()`

Rationale: Mirrors the existing VimScript function names for easy migration.

### 2. Platform Detection
Use `vim.fn.has('nvim')` and `vim.fn.has('popupwin')` for platform detection.

Rationale: Consistent with how the VimScript version detects platforms.

### 3. Neovim Helpers as Local Functions
Keep Neovim-specific helpers (options conversion, floatwin, draw_box, etc.) as local functions within the module.

Rationale: These are internal implementation details, not part of the public API.

### 4. Callback Handling
VimScript callback functions (like `linny_menu_views#dropdown_l1_callback`) must remain in VimScript since Vim's popup API requires VimScript function references. The Lua module will accept callback function names as strings.

Rationale: Vim popup API limitation - callbacks must be VimScript functions.

### 5. Neovim Autocmds in Lua
Convert VimScript autocmds (`autocmd BufLeave`, `autocmd BufEnter`) to Lua using `vim.api.nvim_create_autocmd()`.

Rationale: Cleaner Lua-native approach.

## Risks / Trade-offs

**[Risk] Callback compatibility** → The Lua module must handle both Vim (string function names) and Neovim (can use Lua functions) callback patterns. Mitigation: Test both platforms.

**[Risk] Buffer variable access** → Current code uses `getbufvar/setbufvar` for storing popup options. Mitigation: Use `vim.b` in Lua which maps to the same mechanism.

**[Risk] Timing of autocmd callbacks** → `BufLeave` triggers and callback timing must match VimScript behavior exactly. Mitigation: Test popup close behavior carefully.
