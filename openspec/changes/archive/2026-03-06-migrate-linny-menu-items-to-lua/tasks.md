## 1. Create Lua Module

- [x] 1.1 Create `lua/linny/menu/items.lua` with module structure and `item_default()` function
- [x] 1.2 Implement `append()` function with weight-based insertion
- [x] 1.3 Implement basic item functions: `add_empty_line()`, `add_divider()`, `add_text()`
- [x] 1.4 Implement header functions: `add_header()`, `add_footer()`, `add_section()`
- [x] 1.5 Implement document functions: `add_document()`, `add_document_taxo_key()`, `add_document_taxo_key_val()`
- [x] 1.6 Implement event functions: `add_special_event()`, `add_ex_event()`, `add_external_location()`
- [x] 1.7 Implement utility functions: `list()`, `get_by_index()`

## 2. Module Integration

- [x] 2.1 Update `lua/linny/menu/init.lua` to export items submodule

## 3. Update VimScript Callers

- [x] 3.1 Update `autoload/linny_menu_render.vim` to use luaeval() for items functions
- [x] 3.2 Update `autoload/linny_menu_views.vim` to use luaeval() for items functions
- [x] 3.3 Update `autoload/linny_menu_widgets.vim` to use luaeval() for items functions

## 4. Cleanup

- [x] 4.1 Delete `autoload/linny_menu_items.vim`

## 5. Testing

- [x] 5.1 Create `tests/menu_items_spec.lua` with unit tests for all functions
- [x] 5.2 Run test suite and verify all tests pass
