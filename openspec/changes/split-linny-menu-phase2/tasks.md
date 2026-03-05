## Tasks

### 1. Create linny_menu_documents.vim
Extract document and configuration file operations.

**Files:** `autoload/linny_menu_documents.vim`

**Functions to extract:**
- `linny_menu#copy_document()` → `linny_menu_documents#copy()`
- `linny_menu#new_document_in_leaf()` → `linny_menu_documents#new_in_leaf()`
- `linny_menu#open_document_in_right_pane()` → `linny_menu_documents#open_in_right_pane()`
- `linny_menu#replace_key_value_in_root_frontmatter_filelines()` → `linny_menu_documents#replace_frontmatter_key()`
- `linny_menu#archiveL2config()` → `linny_menu_documents#archive_l2_config()`
- `s:createl2config()` → `linny_menu_documents#create_l2_config()`
- Extract L1 config creation from `<SID>linny_menu_execute` → `linny_menu_documents#create_l1_config()`

**Acceptance:**
- [ ] File created with all document functions
- [ ] Functions use consistent snake_case naming
- [ ] All internal calls in linny_menu.vim updated
- [ ] Document copy works
- [ ] Document creation works
- [ ] Config creation works

---

### 2. Create linny_menu_popup.vim
Extract popup/floating window abstraction with refactored `finish` pattern.

**Files:** `autoload/linny_menu_popup.vim`

**Functions to extract:**
- `linny_menu#create_popup()` → `linny_menu_popup#create()`
- `linny_menu#close_pop()` → `linny_menu_popup#close()`
- `linny_menu#getoptions()` → `linny_menu_popup#getoptions()`
- `linny_menu#setoptions()` → `linny_menu_popup#setoptions()`
- All `s:` neovim helper functions (wrapped in `if has('nvim')`)

**Refactoring required:**
- Remove `finish` statements
- Wrap neovim-only `s:` functions in `if has('nvim')` block
- Ensure Vim popup path still works (if applicable)

**Acceptance:**
- [ ] File created with popup abstraction
- [ ] `finish` statements replaced with `if has('nvim')` guards
- [ ] Popup creation works in Neovim
- [ ] All callers updated to use `linny_menu_popup#*`

---

### 3. Update linny_menu_views.vim for popup module
Update view dropdown functions to use new popup module.

**Files:** `autoload/linny_menu_views.vim`

**Changes:**
- `linny_menu#create_popup()` → `linny_menu_popup#create()`

**Acceptance:**
- [ ] All `linny_menu#create_popup` calls updated
- [ ] View dropdowns still work

---

### 4. Create linny_menu_actions.vim
Extract dropdown actions and content menu execution.

**Files:** `autoload/linny_menu_actions.vim`

**Functions to extract:**
- `linny_menu#dropdown_item()` → `linny_menu_actions#dropdown_item()`
- `linny_menu#dropdown_item_callcack()` → `linny_menu_actions#dropdown_item_callback()`
- `linny_menu#dropdown_taxo_item_callcack()` → `linny_menu_actions#dropdown_taxo_item_callback()`
- `linny_menu#dropdown_remove_taxo_item_callcack()` → `linny_menu_actions#dropdown_remove_taxo_item_callback()`
- `linny_menu#dropdown_term_item_callcack()` → `linny_menu_actions#dropdown_term_item_callback()`
- `linny_menu#exec_content_menu()` → `linny_menu_actions#exec_content_menu()`

**Callback string updates:**
```vim
callback: 'linny_menu#dropdown_item_callcack'
→
callback: 'linny_menu_actions#dropdown_item_callback'
```

**Acceptance:**
- [ ] File created with all action functions
- [ ] Callback function names use correct spelling (callback not callcack)
- [ ] All callback string references updated
- [ ] Dropdown menus work
- [ ] Content actions work (copy, archive, set taxonomy, etc.)

---

### 5. Update linny_menu.vim main file
Remove extracted functions and update all internal calls.

**Files:** `autoload/linny_menu.vim`

**Changes:**
1. Remove extracted document functions (~115 lines)
2. Remove extracted popup functions (~290 lines)
3. Remove extracted action functions (~200 lines)
4. Update `<SID>linny_menu_execute`:
   - `s:createl2config()` → `linny_menu_documents#create_l2_config()`
   - Extract L1 config creation to documents module
5. Update `<SID>linny_menu_hotkey`:
   - `linny_menu#dropdown_item()` → `linny_menu_actions#dropdown_item()`
6. Keep `s:job_start()` utility function

**Acceptance:**
- [ ] All extracted functions removed
- [ ] All internal calls updated to new modules
- [ ] Main file reduced to ~750 lines
- [ ] No orphaned function references

---

### 6. Manual testing
Test all menu functionality after extraction.

**Test cases:**
- [ ] Menu opens and closes
- [ ] Navigation between levels works
- [ ] View cycling works (v key)
- [ ] Dropdown menus appear correctly
- [ ] Document copy works (m → copy)
- [ ] Document archive works (m → archive)
- [ ] Set taxonomy works (m → set taxonomy → select)
- [ ] Remove taxonomy works (m → remove taxonomy → select)
- [ ] Create new document works (A key)
- [ ] Create L1 config works
- [ ] Create L2 config works
- [ ] Open document in new tab works (t key)

---

## Summary

| Task | Risk | Lines Changed |
|------|------|---------------|
| 1. Documents module | Low | +115, -115 |
| 2. Popup module | Medium | +290, -290 |
| 3. Update views | Low | ~4 lines |
| 4. Actions module | Medium | +200, -200 |
| 5. Update main | Low | -600 |
| 6. Testing | - | - |

**Expected final state:**
- `linny_menu.vim`: ~750 lines (down from 1358)
- `linny_menu_documents.vim`: ~115 lines (new)
- `linny_menu_actions.vim`: ~200 lines (new)
- `linny_menu_popup.vim`: ~290 lines (new)
