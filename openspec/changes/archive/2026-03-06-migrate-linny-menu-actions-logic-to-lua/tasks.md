## 1. Add dropdown functions to actions.lua

- [x] 1.1 Add `dropdown_item()` function to `lua/linny/menu/actions.lua`
- [x] 1.2 Add `show_set_taxonomy(item, name, line)` function
- [x] 1.3 Add `show_remove_taxonomy(item, name, line)` function
- [x] 1.4 Add `show_term_selection(name, taxo, terms, line)` function

## 2. Update VimScript to use Lua functions

- [x] 2.1 Update `dropdown_item()` to delegate to Lua
- [x] 2.2 Update `exec_content_menu()` "set taxonomy" to call Lua
- [x] 2.3 Update `exec_content_menu()` "remove taxonomy" to call Lua
- [x] 2.4 Update `dropdown_taxo_item_callback()` to call Lua for term popup

## 3. Cleanup VimScript

- [x] 3.1 Remove migrated logic from VimScript file
- [x] 3.2 Keep only callbacks and thin wrappers

## 4. Verify

- [x] 4.1 Test item dropdown shows actions
- [x] 4.2 Test set taxonomy flow (select taxo → select term)
- [x] 4.3 Test remove taxonomy flow
