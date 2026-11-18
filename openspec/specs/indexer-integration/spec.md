# indexer-integration Specification

## Purpose
Selects an index backend, builds the Linny JSON index for the open notebook, and
checks that the produced index is one this plugin can read.

## Requirements

### Requirement: Backend preference and fallback

The plugin SHALL prefer `lindexer` when available and SHALL use Hugo only when
`lindexer` is not found. When neither backend is available the plugin SHALL remain
usable and disable index rebuilds.

#### Scenario: lindexer preferred

- **WHEN** the plugin selects an index backend
- **AND** `lindexer` is on `PATH`
- **THEN** `lindexer` SHALL be selected
- **AND** Hugo SHALL NOT be invoked

#### Scenario: Hugo fallback

- **WHEN** the plugin selects an index backend
- **AND** `lindexer` is not on `PATH`
- **AND** `hugo` is on `PATH`
- **THEN** Hugo SHALL be selected
- **AND** a one-time notice SHALL recommend installing `lindexer`

#### Scenario: No backend installed

- **WHEN** the plugin selects an index backend
- **AND** neither `lindexer` nor `hugo` is on `PATH`
- **THEN** the selection SHALL report no backend
- **AND** the plugin SHALL NOT raise an error
- **AND** index rebuilds SHALL be skipped

### Requirement: Index build writes the notebook index

A rebuild SHALL run the selected backend against the open notebook and write the
index tree to `<notebook>/lindenIndex`, and SHALL report a failure without raising.

#### Scenario: Rebuild with lindexer

- **WHEN** a rebuild runs and `lindexer` is selected
- **AND** the notebook path is valid
- **THEN** the plugin SHALL run `lindexer build --corpus <notebook> --index <notebook>/lindenIndex`
- **AND** the result SHALL contain `ok = true` on success

#### Scenario: Rebuild failure

- **WHEN** a rebuild runs and the backend exits non-zero
- **THEN** the result SHALL contain `ok = false` and the backend output as `error`
- **AND** the plugin SHALL display a warning message

#### Scenario: Rebuild without a notebook

- **WHEN** a rebuild is requested without a notebook path
- **THEN** the result SHALL contain `ok = false` with `error = "No notebook path provided"`
- **AND** no backend SHALL be executed

### Requirement: Index format compatibility is checked

After a successful build the plugin SHALL read `_indexer_info.json` from the index
root and warn when the index-format version is absent or below the minimum the
plugin supports.

#### Scenario: Compatible index

- **WHEN** `_indexer_info.json` reports an `index_format_version` at or above the
  supported minimum
- **THEN** no compatibility warning SHALL be shown

#### Scenario: Missing format version

- **WHEN** `_indexer_info.json` lacks `index_format_version`
- **THEN** a warning SHALL name the backend and say the index format is unknown

#### Scenario: Unsupported format version

- **WHEN** `_indexer_info.json` reports an `index_format_version` below the supported
  minimum
- **THEN** a warning SHALL state the supported minimum and the reported version

### Requirement: Menu refresh rebuilds through the selected backend

The menu refresh action SHALL rebuild the index through the selected backend before
refreshing content, unless watch mode is active or index hooks are disabled.

#### Scenario: Refresh rebuilds with lindexer

- **WHEN** the user triggers a menu refresh
- **AND** a backend is selected
- **AND** watch mode is not active
- **AND** `g:linny_index_hook_enabled` is `1` (or unset)
- **THEN** the index SHALL be rebuilt before the view refreshes
- **AND** a status message SHALL indicate the rebuild

#### Scenario: Refresh when watch mode is active

- **WHEN** the user triggers a menu refresh
- **AND** watch mode is active
- **THEN** the view SHALL refresh without a manual rebuild

#### Scenario: Refresh when index hooks are disabled

- **WHEN** the user triggers a menu refresh
- **AND** `g:linny_index_hook_enabled` is `0`
- **THEN** the view SHALL refresh without detecting or running a backend

#### Scenario: Refresh when no backend is installed

- **WHEN** the user triggers a menu refresh
- **AND** no backend is available
- **THEN** the view SHALL refresh without a rebuild
- **AND** no error SHALL be displayed

### Requirement: Health reports the active backend

`require('linny.health').validate()` SHALL report the selected backend and its
version, and `:checkhealth linny` SHALL show that status. A missing backend SHALL be
a warning, not an error.

#### Scenario: Health with lindexer active

- **WHEN** health validation runs
- **AND** `lindexer` is available
- **THEN** the result SHALL include `indexer = {backend = "lindexer", available = true, version = "x.y.z"}`
- **AND** checkhealth SHALL report an OK status naming `lindexer`

#### Scenario: Health with Hugo fallback

- **WHEN** health validation runs
- **AND** only Hugo is available
- **THEN** the result SHALL name `hugo` as the backend
- **AND** checkhealth SHALL warn that `lindexer` is recommended

#### Scenario: Health without a backend

- **WHEN** health validation runs
- **AND** no backend is available
- **THEN** the result SHALL include `indexer = {available = false}`
- **AND** checkhealth SHALL warn that index features are disabled
- **AND** the overall result SHALL NOT become `ok = false` for this reason

#### Scenario: Hugo output-format validation only for Hugo

- **WHEN** health validation runs
- **AND** `lindexer` is the selected backend
- **THEN** Hugo output-format checks SHALL NOT run
