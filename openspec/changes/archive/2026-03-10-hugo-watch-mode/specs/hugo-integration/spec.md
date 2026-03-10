# hugo-integration Delta Specification

## MODIFIED Requirements

### Requirement: R key triggers index rebuild in views

The menu view refresh action SHALL trigger an index rebuild before refreshing content, unless watch mode is active.

#### Scenario: R key in menu view

- **WHEN** user presses R in a Linny menu view
- **AND** the notebook is valid
- **AND** Hugo is available
- **AND** watch mode is NOT active
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
