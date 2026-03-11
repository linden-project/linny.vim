# hugo-integration Specification

## Purpose

Hugo executable integration for building and managing the Linny notebook index.
## Requirements
### Requirement: Hugo executable detection

The `lua/linny/hugo.lua` module SHALL provide a `detect()` function that locates the Hugo executable.

#### Scenario: Hugo found in PATH

- **WHEN** calling `require('linny.hugo').detect()`
- **AND** Hugo is installed and available in PATH
- **THEN** the function SHALL return `{found = true, path = "/path/to/hugo", version = "0.155.3"}`

#### Scenario: Hugo not found

- **WHEN** calling `require('linny.hugo').detect()`
- **AND** Hugo is not installed or not in PATH
- **THEN** the function SHALL return `{found = false, path = nil, version = nil}`

### Requirement: Hugo version parsing

The module SHALL parse Hugo's version string to extract the semantic version number.

#### Scenario: Parse extended version string

- **WHEN** Hugo outputs `hugo v0.155.3+extended+withdeploy linux/amd64 BuildDate=unknown`
- **THEN** the parsed version SHALL be `"0.155.3"`

#### Scenario: Parse simple version string

- **WHEN** Hugo outputs `hugo v0.120.0 linux/amd64`
- **THEN** the parsed version SHALL be `"0.120.0"`

### Requirement: Hugo build command execution

The module SHALL provide a `build_index(notebook_path)` function that runs Hugo with the correct options.

#### Scenario: Build index with valid notebook

- **WHEN** calling `require('linny.hugo').build_index("/path/to/notebook")`
- **AND** Hugo is available
- **AND** the notebook path exists and is valid
- **THEN** the function SHALL execute `hugo --source /path/to/notebook`
- **AND** return `{ok = true, output = "..."}`

#### Scenario: Build index with missing notebook

- **WHEN** calling `require('linny.hugo').build_index("/nonexistent/path")`
- **THEN** the function SHALL return `{ok = false, error = "Notebook path does not exist"}`
- **AND** Hugo SHALL NOT be executed

#### Scenario: Build index when Hugo unavailable

- **WHEN** calling `require('linny.hugo').build_index("/path/to/notebook")`
- **AND** Hugo is not available
- **THEN** the function SHALL return `{ok = false, error = "Hugo not found"}`

### Requirement: Notebook validation before index operations

The module SHALL validate that a notebook is set and valid before allowing index operations.

#### Scenario: Notebook not configured

- **WHEN** calling `require('linny.hugo').build_index(nil)`
- **THEN** the function SHALL return `{ok = false, error = "No notebook path provided"}`

#### Scenario: Notebook path is empty string

- **WHEN** calling `require('linny.hugo').build_index("")`
- **THEN** the function SHALL return `{ok = false, error = "No notebook path provided"}`

### Requirement: Index rebuild trigger from Vimscript

The module SHALL expose a Vimscript-callable function for triggering index rebuilds.

#### Scenario: Vimscript calls index rebuild

- **WHEN** calling `linny#hugo_rebuild_index()` from Vimscript
- **AND** `g:linny_open_notebook_path` is set to a valid notebook
- **THEN** the function SHALL call `require('linny.hugo').build_index()` with the notebook path
- **AND** display a message indicating success or failure

### Requirement: R key triggers index rebuild in views

The menu view refresh action SHALL trigger an index rebuild before refreshing content, unless watch mode is active OR hugo hooks are disabled.

#### Scenario: R key in menu view

- **WHEN** user presses R in a Linny menu view
- **AND** the notebook is valid
- **AND** Hugo is available
- **AND** watch mode is NOT active
- **AND** `g:linny_hugo_hook_enabled` is `1` (or unset)
- **THEN** the index SHALL be rebuilt before the view refreshes
- **AND** a status message SHALL indicate the rebuild is happening

#### Scenario: R key when Hugo unavailable

- **WHEN** user presses R in a Linny menu view
- **AND** Hugo is not available
- **THEN** the view SHALL refresh without rebuilding the index
- **AND** no error SHALL be displayed (graceful degradation)

#### Scenario: R key when watch mode is active

- **WHEN** user presses R in a Linny menu view
- **AND** watch mode is active (`hugo.is_watching()` returns true)
- **THEN** the view SHALL refresh without manually rebuilding the index
- **AND** no rebuild message SHALL be displayed
- **AND** the index is assumed current (watch handles rebuilds)

#### Scenario: R key when hugo hook is disabled

- **WHEN** user presses R in a Linny menu view
- **AND** `g:linny_hugo_hook_enabled` is `0`
- **THEN** the view SHALL refresh without any Hugo operations
- **AND** no Hugo detection SHALL occur
- **AND** no rebuild message SHALL be displayed

