## Tasks

### 1. Create linny_menu_util.vim
Extract utility functions (no dependencies on other modules).

**Files:** `autoload/linny_menu_util.vim`

**Functions to move:**
- `PrePad()` → `linny_menu_util#prepad()`
- `Expand_text()` → `linny_menu_util#expand_text()`
- `Slimit()` → `linny_menu_util#slimit()`
- `Cmdmsg()` → `linny_menu_util#cmdmsg()`
- `Errmsg()` → `linny_menu_util#errmsg()`
- `Highlight()` → `linny_menu_util#highlight()`
- `linny_menu#string_capitalize()` → `linny_menu_util#string_capitalize()`
- `linny_menu#stringOfLengthWithChar()` → `linny_menu_util#string_of_length_with_char()`
- `linny_menu#calcActiveViewArrow()` → `linny_menu_util#calc_active_view_arrow()`

**Acceptance:**
- [x] File created with all utility functions
- [x] All internal calls updated to new names

### 2. Create linny_menu_state.vim
Extract tab state management.

**Files:** `autoload/linny_menu_state.vim`

**Functions to move:**
- `linny_menu#tabInitState()` → `linny_menu_state#tab_init()`
- `NewLinnyTabNr()` → `linny_menu_state#new_tab_nr()`
- `linny_menu#termValueLeafState()` → `linny_menu_state#term_value_leaf_state()`
- `linny_menu#termLeafState()` → `linny_menu_state#term_leaf_state()`
- `linny_menu#writeTermLeafState()` → `linny_menu_state#write_term_leaf_state()`
- `linny_menu#writeTermValueLeafState()` → `linny_menu_state#write_term_value_leaf_state()`
- `linny_menu#reset()` → `linny_menu_state#reset()`

**Acceptance:**
- [x] File created with all state functions
- [x] Tab-local variable initialization preserved
- [x] All internal calls updated

### 3. Create linny_menu_items.vim
Extract menu item construction functions.

**Files:** `autoload/linny_menu_items.vim`

**Functions to move:**
- `s:item_default()` → `linny_menu_items#item_default()`
- `s:add_item_empty_line()` → `linny_menu_items#add_empty_line()`
- `s:add_item_divider()` → `linny_menu_items#add_divider()`
- `s:add_item_header()` → `linny_menu_items#add_header()`
- `s:add_item_footer()` → `linny_menu_items#add_footer()`
- `s:add_item_section()` → `linny_menu_items#add_section()`
- `s:add_item_text()` → `linny_menu_items#add_text()`
- `s:add_item_document()` → `linny_menu_items#add_document()`
- `s:add_item_document_taxo_key()` → `linny_menu_items#add_document_taxo_key()`
- `s:add_item_document_taxo_key_val()` → `linny_menu_items#add_document_taxo_key_val()`
- `s:add_item_special_event()` → `linny_menu_items#add_special_event()`
- `s:add_item_ex_event()` → `linny_menu_items#add_ex_event()`
- `s:add_item_external_location()` → `linny_menu_items#add_external_location()`
- `linny_menu#list()` → `linny_menu_items#list()`
- `s:get_item_by_index()` → `linny_menu_items#get_by_index()`

**Acceptance:**
- [x] File created with all item functions
- [x] All s: functions converted to public
- [x] All internal calls updated

### 4. Create linny_menu_window.vim
Extract window/buffer management functions.

**Files:** `autoload/linny_menu_window.vim`

**Functions to move:**
- `Window_exist()` → `linny_menu_window#exist()`
- `Window_close()` → `linny_menu_window#close_window()`
- `Window_open()` → `linny_menu_window#open_window()`
- `Window_render()` → `linny_menu_window#render()`
- `linny_menu#start()` → `linny_menu_window#start()`
- `linny_menu#open()` → `linny_menu_window#open()`
- `linny_menu#close()` → `linny_menu_window#close()`
- `linny_menu#toggle()` → `linny_menu_window#toggle()`
- `linny_menu#refreshMenu()` → `linny_menu_window#refresh()`
- `linny_menu#openHome()` → `linny_menu_window#open_home()`
- `linny_menu#openFile()` → `linny_menu_window#open_file()`

**Acceptance:**
- [x] File created with all window functions
- [x] Buffer/window creation preserved
- [x] All internal calls updated

### 5. Create linny_menu_views.vim
Extract view management functions.

**Files:** `autoload/linny_menu_views.vim`

**Functions to move:**
- `linny_menu#render_view()` → `linny_menu_views#render()`
- `linny_menu#cycle_l1_view()` → `linny_menu_views#cycle_l1()`
- `linny_menu#cycle_l2_view()` → `linny_menu_views#cycle_l2()`
- `linny_menu#dropdown_l1_view()` → `linny_menu_views#dropdown_l1()`
- `linny_menu#dropdown_l1_view_callback()` → `linny_menu_views#dropdown_l1_callback()`
- `linny_menu#dropdown_l2_view()` → `linny_menu_views#dropdown_l2()`
- `linny_menu#dropdown_l2_view_callback()` → `linny_menu_views#dropdown_l2_callback()`
- `linny_menu#new_active_view()` → `linny_menu_views#new_active()`
- `linny_menu#get_views_list()` → `linny_menu_views#get_list()`
- `linny_menu#get_views()` → `linny_menu_views#get_views()`
- `linny_menu#menu_get_active_view()` → `linny_menu_views#get_active()`
- `linny_menu#menu_current_view_props()` → `linny_menu_views#current_props()`

**Acceptance:**
- [x] File created with all view functions
- [x] View cycling works correctly
- [x] All internal calls updated

### 6. Create linny_menu_widgets.vim
Extract widget functions.

**Files:** `autoload/linny_menu_widgets.vim`

**Functions to move:**
- `linny_menu#widget_starred_documents()` → `linny_menu_widgets#starred_documents()`
- `linny_menu#widget_all_level0_views()` → `linny_menu_widgets#all_level0_views()`
- `linny_menu#widget_starred_terms()` → `linny_menu_widgets#starred_terms()`
- `linny_menu#widget_starred_taxonomies()` → `linny_menu_widgets#starred_taxonomies()`
- `linny_menu#widget_all_taxonomies()` → `linny_menu_widgets#all_taxonomies()`
- `linny_menu#widget_recently_modified_documents()` → `linny_menu_widgets#recently_modified_documents()`
- `linny_menu#widget_menu()` → `linny_menu_widgets#menu()`
- `linny_menu#recent_files()` → `linny_menu_widgets#recent_files()`
- `linny_menu#starred_terms()` → `linny_menu_widgets#starred_terms_list()`
- `linny_menu#starred_docs()` → `linny_menu_widgets#starred_docs_list()`
- `s:partial_files_listing()` → `linny_menu_widgets#partial_files_listing()`

**Acceptance:**
- [x] File created with all widget functions
- [x] Widgets render correctly in views
- [x] All internal calls updated

### 7. Create linny_menu_render.vim
Extract menu rendering functions.

**Files:** `autoload/linny_menu_render.vim`

**Functions to move:**
- `s:menu_level0()` → `linny_menu_render#level0()`
- `s:menu_level1()` → `linny_menu_render#level1()`
- `s:menu_level2()` → `linny_menu_render#level2()`
- `s:partial_footer_items()` → `linny_menu_render#partial_footer_items()`
- `s:partial_debug_info()` → `linny_menu_render#partial_debug_info()`
- `s:displayFileAskViewProps()` → `linny_menu_render#display_file_ask_view_props()`
- `s:testFileWithDisplayExpression()` → `linny_menu_render#test_file_with_display_expression()`

**Acceptance:**
- [x] File created with all render functions
- [x] Menu levels render correctly
- [x] All internal calls updated

### 8. Keep remaining functions in linny_menu.vim
The following functions remain in the main file due to architectural constraints:

**Reasons for keeping in main file:**
- `<SID>` functions must stay due to script-local scope requirements for key mappings
- Popup functions use `finish` statements for Vim/Neovim compatibility branching
- Document operations are tightly coupled with menu state and window management
- Public API functions (`linny_menu#openterm`, `linny_menu#start`, etc.) provide stable interface

**Functions kept:**
- Public API: `linny_menu#openterm()`, `linny_menu#openview()`, `linny_menu#openandshow()`, `linny_menu#start()`, `linny_menu#open()`, `linny_menu#close()`, `linny_menu#toggle()`
- Keymap setup: `Setup_keymaps()`, `Set_cursor()`, `Select_items()`, `Menu_expand()`
- SID functions: `<SID>linny_menu_close()`, `<SID>linny_menu_enter()`, `<SID>linny_menu_execute()`, `<SID>linny_menu_execute_by_string()`, `<SID>linny_menu_hotkey()`
- Global remapping: `linny_menu#RemapGlobalKeys()`, `linny_menu#RemapGlobalStarredDocs()`, `linny_menu#RemapGlobalStarredTerms()`
- Dropdown actions: `linny_menu#dropdown_item()`, `linny_menu#dropdown_*_callback()`, `linny_menu#exec_content_menu()`
- Document operations: `linny_menu#copy_document()`, `linny_menu#new_document_in_leaf()`, `linny_menu#open_document_in_right_pane()`, `linny_menu#archiveL2config()`, `s:createl2config()`
- Popup functions: `linny_menu#create_popup()`, `linny_menu#close_pop()`, `linny_menu#getoptions()`, `linny_menu#setoptions()` (plus neovim-specific helpers)

**Acceptance:**
- [x] Main file reduced from 2669 to 1358 lines (49% reduction)
- [x] All functionality preserved
- [x] Public API unchanged

### 9. Manual testing
Test all menu functionality.

**Acceptance:**
- [x] Menu opens and closes
- [x] Level 0 (home) renders correctly
- [x] Level 1 (taxonomy) renders correctly
- [x] Level 2 (term) renders correctly
- [x] Keyboard navigation works
- [x] View cycling works (v key)
- [x] Document actions work (dropdown menu)
- [x] Widget rendering works
- [x] Multiple tabs maintain separate state

## Summary

**Completed extraction:**
| Module | Lines | Description |
|--------|-------|-------------|
| linny_menu_util.vim | 147 | Utility functions |
| linny_menu_state.vim | 52 | Tab state management |
| linny_menu_items.vim | 180 | Menu item construction |
| linny_menu_window.vim | 226 | Window/buffer management |
| linny_menu_views.vim | 197 | View cycling/selection |
| linny_menu_widgets.vim | 202 | Dashboard widgets |
| linny_menu_render.vim | 402 | Menu level rendering |
| linny_menu.vim | 1358 | Main file (reduced) |
| **Total** | **2764** | |

**Not extracted (by design):**
- Tasks 8-11 from original plan were consolidated into keeping functions in main file
- Keymaps module skipped: `<SID>` functions cannot be moved due to script-local scope
- Actions module skipped: tightly coupled with execute system
- Documents module skipped: depends on menu state and window management
- Popup module skipped: uses `finish` statements for Vim/Neovim compatibility
