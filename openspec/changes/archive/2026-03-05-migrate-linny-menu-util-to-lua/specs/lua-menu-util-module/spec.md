## ADDED Requirements

### Requirement: String padding

The menu util module SHALL provide a `prepad` function that pads strings to a specified length.

#### Scenario: Pad string with spaces
- **WHEN** calling `require('linny.menu.util').prepad("5", 3)`
- **THEN** the result SHALL be `"  5"` (padded to 3 characters with spaces)

#### Scenario: Pad string with custom character
- **WHEN** calling `require('linny.menu.util').prepad("5", 3, "0")`
- **THEN** the result SHALL be `"005"` (padded with zeros)

### Requirement: Text expansion

The menu util module SHALL provide an `expand_text` function that evaluates `%{script}` expressions in strings.

#### Scenario: Expand expression in text
- **WHEN** calling `require('linny.menu.util').expand_text("Value: %{1+1}")`
- **THEN** the result SHALL be `"Value: 2"`

#### Scenario: Text without expressions unchanged
- **WHEN** calling `require('linny.menu.util').expand_text("Plain text")`
- **THEN** the result SHALL be `"Plain text"`

### Requirement: String truncation

The menu util module SHALL provide an `slimit` function that truncates strings to fit within a display width limit.

#### Scenario: Truncate long string
- **WHEN** calling `require('linny.menu.util').slimit("Hello World", 6, 0)`
- **THEN** the result SHALL have display width less than 6

#### Scenario: Short string unchanged
- **WHEN** calling `require('linny.menu.util').slimit("Hi", 10, 0)`
- **THEN** the result SHALL be `"Hi"`

### Requirement: Command message display

The menu util module SHALL provide a `cmdmsg` function that displays messages in the command line.

#### Scenario: Display message with highlight
- **WHEN** calling `require('linny.menu.util').cmdmsg("Hello", "WarningMsg")`
- **THEN** the message SHALL be displayed with the specified highlight group

### Requirement: Error message display

The menu util module SHALL provide an `errmsg` function that displays error messages.

#### Scenario: Display error message
- **WHEN** calling `require('linny.menu.util').errmsg("Error occurred")`
- **THEN** the message SHALL be displayed with ErrorMsg highlight

### Requirement: String capitalization

The menu util module SHALL provide a `string_capitalize` function that capitalizes the first character.

#### Scenario: Capitalize lowercase string
- **WHEN** calling `require('linny.menu.util').string_capitalize("hello")`
- **THEN** the result SHALL be `"Hello"`

#### Scenario: Handle already capitalized
- **WHEN** calling `require('linny.menu.util').string_capitalize("World")`
- **THEN** the result SHALL be `"World"`

### Requirement: Repeated character string

The menu util module SHALL provide a `string_of_length_with_char` function that creates strings of repeated characters.

#### Scenario: Create space padding
- **WHEN** calling `require('linny.menu.util').string_of_length_with_char(" ", 5)`
- **THEN** the result SHALL be `"     "` (5 spaces)

#### Scenario: Create dash line
- **WHEN** calling `require('linny.menu.util').string_of_length_with_char("-", 3)`
- **THEN** the result SHALL be `"---"` (3 dashes)

### Requirement: Active view arrow calculation

The menu util module SHALL provide a `calc_active_view_arrow` function for menu headers.

#### Scenario: Calculate arrow position
- **WHEN** calling `require('linny.menu.util').calc_active_view_arrow({"A", "BB", "CCC"}, 1, 2)`
- **THEN** the result SHALL contain an arrow character `▲` positioned under the active view

### Requirement: Module accessible via require

The menu util module SHALL be accessible as `require('linny.menu.util')`.

#### Scenario: Module is requireable
- **WHEN** Neovim loads with the plugin in runtimepath
- **THEN** `require('linny.menu.util')` SHALL return the module table
- **AND** the module SHALL have all utility functions
