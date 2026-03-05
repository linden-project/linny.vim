## ADDED Requirements

### Requirement: Create directory if not exists

The fs module SHALL provide a function to create a directory and its parents if they don't exist.

#### Scenario: Directory does not exist
- **WHEN** calling `require('linny.fs').dir_create_if_not_exist("/tmp/test/nested/path")`
- **AND** the directory does not exist
- **THEN** the directory and all parent directories SHALL be created

#### Scenario: Directory already exists
- **WHEN** calling `require('linny.fs').dir_create_if_not_exist("/tmp")`
- **AND** the directory already exists
- **THEN** no error SHALL occur
- **AND** the directory SHALL remain unchanged

### Requirement: Open path with OS file manager

The fs module SHALL provide a function to open a path with the operating system's default file manager.

#### Scenario: Open on Linux/Unix
- **WHEN** calling `require('linny.fs').os_open_with_filemanager("/some/path")`
- **AND** the OS is Unix-like (Linux, BSD)
- **THEN** `xdg-open` SHALL be invoked with the path
- **AND** the process SHALL run asynchronously (not blocking Neovim)

#### Scenario: Open on macOS
- **WHEN** calling `require('linny.fs').os_open_with_filemanager("/some/path")`
- **AND** the OS is macOS
- **THEN** `open` SHALL be invoked with the path
- **AND** the process SHALL run asynchronously

### Requirement: FS module accessible via require

The fs module SHALL be accessible as `require('linny.fs')`.

#### Scenario: Module is requireable
- **WHEN** Neovim loads with the plugin in runtimepath
- **THEN** `require('linny.fs')` SHALL return the module table
- **AND** the module SHALL have `dir_create_if_not_exist` function
- **AND** the module SHALL have `os_open_with_filemanager` function
