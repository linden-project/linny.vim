# indexer-watch Specification

## Purpose
Runs a background indexing process so the notebook index stays current while the
user works, and reports the watch state in the menu.

## Requirements

### Requirement: Start watch process

Starting watch SHALL launch the selected backend in watch mode for the open
notebook, rebuilding the index tree on every change.

#### Scenario: Start watch with lindexer

- **WHEN** watch is started
- **AND** a notebook path is available
- **AND** `lindexer` is the selected backend
- **THEN** the plugin SHALL start `lindexer watch --corpus <notebook> --state-dir <cache> --index <notebook>/lindenIndex`
- **AND** `<cache>` SHALL be a directory under `stdpath('cache')/linny`
- **AND** the returned job id SHALL be stored as the active watch

#### Scenario: Watch start without a notebook

- **WHEN** watch is started without a notebook path
- **THEN** the plugin SHALL return an empty result
- **AND** no process SHALL be started

#### Scenario: Watch start while already watching

- **WHEN** watch is started
- **AND** a watch process is already active
- **THEN** the existing process SHALL be returned
- **AND** no second process SHALL be started

#### Scenario: Watch start without a backend

- **WHEN** watch is started
- **AND** no backend is available
- **THEN** the start SHALL fail with an error naming the missing backend
- **AND** no process SHALL be started

### Requirement: Stop watch process

Stopping watch SHALL terminate the active process and clear the stored job id.

#### Scenario: Stop an active watch

- **WHEN** watch is stopped
- **AND** a watch process is active
- **THEN** the plugin SHALL terminate the process
- **AND** the stored job id SHALL be cleared
- **AND** the result SHALL report `stopped = true`

#### Scenario: Stop when not watching

- **WHEN** watch is stopped
- **AND** no watch process is active
- **THEN** the result SHALL report `stopped = false`
- **AND** no error SHALL be raised

### Requirement: Query watch status

The plugin SHALL report whether a watch process is running and which backend owns
it.

#### Scenario: Status while watching

- **WHEN** watch status is queried
- **AND** a watch process is active
- **THEN** the result SHALL report `watching = true`
- **AND** the backend name SHALL be reported

#### Scenario: Status after the process exits

- **WHEN** watch status is queried
- **AND** the process has exited
- **THEN** the result SHALL report `watching = false`
- **AND** the stored job id SHALL be cleared

### Requirement: Watch process cleanup on exit

On `VimLeavePre` the plugin SHALL stop any active watch process so no orphaned
process outlives the editor.

#### Scenario: Neovim exits during watch

- **WHEN** Neovim exits
- **AND** a watch process is active
- **THEN** the process SHALL be terminated

### Requirement: Watch status display in menu

The menu footer SHALL show the watch state using the active backend name.

#### Scenario: Watching with lindexer

- **WHEN** the menu renders
- **AND** a watch process is active
- **THEN** the footer SHALL show `[Index: watching]`

#### Scenario: Not watching

- **WHEN** the menu renders
- **AND** no watch process is active
- **THEN** the footer SHALL show `[Index: stopped]`

### Requirement: Auto-start watch on menu open

When enabled, the plugin SHALL start watch automatically the first time the menu
opens in a session.

#### Scenario: Autostart enabled

- **WHEN** the menu opens
- **AND** `g:linny_index_watch_enabled` is `1`
- **AND** no watch has been started this session
- **THEN** watch SHALL start
- **AND** the attempt SHALL be recorded so later menu opens do not retry

#### Scenario: Autostart disabled

- **WHEN** the menu opens
- **AND** `g:linny_index_watch_enabled` is unset or `0`
- **THEN** no watch process SHALL start

#### Scenario: Autostart failure

- **WHEN** the menu opens
- **AND** `g:linny_index_watch_enabled` is `1`
- **AND** the watch backend is unavailable
- **THEN** the failure SHALL be recorded once
- **AND** the menu SHALL NOT display an error on every open

### Requirement: Manual watch commands

The plugin SHALL provide commands to start and stop watch, and SHALL keep the
Hugo-named commands as aliases.

#### Scenario: Start command

- **WHEN** the user runs `:LinnyIndexWatch`
- **THEN** watch SHALL start for the current notebook
- **AND** a status message SHALL report the outcome

#### Scenario: Stop command

- **WHEN** the user runs `:LinnyIndexStop`
- **THEN** watch SHALL stop
- **AND** a status message SHALL report the outcome

#### Scenario: Legacy command aliases

- **WHEN** the user runs `:LinnyHugoWatch` or `:LinnyHugoStop`
- **THEN** the command SHALL behave the same as `:LinnyIndexWatch` or `:LinnyIndexStop`
- **AND** no deprecation error SHALL be raised
