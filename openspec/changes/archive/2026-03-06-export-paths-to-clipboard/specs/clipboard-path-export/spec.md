## ADDED Requirements

### Requirement: Copy path action in dropdown
The document context menu SHALL include a "copy path" action for document items.

#### Scenario: Show copy path option
- **WHEN** user opens context menu on a document item
- **THEN** "copy path" appears in the action list

### Requirement: Path format selection
After selecting "copy path", the system SHALL show a popup to choose between relative and absolute path formats.

#### Scenario: Show format options
- **WHEN** user selects "copy path" action
- **THEN** a popup appears with "relative" and "absolute" options

### Requirement: Copy absolute path
The system SHALL copy the full absolute path to clipboard when "absolute" is selected.

#### Scenario: Copy absolute path
- **WHEN** user selects "absolute" format
- **THEN** the document's `abs_path` is copied to the `+` register (system clipboard)
- **AND** a confirmation message is shown

### Requirement: Copy relative path
The system SHALL copy the path relative to wiki content root when "relative" is selected.

#### Scenario: Copy relative path
- **WHEN** user selects "relative" format
- **THEN** the path relative to `g:linny_path_wiki_content` is copied to the `+` register
- **AND** a confirmation message is shown

### Requirement: Clipboard unavailable handling
The system SHALL show an error message if clipboard is not available.

#### Scenario: No clipboard support
- **WHEN** user tries to copy path and `vim.fn.has('clipboard')` returns 0
- **THEN** an error message is shown with the path (so user can manually copy)

### Requirement: Module exports
The actions module SHALL export `copy_path_to_clipboard(item, format)` and `show_path_format_popup(item, line)` functions.

#### Scenario: Require module
- **WHEN** `require('linny.menu.actions')` is called
- **THEN** the returned table includes the new clipboard functions
