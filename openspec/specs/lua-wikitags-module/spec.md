# lua-wikitags-module Specification

## Purpose
TBD - created by archiving change migrate-linny-wikitags-to-lua. Update Purpose after archive.
## Requirements
### Requirement: FILE wikitag opens file with system file manager

The wikitags module SHALL provide a `file` function that opens a file path with the OS file manager.

#### Scenario: Open file with file manager
- **WHEN** calling `require('linny.wikitags').file("~/Documents")`
- **THEN** the path SHALL be expanded
- **AND** the OS file manager SHALL be invoked with the expanded path

### Requirement: DIR wikitag creates directory and opens file manager

The wikitags module SHALL provide `dir1st` and `dir2nd` functions for directory operations.

#### Scenario: dir1st creates and opens directory
- **WHEN** calling `require('linny.wikitags').dir1st("/tmp/newdir")`
- **AND** the directory does not exist
- **THEN** the directory SHALL be created
- **AND** the OS file manager SHALL be opened to that directory

#### Scenario: dir2nd creates directory and opens NERDTree
- **WHEN** calling `require('linny.wikitags').dir2nd("/tmp/newdir")`
- **AND** NERDTree is available
- **THEN** the directory SHALL be created if needed
- **AND** NERDTree SHALL be opened to that directory

### Requirement: SHELL wikitag executes shell command

The wikitags module SHALL provide a `shell` function that executes a shell command.

#### Scenario: Execute shell command
- **WHEN** calling `require('linny.wikitags').shell("echo hello")`
- **THEN** the command SHALL be executed via Vim's `!` command

### Requirement: LIN wikitag opens menu term

The wikitags module SHALL provide a `linny` function that opens the linny menu.

#### Scenario: Open menu with taxonomy and term
- **WHEN** calling `require('linny.wikitags').linny("taxonomy:term")`
- **THEN** `linny_menu#openterm` SHALL be called with `("taxonomy", "term")`

#### Scenario: Open menu with taxonomy only
- **WHEN** calling `require('linny.wikitags').linny("taxonomy")`
- **THEN** `linny_menu#openterm` SHALL be called with `("taxonomy", "")`

### Requirement: VIM wikitag executes vim command

The wikitags module SHALL provide a `vim_cmd` function that executes a Vim command.

#### Scenario: Execute vim command
- **WHEN** calling `require('linny.wikitags').vim_cmd("edit foo.txt")`
- **THEN** the command SHALL be executed via `vim.cmd()`

### Requirement: Wikitags module accessible via require

The wikitags module SHALL be accessible as `require('linny.wikitags')`.

#### Scenario: Module is requireable
- **WHEN** Neovim loads with the plugin in runtimepath
- **THEN** `require('linny.wikitags')` SHALL return the module table
- **AND** the module SHALL have all wikitag functions

