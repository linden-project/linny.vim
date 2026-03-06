## 1. Add formatting functions to items.lua

- [x] 1.1 Add `select_items()` function to `lua/linny/menu/items.lua`
- [x] 1.2 Add `expand_item(item)` function to items.lua
- [x] 1.3 Add `build_content()` function that combines select and expand

## 2. Update VimScript to use Lua functions

- [x] 2.1 Update `openandshow()` to call `items.build_content()` via luaeval
- [x] 2.2 Update `toggle()` to call `items.build_content()` via luaeval

## 3. Cleanup VimScript

- [x] 3.1 Remove `Select_items()` function from linny_menu.vim
- [x] 3.2 Remove `Menu_expand()` function from linny_menu.vim
- [x] 3.3 Remove `s:job_start()` helper (duplicate of actions.lua)

## 4. Verify

- [x] 4.1 Test menu opens with correct item formatting
- [x] 4.2 Test key navigation works (numbered keys)
- [x] 4.3 Test multi-line items display correctly
