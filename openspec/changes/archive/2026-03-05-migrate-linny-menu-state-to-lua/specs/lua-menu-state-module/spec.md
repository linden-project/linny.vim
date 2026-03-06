## ADDED Requirements

### Requirement: Tab state initialization

The menu state module SHALL provide a `tab_init` function that initializes tab-local menu state variables.

#### Scenario: Initialize tab state for new tab
- **WHEN** calling `require('linny.menu.state').tab_init()` on a tab without existing state
- **THEN** `vim.t.linny_menu_items` SHALL be set to an empty table
- **AND** `vim.t.linny_tasks_count` SHALL be set to an empty table
- **AND** `vim.t.linny_menu_cursor` SHALL be set to 0
- **AND** `vim.t.linny_menu_name` SHALL be set to a unique name containing the tab number
- **AND** `vim.t.linny_menu_line` SHALL be set to 0
- **AND** `vim.t.linny_menu_lastmaxsize` SHALL be set to 0
- **AND** `vim.t.linny_menu_view` SHALL be set to empty string
- **AND** `vim.t.linny_menu_taxonomy` SHALL be set to empty string
- **AND** `vim.t.linny_menu_term` SHALL be set to empty string

#### Scenario: Skip initialization if already initialized
- **WHEN** calling `require('linny.menu.state').tab_init()` on a tab with existing `vim.t.linny_menu_name`
- **THEN** the existing state SHALL NOT be modified

### Requirement: Unique tab number generation

The menu state module SHALL provide a `new_tab_nr` function that generates unique tab numbers.

#### Scenario: Generate unique tab number
- **WHEN** calling `require('linny.menu.state').new_tab_nr()`
- **THEN** the result SHALL be a number greater than the previous call
- **AND** `vim.g.linnytabnr` SHALL be incremented by 1

### Requirement: Read L1 taxonomy state

The menu state module SHALL provide a `term_leaf_state` function that reads L1 state from JSON files.

#### Scenario: Read existing L1 state
- **WHEN** calling `require('linny.menu.state').term_leaf_state("category")`
- **AND** the L1 state file exists
- **THEN** the result SHALL be the parsed JSON content

#### Scenario: Read non-existing L1 state
- **WHEN** calling `require('linny.menu.state').term_leaf_state("category")`
- **AND** the L1 state file does not exist
- **THEN** the result SHALL be an empty table

### Requirement: Read L2 taxonomy term state

The menu state module SHALL provide a `term_value_leaf_state` function that reads L2 state from JSON files.

#### Scenario: Read existing L2 state
- **WHEN** calling `require('linny.menu.state').term_value_leaf_state("category", "work")`
- **AND** the L2 state file exists
- **THEN** the result SHALL be the parsed JSON content

#### Scenario: Read non-existing L2 state
- **WHEN** calling `require('linny.menu.state').term_value_leaf_state("category", "work")`
- **AND** the L2 state file does not exist
- **THEN** the result SHALL be an empty table

### Requirement: Write L1 taxonomy state

The menu state module SHALL provide a `write_term_leaf_state` function that writes L1 state to JSON files.

#### Scenario: Write L1 state
- **WHEN** calling `require('linny.menu.state').write_term_leaf_state("category", {collapsed = true})`
- **THEN** the state SHALL be written to the L1 state file path as JSON

### Requirement: Write L2 taxonomy term state

The menu state module SHALL provide a `write_term_value_leaf_state` function that writes L2 state to JSON files.

#### Scenario: Write L2 state
- **WHEN** calling `require('linny.menu.state').write_term_value_leaf_state("category", "work", {collapsed = true})`
- **THEN** the state SHALL be written to the L2 state file path as JSON

### Requirement: Reset menu state

The menu state module SHALL provide a `reset` function that clears menu state variables.

#### Scenario: Reset menu state
- **WHEN** calling `require('linny.menu.state').reset()`
- **THEN** `vim.t.linny_menu_items` SHALL be set to an empty table
- **AND** `vim.t.linny_menu_line` SHALL be set to 0
- **AND** `vim.t.linny_menu_cursor` SHALL be set to 0

### Requirement: Module accessible via require

The menu state module SHALL be accessible as `require('linny.menu.state')`.

#### Scenario: Module is requireable
- **WHEN** Neovim loads with the plugin in runtimepath
- **THEN** `require('linny.menu.state')` SHALL return the module table
- **AND** the module SHALL have all state management functions
