## ADDED Requirements

### Requirement: Export to zip context menu option
The document context menu in level 2 (term) menu SHALL include an "export to zip" option.

#### Scenario: Context menu shows export option
- **WHEN** user opens context menu on a document in term view
- **THEN** "export to zip" option appears in the action list

### Requirement: Export all term documents
The `actions.export_term_to_zip(output_path)` function SHALL create a zip archive containing all documents in the current term.

#### Scenario: Export term documents
- **WHEN** user selects "export to zip" and provides an output path
- **THEN** a zip file is created at that path containing all term documents

### Requirement: Folder structure prompt for group_by views
When the active view has `group_by` enabled, the system SHALL prompt the user to choose between flat export or preserving folder structure.

#### Scenario: Group by view prompts for structure
- **WHEN** user selects "export to zip" and current view has `group_by` active
- **THEN** a popup appears with options: "flat" and "preserve folders"

#### Scenario: Flat export ignores grouping
- **WHEN** user selects "flat" export option
- **THEN** all documents are placed in zip root without subdirectories

#### Scenario: Preserve folders uses group values
- **WHEN** user selects "preserve folders" export option
- **THEN** documents are organized into subdirectories matching their group values

### Requirement: Output path selection
The system SHALL prompt for output path using input dialog.

#### Scenario: Default output path
- **WHEN** export popup appears
- **THEN** default path is suggested based on term name (e.g., `~/Downloads/<term>.zip`)

#### Scenario: User specifies custom path
- **WHEN** user enters a custom path in the input dialog
- **THEN** zip file is created at the specified location

### Requirement: Export uses system zip command
The export function SHALL use the system `zip` command for creating archives.

#### Scenario: Zip command execution
- **WHEN** export is triggered
- **THEN** system executes `zip -r <output> <files>` asynchronously

#### Scenario: Zip command not available
- **WHEN** `zip` command is not found on system
- **THEN** error message is displayed to user

### Requirement: Module exports
The actions module SHALL export `export_term_to_zip` function.

#### Scenario: Require module
- **WHEN** `require('linny.menu.actions')` is called
- **THEN** the returned table includes `export_term_to_zip` function
