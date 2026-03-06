## 1. Add render function to views.lua

- [x] 1.1 Add `render(view_name)` function to `lua/linny/menu/views.lua`
- [x] 1.2 Implement widget iteration with hidden check
- [x] 1.3 Implement widget type dispatch to widgets module
- [x] 1.4 Add configuration section with edit link

## 2. Add dropdown functions to views.lua

- [x] 2.1 Add `dropdown_l1()` function that creates popup via popup module
- [x] 2.2 Add `dropdown_l2()` function that creates popup via popup module

## 3. Update VimScript callers

- [x] 3.1 Update caller of `linny_menu_views#render()` to use Lua version
- [x] 3.2 Update `linny_menu_views.vim` to remove migrated functions
- [x] 3.3 Keep only callback functions in `linny_menu_views.vim`

## 4. Verify

- [x] 4.1 Test view rendering works correctly
- [x] 4.2 Test L1 dropdown works with callback
- [x] 4.3 Test L2 dropdown works with callback
