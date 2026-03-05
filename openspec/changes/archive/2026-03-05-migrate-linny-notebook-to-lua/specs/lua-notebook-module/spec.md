## ADDED Requirements

### Requirement: Notebook init sets global path variables

The notebook module SHALL provide an `init` function that configures global path variables.

#### Scenario: Init sets content path
- **WHEN** calling `require('linny.notebook').init()`
- **AND** `g:linny_open_notebook_path` is set to `/path/to/notebook`
- **THEN** `g:linny_path_wiki_content` SHALL be set to `/path/to/notebook/content`
- **AND** `g:linny_path_wiki_config` SHALL be set to `/path/to/notebook/lindenConfig`
- **AND** `g:linny_index_path` SHALL be set to `/path/to/notebook/lindenIndex`

### Requirement: Notebook open validates and initializes notebook

The notebook module SHALL provide an `open` function that opens a notebook by path.

#### Scenario: Open with valid path
- **WHEN** calling `require('linny.notebook').open("/valid/path")`
- **AND** the path is a valid directory
- **THEN** `g:linny_open_notebook_path` SHALL be set to the expanded path
- **AND** `linny#Init()` SHALL be called
- **AND** `linny_menu#start()` SHALL be called
- **AND** the function SHALL return true

#### Scenario: Open with invalid path
- **WHEN** calling `require('linny.notebook').open("/invalid/path")`
- **AND** the path does not exist
- **THEN** an error message SHALL be displayed
- **AND** the function SHALL return false

#### Scenario: Open with empty path prompts user
- **WHEN** calling `require('linny.notebook').open("")`
- **THEN** the user SHALL be prompted to enter a path

### Requirement: Notebook module accessible via require

The notebook module SHALL be accessible as `require('linny.notebook')`.

#### Scenario: Module is requireable
- **WHEN** Neovim loads with the plugin in runtimepath
- **THEN** `require('linny.notebook')` SHALL return the module table
- **AND** the module SHALL have init and open functions
