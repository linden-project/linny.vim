## ADDED Requirements

### Requirement: Module is requireable
The `linny.menu.actions` module SHALL be loadable via Lua's require system and accessible through the menu module hierarchy.

#### Scenario: Direct require
- **WHEN** calling `require('linny.menu.actions')`
- **THEN** the module loads without error and returns a table with all action functions

#### Scenario: Access via menu module
- **WHEN** calling `require('linny.menu').actions`
- **THEN** the actions submodule is accessible

#### Scenario: Access via main module
- **WHEN** calling `require('linny').menu.actions`
- **THEN** the actions submodule is accessible through the main module

### Requirement: job_start executes external commands
The `job_start(command)` function SHALL execute external commands asynchronously in both Vim and Neovim.

#### Scenario: Execute command in Neovim
- **WHEN** calling `job_start({"fred", "set_bool_val", "/path/file.md", "archive", "true"})` in Neovim
- **THEN** it calls vim.fn.jobstart with the command array

#### Scenario: Execute command in Vim
- **WHEN** calling `job_start({"fred", "set_bool_val", "/path/file.md", "archive", "true"})` in Vim
- **THEN** it calls vim.fn.job_start with the command array

### Requirement: exec_content_menu dispatches actions for taxo_key_val items
The `exec_content_menu(action, item)` function SHALL handle actions for taxonomy key-value items.

#### Scenario: Archive taxo_key_val
- **WHEN** calling `exec_content_menu("archive", item)` where item.option_type is "taxo_key_val"
- **THEN** it calls the archive_l2_config function with taxo_key and taxo_term

### Requirement: exec_content_menu dispatches actions for document items
The `exec_content_menu(action, item)` function SHALL handle actions for document items.

#### Scenario: Set archive on document
- **WHEN** calling `exec_content_menu("set archive", item)` where item.option_type is "document"
- **THEN** it executes fred set_bool_val with archive=true

#### Scenario: Toggle starred on document
- **WHEN** calling `exec_content_menu("toggle starred", item)` where item.option_type is "document"
- **THEN** it executes fred toggle_bool_val for starred

#### Scenario: Copy document
- **WHEN** calling `exec_content_menu("copy", item)` where item.option_type is "document"
- **THEN** it prompts for a new name and calls the copy function

#### Scenario: Open docdir
- **WHEN** calling `exec_content_menu("open docdir", item)` where item.option_type is "document"
- **THEN** it creates the docdir if needed and opens it with the system file manager

#### Scenario: Set taxonomy with repeat pattern
- **WHEN** calling `exec_content_menu("set category: work", item)` where item.option_type is "document"
- **THEN** it executes fred set_string_val with the taxonomy and term extracted from the action string

### Requirement: build_dropdown_views returns action list for item type
The `build_dropdown_views(item)` function SHALL return the appropriate action list based on item type.

#### Scenario: Document item actions
- **WHEN** calling `build_dropdown_views(item)` where item.option_type is "document"
- **THEN** it returns a list including "copy", "archive", "set taxonomy", "remove taxonomy", "open docdir"

#### Scenario: Document item with repeat action
- **WHEN** calling `build_dropdown_views(item)` where item.option_type is "document" and a previous taxonomy was set
- **THEN** it includes the repeat action like "set category: work" in the list

#### Scenario: Taxo key-val item actions
- **WHEN** calling `build_dropdown_views(item)` where item.option_type is "taxo_key_val"
- **THEN** it returns a list containing "archive"

#### Scenario: Other item types
- **WHEN** calling `build_dropdown_views(item)` where item.option_type is neither "document" nor "taxo_key_val"
- **THEN** it returns an empty list
