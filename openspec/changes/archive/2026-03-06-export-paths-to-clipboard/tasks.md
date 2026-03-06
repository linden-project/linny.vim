## 1. Add clipboard functions to actions.lua

- [x] 1.1 Add `copy_path_to_clipboard(item, format)` function
- [x] 1.2 Add `show_path_format_popup(item, line)` function
- [x] 1.3 Add "copy path" to `build_dropdown_views()` for documents

## 2. Add VimScript callback

- [x] 2.1 Add `dropdown_path_format_callback` to `linny_menu_actions.vim`

## 3. Handle clipboard action in exec_content_menu

- [x] 3.1 Add "copy path" case to `exec_content_menu()` that shows format popup

## 4. Add unit tests

- [x] 4.1 Add test for `copy_path_to_clipboard` with absolute path
- [x] 4.2 Add test for `copy_path_to_clipboard` with relative path
- [x] 4.3 Add test for clipboard unavailable handling

## 5. Verify

- [ ] 5.1 Test copy path action appears in document menu
- [ ] 5.2 Test absolute path copies correctly
- [ ] 5.3 Test relative path copies correctly
