# menu-command-semantics Specification

## Purpose
TBD - created by archiving change menu-command-clarity. Update Purpose after archive.
## Requirements
### Requirement: LinnyMenuOpen opens menu in last state

The `:LinnyMenuOpen` command SHALL open the menu restoring the previous view state.

#### Scenario: Menu was previously showing a taxonomy term

- **WHEN** user runs `:LinnyMenuOpen`
- **AND** menu was previously open showing taxonomy "project" term "alpha"
- **THEN** menu SHALL open showing taxonomy "project" term "alpha"

#### Scenario: Menu was never opened in session

- **WHEN** user runs `:LinnyMenuOpen`
- **AND** menu has never been opened in this session
- **THEN** menu SHALL open in root view (same as LinnyStart)

#### Scenario: Menu is already open

- **WHEN** user runs `:LinnyMenuOpen`
- **AND** menu is already open
- **THEN** nothing SHALL happen (menu remains as-is)

### Requirement: LinnyMenuClose closes and preserves state

The `:LinnyMenuClose` command SHALL close the menu while preserving state for next open.

#### Scenario: Close menu preserves state

- **WHEN** user runs `:LinnyMenuClose`
- **AND** menu is open showing taxonomy "project" term "alpha"
- **THEN** menu SHALL close
- **AND** state (taxonomy, term, view) SHALL be preserved

#### Scenario: Close when already closed

- **WHEN** user runs `:LinnyMenuClose`
- **AND** menu is not open
- **THEN** nothing SHALL happen

### Requirement: LinnyMenuToggle delegates to Open or Close

The `:LinnyMenuToggle` command SHALL only decide whether to open or close, delegating to the respective command.

#### Scenario: Toggle when closed

- **WHEN** user runs `:LinnyMenuToggle`
- **AND** menu is closed
- **THEN** it SHALL call `LinnyMenuOpen` behavior

#### Scenario: Toggle when open

- **WHEN** user runs `:LinnyMenuToggle`
- **AND** menu is open
- **THEN** it SHALL call `LinnyMenuClose` behavior

### Requirement: LinnyStart opens menu at root

The `:LinnyStart` command SHALL open the menu in start position (root view), resetting state.

#### Scenario: Start resets to root view

- **WHEN** user runs `:LinnyStart`
- **AND** menu state was previously showing taxonomy "project"
- **THEN** menu SHALL open in root view
- **AND** taxonomy/term state SHALL be cleared

#### Scenario: Start when menu is open

- **WHEN** user runs `:LinnyStart`
- **AND** menu is already open
- **THEN** menu SHALL navigate to root view
- **AND** state SHALL be reset

### Requirement: Hugo watch auto-start on first open

Hugo watch mode auto-start SHALL only trigger on `LinnyStart`, not on `LinnyMenuOpen`.

#### Scenario: LinnyStart triggers auto-start

- **WHEN** user runs `:LinnyStart`
- **AND** `g:linny_hugo_watch_enabled` is `1`
- **AND** this is the first menu open in the session
- **THEN** Hugo watch mode SHALL be started

#### Scenario: LinnyMenuOpen does not trigger auto-start

- **WHEN** user runs `:LinnyMenuOpen`
- **AND** `g:linny_hugo_watch_enabled` is `1`
- **THEN** Hugo watch mode SHALL NOT be started (preserves existing behavior)

