## ADDED Requirements

### Requirement: Initialization state tracking

The plugin SHALL track whether initialization completed successfully via `g:linny_initialized`.

#### Scenario: Plugin loads without Init called

- **WHEN** the plugin is loaded at Vim/Neovim startup
- **AND** `linny#Init()` has not been called
- **THEN** `g:linny_initialized` SHALL be 0 or unset

#### Scenario: Successful initialization sets flag

- **WHEN** `linny#Init()` completes successfully
- **AND** all required directories exist
- **THEN** `g:linny_initialized` SHALL be set to 1

#### Scenario: Failed initialization does not set flag

- **WHEN** `linny#Init()` is called
- **AND** `linny#setup_paths()` returns failure (required directory missing)
- **THEN** `g:linny_initialized` SHALL remain 0
- **AND** an error message SHALL be displayed

### Requirement: Fatal directory check returns error state

The `linny#fatal_check_dir()` function SHALL return a boolean indicating success or failure.

#### Scenario: Directory exists

- **WHEN** calling `linny#fatal_check_dir('/existing/directory')`
- **AND** the directory exists
- **THEN** the function SHALL return 1

#### Scenario: Directory does not exist

- **WHEN** calling `linny#fatal_check_dir('/nonexistent/directory')`
- **AND** the directory does not exist
- **THEN** the function SHALL return 0
- **AND** an error message SHALL be displayed using `echohl ErrorMsg`
- **AND** the message SHALL include the path that does not exist

### Requirement: Lua path functions handle nil safely

All path construction functions in `lua/linny/paths.lua` SHALL handle nil path variables without crashing.

#### Scenario: Path function called with nil base path

- **WHEN** calling a path function like `paths.l1_index_filepath('taxonomy')`
- **AND** `vim.g.linny_index_path` is nil
- **THEN** the function SHALL return nil
- **AND** no Lua error SHALL be thrown

#### Scenario: Path function called with valid base path

- **WHEN** calling `paths.l1_index_filepath('taxonomy')`
- **AND** `vim.g.linny_index_path` is `/path/to/index`
- **THEN** the function SHALL return `/path/to/index/taxonomy/index.json`
