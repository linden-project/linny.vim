## ADDED Requirements

### Requirement: Module is requireable
The `linny.menu.window` module SHALL be loadable via Lua's require system and accessible through the menu module hierarchy.

#### Scenario: Direct require
- **WHEN** calling `require('linny.menu.window')`
- **THEN** the module loads without error and returns a table with all window functions

#### Scenario: Access via menu module
- **WHEN** calling `require('linny.menu').window`
- **THEN** the window submodule is accessible

#### Scenario: Access via main module
- **WHEN** calling `require('linny').menu.window`
- **THEN** the window submodule is accessible through the main module

### Requirement: exist checks menu window existence
The `exist()` function SHALL return whether the menu window buffer exists.

#### Scenario: Menu not initialized
- **WHEN** calling `exist()` without `t:linny_menu_bid` set
- **THEN** it returns false and initializes `t:linny_menu_bid` to -1

#### Scenario: Menu buffer exists
- **WHEN** calling `exist()` with valid `t:linny_menu_bid`
- **THEN** it returns true if buffer exists, false otherwise

### Requirement: close_window closes the menu
The `close_window()` function SHALL close the menu window and clean up the buffer.

#### Scenario: Last window handling
- **WHEN** calling `close_window()` and menu is the only window
- **THEN** it creates a new window before closing to avoid closing Vim

#### Scenario: Normal close
- **WHEN** calling `close_window()` with menu buffer open
- **THEN** it wipes the buffer and sets `t:linny_menu_bid` to -1

### Requirement: open_window creates menu window
The `open_window(size)` function SHALL create a menu window with the specified size.

#### Scenario: Size constraints
- **WHEN** calling `open_window(size)` with size outside bounds
- **THEN** it clamps size between 4 and `g:linny_menu_max_width`

#### Scenario: Window creation
- **WHEN** calling `open_window(size)`
- **THEN** it creates a vertical split and sets buffer options (nofile, nowrap, etc.)

#### Scenario: Position option
- **WHEN** `g:linny_menu_options` contains 'T'
- **THEN** window opens on the left; otherwise opens on the right

### Requirement: render displays items in window
The `render(items)` function SHALL display menu items in the window buffer.

#### Scenario: Render items
- **WHEN** calling `render(items)` with a list of menu items
- **THEN** it displays each item's text and tracks line numbers by mode

#### Scenario: Track line types
- **WHEN** rendering items with different modes
- **THEN** it populates `t:linny_menu.option_lines`, `section_lines`, `text_lines`, `header_lines`, `footer_lines`

### Requirement: start initializes and opens menu
The `start()` function SHALL initialize tab state and open the term view.

#### Scenario: Start menu
- **WHEN** calling `start()`
- **THEN** it calls state.tab_init() and opens the root term view

### Requirement: open opens menu if closed
The `open()` function SHALL open the menu only if it doesn't exist.

#### Scenario: Menu not open
- **WHEN** calling `open()` and menu doesn't exist
- **THEN** it initializes state and shows the menu

#### Scenario: Menu already open
- **WHEN** calling `open()` and menu exists
- **THEN** it does nothing

### Requirement: close closes menu if open
The `close()` function SHALL close the menu only if it exists.

#### Scenario: Menu open
- **WHEN** calling `close()` and menu exists
- **THEN** it closes the menu window

#### Scenario: Menu not open
- **WHEN** calling `close()` and menu doesn't exist
- **THEN** it does nothing

### Requirement: toggle toggles menu visibility
The `toggle()` function SHALL open the menu if closed, close if open.

#### Scenario: Toggle open
- **WHEN** calling `toggle()` and menu doesn't exist
- **THEN** it builds and displays the menu

#### Scenario: Toggle close
- **WHEN** calling `toggle()` and menu exists
- **THEN** it closes the menu

### Requirement: refresh rebuilds the index and menu
The `refresh()` function SHALL reinitialize linny and rebuild the menu.

#### Scenario: Refresh
- **WHEN** calling `refresh()`
- **THEN** it calls linny#Init(), linny#make_index(), and reopens the menu

### Requirement: open_home navigates to home view
The `open_home()` function SHALL navigate the menu to the root view.

#### Scenario: Menu exists
- **WHEN** calling `open_home()` with menu initialized
- **THEN** it opens the root term view

#### Scenario: Menu not initialized
- **WHEN** calling `open_home()` without menu
- **THEN** it displays an error message

### Requirement: open_file opens file preserving menu
The `open_file(filepath)` function SHALL open a file while preserving the menu layout.

#### Scenario: From menu buffer
- **WHEN** calling `open_file(path)` while in menu buffer
- **THEN** it opens file in vertical split and restores menu width

#### Scenario: From non-menu buffer
- **WHEN** calling `open_file(path)` while not in menu buffer
- **THEN** it opens the file normally with :e
