# Design: Split linny_menu.vim Phase 2

## Architecture

### Module Dependency Graph

```
linny_menu.vim (main/coordinator)
    ├── linny_menu_documents.vim (document operations)
    ├── linny_menu_actions.vim (dropdown actions)
    │   └── uses linny_menu_popup#create()
    │   └── uses linny_menu_documents#*()
    └── linny_menu_popup.vim (popup abstraction)
```

### Data Flow

```
User Action (keymap)
    │
    ▼
<SID>linny_menu_execute() [stays in main]
    │
    ├─► linny_menu_actions#dropdown_item()
    │       │
    │       ▼
    │   linny_menu_popup#create()
    │       │
    │       ▼
    │   callback: linny_menu_actions#dropdown_item_callback()
    │       │
    │       ▼
    │   linny_menu_actions#exec_content_menu()
    │       │
    │       ├─► linny_menu_documents#copy()
    │       ├─► linny_menu_documents#create_l2_config()
    │       └─► linny_menu_documents#archive_l2_config()
    │
    └─► Direct event handlers (stay in main)
```

## Module Specifications

### 1. linny_menu_documents.vim

**Purpose**: Document and configuration file operations

**Public Functions**:
| Function | Description |
|----------|-------------|
| `linny_menu_documents#copy(source_path, new_title)` | Copy document with new title |
| `linny_menu_documents#new_in_leaf(...)` | Create new document in current taxonomy/term |
| `linny_menu_documents#open_in_right_pane(path)` | Open document preserving menu layout |
| `linny_menu_documents#replace_frontmatter_key(lines, key, value)` | Update frontmatter key |
| `linny_menu_documents#archive_l2_config(taxonomy, term)` | Archive a term config |
| `linny_menu_documents#create_l2_config(taxonomy, term)` | Create/open term config |
| `linny_menu_documents#create_l1_config(taxonomy)` | Create/open taxonomy config |

**Dependencies**:
- `linny#*` functions for paths and config
- `linny_menu_util#string_capitalize()`
- `linny_menu#openandshow()` for refresh after operations
- Tab variables: `t:linny_menu_taxonomy`, `t:linny_menu_term`, `t:linny_menu_lastmaxsize`

### 2. linny_menu_actions.vim

**Purpose**: Dropdown menu actions and content menu execution

**Public Functions**:
| Function | Description |
|----------|-------------|
| `linny_menu_actions#dropdown_item()` | Show action dropdown for current item |
| `linny_menu_actions#dropdown_item_callback(id, result)` | Handle dropdown selection |
| `linny_menu_actions#dropdown_taxo_item_callback(id, result)` | Handle taxonomy selection |
| `linny_menu_actions#dropdown_remove_taxo_item_callback(id, result)` | Handle taxonomy removal |
| `linny_menu_actions#dropdown_term_item_callback(id, result)` | Handle term selection |
| `linny_menu_actions#exec_content_menu(action, item)` | Execute content menu action |

**Dependencies**:
- `linny_menu_popup#create()` for dropdowns
- `linny_menu_documents#*` for document operations
- `linny#parse_json_file()` for index access
- Tab variables: `t:linny_menu_item_for_dropdown`, `t:linny_menu_dropdownviews`, etc.

**Callback String Updates**:
```vim
" Old
callback: 'linny_menu#dropdown_item_callcack'

" New
callback: 'linny_menu_actions#dropdown_item_callback'
```

### 3. linny_menu_popup.vim

**Purpose**: Cross-platform popup/floating window abstraction

**Public Functions**:
| Function | Description |
|----------|-------------|
| `linny_menu_popup#create(what, options)` | Create popup (vim) or float (nvim) |
| `linny_menu_popup#close(id, result)` | Close popup with result |
| `linny_menu_popup#getoptions(id)` | Get popup options |
| `linny_menu_popup#setoptions(id, options)` | Set popup options |

**Script-local Functions** (neovim-only, kept as `s:`):
- `s:floatwin()` - Create neovim floating window
- `s:options()` - Convert popup options to nvim format
- `s:to_list()` - Convert content to list
- `s:draw_box()` - Draw border box
- `s:get_buffer()` - Get/create scratch buffer
- `s:set_keymaps()` - Set popup keymaps
- `s:set_lines()` - Set buffer lines
- `s:set_winopts()` - Set window options
- `s:shift_inside()` - Calculate inner position
- `s:centered()` - Calculate centered position
- `s:bufleave()` - Handle buffer leave
- `s:num2bool()` - Convert 0/1 to v:false/v:true

**Refactoring `finish` pattern**:

Before:
```vim
function! linny_menu#create_popup(what, options) abort
    if has('popupwin')
        return popup_create(a:what, a:options)
    elseif has('nvim')
        return s:floatwin(s:to_list(a:what), s:options(#{}, a:options))
    endif
endfunction

if !has('nvim')
    finish
endif

" neovim-only functions here...
```

After:
```vim
function! linny_menu_popup#create(what, options) abort
    if has('popupwin')
        return popup_create(a:what, a:options)
    elseif has('nvim')
        return s:floatwin(s:to_list(a:what), s:options(#{}, a:options))
    endif
endfunction

" Guard all neovim-only s: functions
if has('nvim')

function! s:floatwin(lines, opts) abort
    " ... implementation
endfunction

" ... other s: functions

endif " has('nvim')
```

## Updates to Existing Files

### linny_menu.vim Changes

1. **Remove extracted functions** (~600 lines)

2. **Update callback references in `<SID>linny_menu_execute`**:
```vim
" Old
elseif(item.event == 'createl2config')
    call s:createl2config(t:linny_menu_taxonomy, t:linny_menu_term)

" New
elseif(item.event == 'createl2config')
    call linny_menu_documents#create_l2_config(t:linny_menu_taxonomy, t:linny_menu_term)
```

3. **Update `<SID>linny_menu_hotkey`**:
```vim
" Old
call linny_menu#dropdown_item()

" New
call linny_menu_actions#dropdown_item()
```

4. **Keep `s:job_start()`** - Used by multiple modules, stays in main

### linny_menu_views.vim Changes

Update popup creation calls:
```vim
" Old
call linny_menu#create_popup(views, #{...})

" New
call linny_menu_popup#create(views, #{...})
```

## Testing Strategy

1. **Unit tests** (if available): Verify each function works in isolation
2. **Integration tests**:
   - Create new document from menu
   - Copy document
   - Archive term config
   - Set/remove taxonomy on document
   - Dropdown menus appear and function
3. **Cross-platform**: Test on both Vim (if supported) and Neovim

## Migration Path

1. Create `linny_menu_documents.vim` first (lowest risk)
2. Create `linny_menu_popup.vim` (isolated, but needs `finish` refactor)
3. Create `linny_menu_actions.vim` (depends on popup)
4. Update all call sites in main file
5. Update callback string references
6. Test thoroughly
