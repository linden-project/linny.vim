# startup-health-check Specification

## Purpose

Provides comprehensive health validation for plugin configuration and initialization state, ensuring users have helpful guidance when setup is incomplete or invalid.
## Requirements
### Requirement: Core health validation in Lua

The `lua/linny/health.lua` module SHALL provide a `validate()` function as the single source of truth for configuration validation.

#### Scenario: Validate with valid notebook

- **WHEN** calling `require('linny.health').validate()`
- **AND** `g:linny_open_notebook_path` points to a valid notebook directory
- **AND** the notebook contains `content`, `lindenConfig`, and `lindenIndex` subdirectories
- **THEN** the function SHALL return `{ok = true, errors = {}}`

#### Scenario: Validate with missing notebook path

- **WHEN** calling `require('linny.health').validate()`
- **AND** `g:linny_open_notebook_path` is not set or empty
- **THEN** the function SHALL return `{ok = false, errors = {'Notebook path not configured'}}`

#### Scenario: Validate with non-existent notebook directory

- **WHEN** calling `require('linny.health').validate()`
- **AND** `g:linny_open_notebook_path` is set to `/nonexistent/path`
- **AND** the directory does not exist
- **THEN** the function SHALL return `{ok = false, errors = {'Notebook directory does not exist: /nonexistent/path'}}`

#### Scenario: Validate with missing subdirectories

- **WHEN** calling `require('linny.health').validate()`
- **AND** `g:linny_open_notebook_path` exists
- **AND** the `content` subdirectory is missing
- **THEN** the function SHALL return `{ok = false, errors = {'Missing directory: content'}}`

### Requirement: Vimscript health check wrapper

The `linny#health_check()` function SHALL be a thin wrapper that calls the Lua validation.

#### Scenario: Vimscript wrapper calls Lua

- **WHEN** calling `linny#health_check()`
- **THEN** the function SHALL call `require('linny.health').validate()` via luaeval
- **AND** return the result as a Vimscript dictionary

### Requirement: Commands check initialization before executing

User-facing commands SHALL verify initialization state and show helpful guidance when not initialized.

#### Scenario: LinnyStart called without initialization

- **WHEN** user runs `:LinnyStart`
- **AND** `g:linny_initialized` is 0 or unset
- **THEN** the command SHALL NOT crash with a Lua error
- **AND** the command SHALL display a warning message
- **AND** the message SHALL include setup instructions
- **AND** the message SHALL include the template URL: `https://github.com/linden-project/linny-notebook-template`

#### Scenario: LinnyMenuToggle called without initialization

- **WHEN** user runs `:LinnyMenuToggle`
- **AND** `g:linny_initialized` is 0 or unset
- **THEN** the command SHALL NOT crash with a Lua error
- **AND** the command SHALL display the same guidance as LinnyStart

#### Scenario: Command executes normally when initialized

- **WHEN** user runs `:LinnyStart`
- **AND** `g:linny_initialized` is 1
- **THEN** the command SHALL execute its normal functionality

### Requirement: Neovim checkhealth integration

The plugin SHALL integrate with Neovim's `:checkhealth` command via a `lua/linny/health.lua` module.

#### Scenario: Checkhealth with valid configuration

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** `g:linny_open_notebook_path` is configured correctly
- **AND** the notebook directory exists with all subdirectories
- **AND** `g:linny_initialized` is 1
- **THEN** all checks SHALL report OK status

#### Scenario: Checkhealth with missing notebook path

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** `g:linny_open_notebook_path` is not set or empty
- **THEN** an ERROR SHALL be reported with message "Notebook path not configured"
- **AND** advice SHALL include the template URL: `https://github.com/linden-project/linny-notebook-template`

#### Scenario: Checkhealth with non-existent notebook

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** `g:linny_open_notebook_path` points to a non-existent directory
- **THEN** an ERROR SHALL be reported with message including the path

#### Scenario: Checkhealth with missing subdirectory

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** the notebook directory exists
- **AND** the `content` subdirectory is missing
- **THEN** a WARN SHALL be reported for the missing subdirectory

#### Scenario: Checkhealth with uninitialized plugin

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** `g:linny_initialized` is 0 or unset
- **THEN** a WARN SHALL be reported with message "Plugin not initialized"

### Requirement: Menu toggle initializes tab state

The `LinnyMenuToggle` command SHALL initialize tab state before building menu content.

#### Scenario: LinnyMenuToggle as first command

- **WHEN** user runs `:LinnyMenuToggle` as the first Linny command
- **AND** `g:linny_initialized` is 1
- **AND** no other menu command has been run
- **THEN** the menu SHALL open without crashing
- **AND** tab state SHALL be initialized via `linny.menu.state.tab_init()`

### Requirement: Require init helper function

The `linny#require_init()` function SHALL provide centralized initialization checking for commands.

#### Scenario: Require init when initialized

- **WHEN** calling `linny#require_init()`
- **AND** `g:linny_initialized` is 1
- **THEN** the function SHALL return 1
- **AND** no message SHALL be displayed

#### Scenario: Require init when not initialized

- **WHEN** calling `linny#require_init()`
- **AND** `g:linny_initialized` is 0 or unset
- **THEN** the function SHALL return 0
- **AND** a warning message SHALL be displayed with setup instructions

### Requirement: Hugo availability validation

The health check system SHALL validate that Hugo is available on the system.

#### Scenario: Hugo is available

- **WHEN** calling `require('linny.health').validate()`
- **AND** Hugo is installed and in PATH
- **THEN** the result SHALL include `hugo = {available = true, version = "x.y.z"}`

#### Scenario: Hugo is not available

- **WHEN** calling `require('linny.health').validate()`
- **AND** Hugo is not installed or not in PATH
- **THEN** the result SHALL include `hugo = {available = false}`
- **AND** `errors` SHALL include `"Hugo not found (index features disabled)"`

### Requirement: Checkhealth reports Hugo status

The `:checkhealth linny` command SHALL report Hugo availability.

#### Scenario: Checkhealth with Hugo available

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** Hugo is installed
- **THEN** an OK status SHALL be reported with message including the Hugo version

#### Scenario: Checkhealth with Hugo missing

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** Hugo is not installed
- **THEN** a WARN status SHALL be reported with message "Hugo not found"
- **AND** advice SHALL explain that index/search features require Hugo
- **AND** advice SHALL include installation guidance

### Requirement: Hugo check is non-blocking

Missing Hugo SHALL NOT prevent plugin initialization or basic functionality.

#### Scenario: Plugin initializes without Hugo

- **WHEN** Linny initializes
- **AND** Hugo is not available
- **THEN** `g:linny_initialized` SHALL still be set to 1 (if notebook is valid)
- **AND** index-related features SHALL be gracefully disabled

### Requirement: Health check validates Hugo configuration

The health check system SHALL validate Hugo configuration when Hugo is available.

#### Scenario: Health check with valid Hugo configuration

- **WHEN** calling `require('linny.health').validate()`
- **AND** Hugo is available
- **AND** the notebook has valid Hugo configuration
- **THEN** the result SHALL include `hugo_config = {ok = true}`

#### Scenario: Health check with invalid Hugo configuration

- **WHEN** calling `require('linny.health').validate()`
- **AND** Hugo is available
- **AND** the notebook has invalid Hugo configuration
- **THEN** the result SHALL include `hugo_config = {ok = false, errors = [...]}`
- **AND** the overall result `ok` SHALL be false

#### Scenario: Health check skips config validation when Hugo unavailable

- **WHEN** calling `require('linny.health').validate()`
- **AND** Hugo is not available
- **THEN** Hugo configuration validation SHALL be skipped
- **AND** the result SHALL NOT contain `hugo_config` errors

### Requirement: Checkhealth reports Hugo configuration status

The `:checkhealth linny` command SHALL report Hugo configuration validation results.

#### Scenario: Checkhealth with valid Hugo configuration

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** Hugo is available
- **AND** Hugo configuration is valid
- **THEN** an OK status SHALL be reported with message "Hugo configuration valid"

#### Scenario: Checkhealth with invalid directory settings

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** Hugo is available
- **AND** `publishDir` is not `"lindenIndex"`
- **THEN** an ERROR status SHALL be reported
- **AND** the message SHALL include the expected and actual values
- **AND** advice SHALL reference the notebook template

#### Scenario: Checkhealth with missing output formats

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** Hugo is available
- **AND** required output formats are missing
- **THEN** a WARN status SHALL be reported for each missing format
- **AND** advice SHALL explain the format's purpose

#### Scenario: Checkhealth skips config when Hugo missing

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** Hugo is not available
- **THEN** Hugo configuration checks SHALL be skipped
- **AND** an INFO message SHALL indicate config validation was skipped

