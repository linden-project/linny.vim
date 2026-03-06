## 1. Create Lua Module

- [x] 1.1 Create `lua/linny/menu/widgets.lua` with module structure
- [x] 1.2 Implement `recent_files(number)` function using vim.fn.systemlist
- [x] 1.3 Implement `starred_terms_list()` function
- [x] 1.4 Implement `starred_docs_list()` function
- [x] 1.5 Implement `partial_files_listing(files_list, view_props, bool_extra_file_info)` function
- [x] 1.6 Implement `starred_documents(widgetconf)` widget function
- [x] 1.7 Implement `starred_terms(widgetconf)` widget function
- [x] 1.8 Implement `starred_taxonomies(widgetconf)` widget function
- [x] 1.9 Implement `all_taxonomies(widgetconf)` widget function
- [x] 1.10 Implement `recently_modified_documents(widgetconf)` widget function
- [x] 1.11 Implement `all_level0_views(widgetconf)` widget function
- [x] 1.12 Implement `menu(widgetconf)` widget function

## 2. Module Integration

- [x] 2.1 Update `lua/linny/menu/init.lua` to export widgets submodule

## 3. Update VimScript Callers

- [x] 3.1 Update `autoload/linny_menu_views.vim` to use luaeval() for widget function calls

## 4. Cleanup

- [x] 4.1 Remove migrated functions from `autoload/linny_menu_widgets.vim`

## 5. Testing

- [x] 5.1 Create `tests/menu_widgets_spec.lua` with unit tests for data retrieval functions
- [x] 5.2 Run test suite and verify all tests pass
