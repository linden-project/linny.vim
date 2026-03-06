## ADDED Requirements

### Requirement: Select items with auto-assigned keys
The `items.select_items()` function SHALL iterate through menu items and assign sequential keys to selectable items that don't have a key assigned.

#### Scenario: Auto-assign keys to keyless items
- **WHEN** `items.select_items()` is called
- **THEN** items with `mode == 0` and empty key get assigned keys starting from "1", zero-padded

#### Scenario: Preserve existing keys
- **WHEN** `items.select_items()` is called on items with existing keys
- **THEN** existing keys are preserved unchanged

### Requirement: Expand item for display
The `items.expand_item(item)` function SHALL format a menu item for display, adding key brackets and padding.

#### Scenario: Format selectable item
- **WHEN** `items.expand_item()` is called with a selectable item (mode == 0)
- **THEN** the item text is prefixed with `[key]` and left-padded according to `g:linny_menu_padding_left`

#### Scenario: Handle multi-line text
- **WHEN** `items.expand_item()` is called with item text containing newlines
- **THEN** each line is returned as a separate item, with only the first line showing the key

#### Scenario: Non-selectable items
- **WHEN** `items.expand_item()` is called with a non-selectable item (mode != 0)
- **THEN** the item text is returned with padding only, no key brackets

### Requirement: Build content for rendering
The `items.build_content()` function SHALL process all items through select and expand, returning display-ready content with calculated max width.

#### Scenario: Build full content list
- **WHEN** `items.build_content()` is called
- **THEN** it returns a table with `content` (list of expanded items) and `maxsize` (max display width)

### Requirement: Module exports
The items module SHALL export `select_items`, `expand_item`, and `build_content` in addition to existing exports.

#### Scenario: Require module
- **WHEN** `require('linny.menu.items')` is called
- **THEN** the returned table includes the new formatting functions plus existing exports
