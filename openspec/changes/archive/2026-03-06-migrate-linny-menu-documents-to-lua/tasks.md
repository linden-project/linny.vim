## 1. Create Lua Module

- [x] 1.1 Create `lua/linny/menu/documents.lua` with module structure
- [x] 1.2 Implement `replace_frontmatter_key(file_lines, key, new_value)` function
- [x] 1.3 Implement `open_in_right_pane(path)` function
- [x] 1.4 Implement `copy(source_path, new_title)` function
- [x] 1.5 Implement `new_in_leaf(title)` function
- [x] 1.6 Implement `archive_l2_config(taxonomy, taxo_term)` function
- [x] 1.7 Implement `create_l2_config(taxonomy, taxo_term)` function
- [x] 1.8 Implement `create_l1_config(taxonomy)` function

## 2. Module Integration

- [x] 2.1 Update `lua/linny/menu/init.lua` to export documents submodule

## 3. Update VimScript Callers

- [x] 3.1 Update `autoload/linny_menu_actions.vim` to use luaeval() for document calls (no calls found)
- [x] 3.2 Update `autoload/linny_menu.vim` to use luaeval() for document calls

## 4. Cleanup

- [x] 4.1 Delete `autoload/linny_menu_documents.vim`

## 5. Testing

- [x] 5.1 Create `tests/menu_documents_spec.lua` with unit tests
- [x] 5.2 Run test suite and verify all tests pass
