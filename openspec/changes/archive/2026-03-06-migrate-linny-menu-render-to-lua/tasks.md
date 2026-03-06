## 1. Create Lua Module

- [x] 1.1 Create `lua/linny/menu/render.lua` with module structure
- [x] 1.2 Implement `test_file_with_display_expression(file_dict, expr)` function
- [x] 1.3 Implement `display_file_ask_view_props(view_props, file_dict)` function
- [x] 1.4 Implement `level0(view_name)` function
- [x] 1.5 Implement `level1(tax)` function
- [x] 1.6 Implement `level2(tax, term)` function
- [x] 1.7 Implement `partial_debug_info()` function
- [x] 1.8 Implement `partial_footer_items()` function

## 2. Module Integration

- [x] 2.1 Update `lua/linny/menu/init.lua` to export render submodule

## 3. Update VimScript Callers

- [x] 3.1 Update `autoload/linny_menu.vim` to use luaeval() for render calls
- [x] 3.2 Update `autoload/linny_menu_views.vim` to use luaeval() for render calls (no calls found)

## 4. Cleanup

- [x] 4.1 Delete `autoload/linny_menu_render.vim`

## 5. Testing

- [x] 5.1 Create `tests/menu_render_spec.lua` with unit tests
- [x] 5.2 Run test suite and verify all tests pass
