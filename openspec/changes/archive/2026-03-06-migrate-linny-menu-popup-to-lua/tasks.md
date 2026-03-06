## 1. Create Lua Module

- [x] 1.1 Create `lua/linny/menu/popup.lua` with module table structure
- [x] 1.2 Implement `create(what, options)` function with platform detection
- [x] 1.3 Implement `close(id, result)` function for both Vim and Neovim
- [x] 1.4 Implement `getoptions(id)` function for both platforms
- [x] 1.5 Implement `setoptions(id, options)` function for both platforms

## 2. Neovim Floating Window Helpers

- [x] 2.1 Implement `num2bool()` option conversion helper
- [x] 2.2 Implement `options()` function to convert popup options to Neovim format
- [x] 2.3 Implement `to_list()` helper to normalize input content
- [x] 2.4 Implement `floatwin()` main floating window creation function
- [x] 2.5 Implement `draw_box()` for border rendering with title support
- [x] 2.6 Implement `centered()` positioning helper
- [x] 2.7 Implement `shift_inside()` for content positioning within box
- [x] 2.8 Implement `get_buffer()` for buffer reuse
- [x] 2.9 Implement `set_lines()` for buffer content setting
- [x] 2.10 Implement `set_winopts()` for window option setting
- [x] 2.11 Implement `set_keymaps()` for filter-based keymap setup
- [x] 2.12 Implement `bufleave()` callback handler with autocmd

## 3. Update Module Exports

- [x] 3.1 Add popup export to `lua/linny/menu/init.lua`

## 4. Update Callers

- [x] 4.1 Update `autoload/linny_menu_views.vim` to use `luaeval("require('linny.menu.popup').create(...)")`
- [x] 4.2 Update `autoload/linny_menu_actions.vim` to use Lua popup calls

## 5. Cleanup

- [x] 5.1 Delete `autoload/linny_menu_popup.vim`
- [x] 5.2 Verify popup functionality works in Neovim
- [x] 5.3 Verify popup functionality works in Vim (if popupwin available)
