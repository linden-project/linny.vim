# configured-notebooks-widget Specification

## Purpose
TBD - created by archiving change add-notebook-list-config. Update Purpose after archive.
## Requirements
### Requirement: Widget displays configured notebooks

The `configured_notebooks` widget SHALL display all notebooks from `g:linny_notebooks` as menu items.

#### Scenario: Render configured notebooks

- **WHEN** calling `configured_notebooks({})`
- **AND** `g:linny_notebooks` contains `['/path/nb1', '/path/nb2']`
- **THEN** it SHALL add menu items for each notebook path

#### Scenario: Empty notebook list

- **WHEN** calling `configured_notebooks({})`
- **AND** `g:linny_notebooks` is empty or not set
- **THEN** it SHALL add no items to the menu

#### Scenario: Notebook item shows path basename

- **WHEN** a notebook item is rendered
- **THEN** the display title SHALL be the basename of the notebook path (e.g., `/home/user/notes` → `notes`)

### Requirement: Widget marks active notebook

The widget SHALL visually indicate which notebook is currently active.

#### Scenario: Active notebook is marked

- **WHEN** `configured_notebooks({})` is called
- **AND** `g:linny_open_notebook_path` matches a path in `g:linny_notebooks`
- **THEN** that notebook item SHALL be marked as active (e.g., with `*` prefix or highlight)

#### Scenario: No active notebook in list

- **WHEN** `configured_notebooks({})` is called
- **AND** `g:linny_open_notebook_path` is not in `g:linny_notebooks`
- **THEN** no notebook item SHALL be marked as active

### Requirement: Selecting notebook switches context

Selecting a notebook item SHALL switch Linny to that notebook.

#### Scenario: Switch to different notebook

- **WHEN** user selects a notebook item from the widget
- **AND** the notebook path differs from current `g:linny_open_notebook_path`
- **THEN** `g:linny_open_notebook_path` SHALL be set to the selected path
- **AND** Linny SHALL reinitialize with the new notebook

#### Scenario: Select already active notebook

- **WHEN** user selects the currently active notebook
- **THEN** no reinitialization SHALL occur

