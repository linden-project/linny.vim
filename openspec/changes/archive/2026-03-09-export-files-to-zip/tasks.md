## 1. Add Lua functions to actions.lua

- [x] 1.1 Add `check_zip_available()` function to verify zip command exists
- [x] 1.2 Add `export_term_to_zip(output_path, structure)` function for creating zip archive
- [x] 1.3 Add `show_export_structure_popup()` for flat/folders choice (when group_by active)
- [x] 1.4 Add `show_export_path_input(callback)` for output path prompt

## 2. Add context menu option

- [x] 2.1 Add "export to zip" to `build_dropdown_views()` for taxo_key_val items
- [x] 2.2 Handle "export to zip" action in `exec_content_menu()`

## 3. Add VimScript callbacks

- [x] 3.1 Add `dropdown_export_structure_callback` to `linny_menu_actions.vim`
- [x] 3.2 Add `dropdown_export_path_callback` to `linny_menu_actions.vim` (N/A - using vim.fn.input directly)

## 4. Add unit tests

- [x] 4.1 Add test for `check_zip_available` function
- [x] 4.2 Add test for `export_term_to_zip` function (mock zip command)
- [x] 4.3 Add test for "export to zip" appearing in dropdown views

## 5. Verify

- [x] 5.1 Test export to zip in term view without group_by
- [x] 5.2 Test export to zip with group_by active (flat option)
- [x] 5.3 Test export to zip with group_by active (preserve folders option)
- [ ] 5.4 Test error handling when zip command not available
