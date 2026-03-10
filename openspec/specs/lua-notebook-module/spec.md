# lua-notebook-module Specification

## Purpose
TBD - created by archiving change migrate-linny-notebook-to-lua. Update Purpose after archive.
## Requirements
### Requirement: Notebook init sets global path variables

The notebook module SHALL provide an `init` function that configures global path variables and validates the notebook structure. The init function operates silently to support auto-initialization at startup.

#### Scenario: Init sets content path
- **WHEN** calling `require('linny.notebook').init()`
- **AND** `g:linny_open_notebook_path` is set to `/path/to/notebook`
- **AND** the notebook directory exists
- **THEN** `g:linny_path_wiki_content` SHALL be set to `/path/to/notebook/content`
- **AND** `g:linny_path_wiki_config` SHALL be set to `/path/to/notebook/lindenConfig`
- **AND** `g:linny_index_path` SHALL be set to `/path/to/notebook/lindenIndex`
- **AND** the function SHALL return true

#### Scenario: Init with non-existent notebook path

- **WHEN** calling `require('linny.notebook').init()`
- **AND** `g:linny_open_notebook_path` is set to `/nonexistent/path`
- **AND** the directory does not exist
- **THEN** the function SHALL return false
- **AND** no error message SHALL be displayed (silent operation)
- **AND** the path variables SHALL NOT be set

#### Scenario: Init with nil notebook path

- **WHEN** calling `require('linny.notebook').init()`
- **AND** `g:linny_open_notebook_path` is nil or empty
- **THEN** the function SHALL return false
- **AND** no error message SHALL be displayed (silent operation)
- **AND** no Lua error SHALL be thrown

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

### Requirement: Auto-initialization at plugin load

The plugin SHALL automatically call `linny#Init()` when loaded, silently setting `g:linny_initialized` based on configuration validity.

#### Scenario: Plugin loads with valid notebook configured

- **WHEN** the plugin is loaded at Vim/Neovim startup
- **AND** `g:linny_open_notebook_path` is set to a valid notebook directory
- **THEN** `g:linny_initialized` SHALL be 1
- **AND** no messages SHALL be displayed

#### Scenario: Plugin loads without notebook configured

- **WHEN** the plugin is loaded at Vim/Neovim startup
- **AND** `g:linny_open_notebook_path` is not set or empty
- **THEN** `g:linny_initialized` SHALL be 0
- **AND** no messages SHALL be displayed
- **AND** user SHALL see helpful message when running a Linny command

### Requirement: Notebook open only starts menu on successful initialization

The `open` function SHALL only start the menu if initialization completes successfully.

#### Scenario: Open with valid directory but missing required subdirectories

- **WHEN** calling `require('linny.notebook').open("/path/to/empty/dir")`
- **AND** the directory exists
- **AND** the directory is missing required subdirectories (content, lindenConfig)
- **THEN** an error message SHALL be displayed
- **AND** the menu SHALL NOT be opened
- **AND** the function SHALL return false

#### Scenario: Open with fully valid notebook

- **WHEN** calling `require('linny.notebook').open("/path/to/valid/notebook")`
- **AND** the directory exists with all required subdirectories
- **THEN** `linny#Init()` SHALL be called
- **AND** `g:linny_initialized` SHALL be 1
- **AND** the menu SHALL be opened
- **AND** the function SHALL return true

