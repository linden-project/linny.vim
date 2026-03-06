## 1. Add Lua functions to actions.lua

- [x] 1.1 Add `get_term_document_paths(tax, term)` function
- [x] 1.2 Add `copy_term_paths_to_clipboard(format)` function
- [x] 1.3 Add `show_term_paths_format_popup()` function

## 2. Add VimScript callback and keymap

- [x] 2.1 Add `dropdown_term_paths_format_callback` to `linny_menu_actions.vim`
- [x] 2.2 Add `Y` keymap for `menu_level2` in `Setup_keymaps()`

## 3. Add unit tests

- [x] 3.1 Add test for `get_term_document_paths`
- [x] 3.2 Add test for `copy_term_paths_to_clipboard`

## 4. Verify

- [ ] 4.1 Test Y hotkey shows format popup in term view
- [ ] 4.2 Test absolute paths are copied correctly
- [ ] 4.3 Test relative paths are copied correctly
- [ ] 4.4 Test Y does nothing in level 1 menu
