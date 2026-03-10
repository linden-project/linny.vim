# hugo-watch-process Specification

## Purpose

Background Hugo process management with `--watch` mode for automatic index rebuilding during editing sessions.
## Requirements
### Requirement: Start watch process

The `lua/linny/hugo.lua` module SHALL provide a `start_watch(notebook_path)` function that starts Hugo in watch mode.

#### Scenario: Start watch with valid notebook

- **WHEN** calling `require('linny.hugo').start_watch("/path/to/notebook")`
- **AND** Hugo is available
- **AND** the notebook path exists
- **AND** no watch process is currently running
- **THEN** the function SHALL start Hugo with `hugo --source /path/to/notebook --watch`
- **AND** return `{ok = true, job_id = <number>}`

#### Scenario: Start watch when already watching

- **WHEN** calling `require('linny.hugo').start_watch("/path/to/notebook")`
- **AND** a watch process is already running
- **THEN** the function SHALL return `{ok = false, error = "Watch already running"}`
- **AND** SHALL NOT start a second process

#### Scenario: Start watch when Hugo unavailable

- **WHEN** calling `require('linny.hugo').start_watch("/path/to/notebook")`
- **AND** Hugo is not available
- **THEN** the function SHALL return `{ok = false, error = "Hugo not found"}`

#### Scenario: Start watch with invalid notebook

- **WHEN** calling `require('linny.hugo').start_watch("/nonexistent/path")`
- **THEN** the function SHALL return `{ok = false, error = "Notebook path does not exist"}`

### Requirement: Stop watch process

The module SHALL provide a `stop_watch()` function to terminate the running Hugo watch process.

#### Scenario: Stop running watch

- **WHEN** calling `require('linny.hugo').stop_watch()`
- **AND** a watch process is running
- **THEN** the function SHALL terminate the Hugo process
- **AND** return `{ok = true}`

#### Scenario: Stop when not watching

- **WHEN** calling `require('linny.hugo').stop_watch()`
- **AND** no watch process is running
- **THEN** the function SHALL return `{ok = false, error = "No watch process running"}`

### Requirement: Query watch status

The module SHALL provide an `is_watching()` function to check if a watch process is active.

#### Scenario: Check status when watching

- **WHEN** calling `require('linny.hugo').is_watching()`
- **AND** a watch process is running
- **THEN** the function SHALL return `true`

#### Scenario: Check status when not watching

- **WHEN** calling `require('linny.hugo').is_watching()`
- **AND** no watch process is running
- **THEN** the function SHALL return `false`

### Requirement: Watch process cleanup on exit

The watch process SHALL be terminated when Neovim exits.

#### Scenario: Neovim exits with watch running

- **WHEN** user exits Neovim (`:q`, `:qa`, etc.)
- **AND** a watch process is running
- **THEN** the watch process SHALL be terminated
- **AND** no orphan Hugo process SHALL remain

### Requirement: Watch status display in menu

The LinnyMenu footer SHALL display the current Hugo watch status.

#### Scenario: Menu shows watching status

- **WHEN** the LinnyMenu is displayed
- **AND** a watch process is running
- **THEN** the footer SHALL include `[Hugo: watching]`

#### Scenario: Menu shows stopped status

- **WHEN** the LinnyMenu is displayed
- **AND** no watch process is running
- **THEN** the footer SHALL include `[Hugo: stopped]`

### Requirement: Auto-start watch on menu open

When enabled, watch mode SHALL start automatically on first LinnyMenu open.

#### Scenario: Auto-start enabled and menu opens first time

- **WHEN** `g:linny_hugo_watch_enabled` is set to `1`
- **AND** LinnyMenu is opened for the first time in the session
- **AND** Hugo is available
- **THEN** watch mode SHALL be started automatically

#### Scenario: Auto-start disabled

- **WHEN** `g:linny_hugo_watch_enabled` is not set or set to `0`
- **AND** LinnyMenu is opened
- **THEN** watch mode SHALL NOT be started automatically

#### Scenario: Auto-start on subsequent menu opens

- **WHEN** `g:linny_hugo_watch_enabled` is set to `1`
- **AND** LinnyMenu has been opened before in this session
- **THEN** watch mode SHALL NOT be started again (already running or user stopped it)

### Requirement: Manual watch commands

Vimscript commands SHALL be provided for manual watch control.

#### Scenario: Start watch via command

- **WHEN** user runs `:LinnyHugoWatch`
- **AND** Hugo is available
- **AND** notebook is configured
- **THEN** watch mode SHALL be started
- **AND** a success message SHALL be displayed

#### Scenario: Stop watch via command

- **WHEN** user runs `:LinnyHugoStop`
- **AND** watch is running
- **THEN** watch mode SHALL be stopped
- **AND** a confirmation message SHALL be displayed

