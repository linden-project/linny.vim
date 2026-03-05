## ADDED Requirements

### Requirement: Word to filename conversion

The wiki module SHALL provide a `word_to_filename` function that converts wiki words to filenames.

#### Scenario: Convert word to filename
- **WHEN** calling `require('linny.wiki').word_to_filename("My Document")`
- **THEN** the result SHALL be `"my_document.md"` (lowercase, spaces replaced)

#### Scenario: Handle special characters
- **WHEN** calling `require('linny.wiki').word_to_filename("Doc/With:Chars")`
- **THEN** slashes and colons SHALL be replaced with the space replace character

### Requirement: File existence check

The wiki module SHALL provide a `file_exists` function.

#### Scenario: Check existing file
- **WHEN** calling `require('linny.wiki').file_exists("/tmp")`
- **THEN** the result SHALL be true

#### Scenario: Check non-existing file
- **WHEN** calling `require('linny.wiki').file_exists("/nonexistent/path")`
- **THEN** the result SHALL be false

### Requirement: Wikitag detection

The wiki module SHALL provide a `wikitag_has_tag` function that detects wikitags in words.

#### Scenario: Detect FILE wikitag
- **GIVEN** `g:linny_wikitags_register` contains "FILE"
- **WHEN** calling `require('linny.wiki').wikitag_has_tag("FILE ~/Documents")`
- **THEN** the result SHALL be `"FILE"`

#### Scenario: No wikitag present
- **WHEN** calling `require('linny.wiki').wikitag_has_tag("regular link")`
- **THEN** the result SHALL be `""`

### Requirement: YAML frontmatter parsing

The wiki module SHALL provide functions for YAML frontmatter handling.

#### Scenario: Get YAML key under cursor
- **GIVEN** cursor is on a line with `category: value`
- **WHEN** calling `require('linny.wiki').yaml_key_under_cursor()`
- **THEN** the result SHALL be `"category"`

#### Scenario: Get YAML value under cursor
- **GIVEN** cursor is on a line with `category: value`
- **WHEN** calling `require('linny.wiki').yaml_val_under_cursor()`
- **THEN** the result SHALL be `"value"`

### Requirement: Wiki link navigation

The wiki module SHALL provide a `goto_link` function for navigating wiki links.

#### Scenario: Navigate to existing wiki link
- **WHEN** cursor is on `[[existing link]]`
- **AND** calling `require('linny.wiki').goto_link()`
- **THEN** the linked file SHALL be opened

#### Scenario: Create new file for non-existing link
- **WHEN** cursor is on `[[new link]]`
- **AND** the linked file does not exist
- **AND** calling `require('linny.wiki').goto_link()`
- **THEN** a new file SHALL be created and opened

### Requirement: Non-existing link highlighting

The wiki module SHALL provide a `find_non_existing_links` function.

#### Scenario: Highlight non-existing links
- **WHEN** calling `require('linny.wiki').find_non_existing_links()`
- **THEN** all `[[links]]` pointing to non-existing files SHALL be highlighted with 'Todo' highlight group

### Requirement: Return to previous position

The wiki module SHALL provide a `return_to_last` function.

#### Scenario: Return after navigation
- **WHEN** `goto_link()` was called previously
- **AND** calling `require('linny.wiki').return_to_last()`
- **THEN** cursor SHALL return to the previous buffer and position

### Requirement: Wiki module accessible via require

The wiki module SHALL be accessible as `require('linny.wiki')`.

#### Scenario: Module is requireable
- **WHEN** Neovim loads with the plugin in runtimepath
- **THEN** `require('linny.wiki')` SHALL return the module table
- **AND** the module SHALL have all wiki functions
