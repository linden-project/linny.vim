## ADDED Requirements

### Requirement: Y hotkey in level 2 menu
The level 2 (term) menu SHALL have a `Y` hotkey that triggers bulk path copy.

#### Scenario: Press Y in term view
- **WHEN** user presses `Y` in level 2 menu
- **THEN** a format selection popup appears with "relative" and "absolute" options

### Requirement: Collect term document paths
The `actions.get_term_document_paths(tax, term)` function SHALL return all document paths for the given taxonomy term.

#### Scenario: Get paths for term
- **WHEN** `get_term_document_paths("category", "work")` is called
- **THEN** it returns a list of absolute paths for all documents in that term

### Requirement: Copy term paths to clipboard
The `actions.copy_term_paths_to_clipboard(format)` function SHALL copy all document paths in the current term to clipboard.

#### Scenario: Copy absolute paths
- **WHEN** user selects "absolute" format after pressing `Y`
- **THEN** all document paths are copied to clipboard (newline-separated)
- **AND** a confirmation message shows the count of paths copied

#### Scenario: Copy relative paths
- **WHEN** user selects "relative" format after pressing `Y`
- **THEN** all document paths relative to wiki content root are copied (newline-separated)
- **AND** a confirmation message shows the count of paths copied

### Requirement: Hotkey only in level 2
The `Y` hotkey SHALL only be mapped in level 2 (term) menu, not in level 0 or level 1.

#### Scenario: Y not available in level 1
- **WHEN** user presses `Y` in level 1 (taxonomy) menu
- **THEN** nothing happens (no mapping)

### Requirement: Module exports
The actions module SHALL export `get_term_document_paths` and `copy_term_paths_to_clipboard` functions.

#### Scenario: Require module
- **WHEN** `require('linny.menu.actions')` is called
- **THEN** the returned table includes the new term paths functions
