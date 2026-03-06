# menu-items-lua Specification

## Purpose
TBD - created by archiving change migrate-linny-menu-items-to-lua. Update Purpose after archive.
## Requirements
### Requirement: Module is requireable
The `linny.menu.items` module SHALL be loadable via Lua's require system and accessible through the menu module hierarchy.

#### Scenario: Direct require
- **WHEN** calling `require('linny.menu.items')`
- **THEN** the module loads without error and returns a table with all item functions

#### Scenario: Access via menu module
- **WHEN** calling `require('linny.menu').items`
- **THEN** the items submodule is accessible

#### Scenario: Access via main module
- **WHEN** calling `require('linny').menu.items`
- **THEN** the items submodule is accessible through the main module

### Requirement: item_default creates valid item structure
The `item_default()` function SHALL return a table with all required menu item fields initialized to their defaults.

#### Scenario: Default item structure
- **WHEN** calling `item_default()`
- **THEN** it returns a table with fields: mode=1, event='', text='', option_type='', option_data={}, key='', weight=0, help=''

#### Scenario: option_data is a valid Vim dictionary
- **WHEN** calling `item_default()` and accessing `option_data` from VimScript
- **THEN** `option_data` is a Vim Dictionary (not a List)

### Requirement: add_empty_line appends empty item
The `add_empty_line()` function SHALL append an empty item to the menu items list.

#### Scenario: Empty line added
- **WHEN** calling `add_empty_line()`
- **THEN** a default item (mode=1, empty text) is appended to `vim.t.linny_menu_items`

### Requirement: add_divider appends divider item
The `add_divider()` function SHALL append a divider line item.

#### Scenario: Divider added
- **WHEN** calling `add_divider()`
- **THEN** an item with text containing dashes is appended

### Requirement: add_header appends header item
The `add_header(text)` function SHALL append a header item with mode=3.

#### Scenario: Header text extraction
- **WHEN** calling `add_header("# My Header")`
- **THEN** an item with mode=3 and text="My Header" (without `#` prefix) is appended

### Requirement: add_footer appends footer item
The `add_footer(text)` function SHALL append a footer item with mode=4.

#### Scenario: Footer added
- **WHEN** calling `add_footer("Footer text")`
- **THEN** an item with mode=4 and text="Footer text" is appended

### Requirement: add_section appends section item
The `add_section(text)` function SHALL append an empty line followed by a section item with mode=2.

#### Scenario: Section added
- **WHEN** calling `add_section("## Section Name")`
- **THEN** an empty line is appended, followed by an item with mode=2 and text="Section Name"

### Requirement: add_text appends text item
The `add_text(text)` function SHALL append a text item with mode=1.

#### Scenario: Text added
- **WHEN** calling `add_text("Some text")`
- **THEN** an item with mode=1 and text="Some text" is appended

### Requirement: add_document appends document item
The `add_document(title, abs_path, keyboard_key, type)` function SHALL append a selectable document item.

#### Scenario: Document item structure
- **WHEN** calling `add_document("My Doc", "/path/to/doc.md", "d", "file")`
- **THEN** an item with mode=0, key="d", option_type="file", option_data.abs_path="/path/to/doc.md", and event containing the path is appended

### Requirement: add_document_taxo_key appends taxonomy item
The `add_document_taxo_key(taxo_key)` function SHALL append a taxonomy navigation item.

#### Scenario: Taxonomy item with count
- **WHEN** calling `add_document_taxo_key("projects")` with `g:linny_menu_display_taxo_count` enabled
- **THEN** an item with capitalized text including count (e.g., "Projects (5)") is appended

#### Scenario: Taxonomy item without count
- **WHEN** calling `add_document_taxo_key("projects")` with `g:linny_menu_display_taxo_count` disabled
- **THEN** an item with capitalized text without count ("Projects") is appended

### Requirement: add_document_taxo_key_val appends term item
The `add_document_taxo_key_val(taxo_key, taxo_term, display_taxonomy)` function SHALL append a taxonomy term navigation item.

#### Scenario: Term item with taxonomy displayed
- **WHEN** calling `add_document_taxo_key_val("project", "alpha", true)`
- **THEN** an item with text "Project: alpha" is appended

#### Scenario: Term item without taxonomy displayed
- **WHEN** calling `add_document_taxo_key_val("project", "alpha", false)`
- **THEN** an item with text "alpha" (no prefix) is appended

### Requirement: add_special_event appends event item
The `add_special_event(title, event_id, keyboard_key)` function SHALL append an item that triggers an event.

#### Scenario: Special event added
- **WHEN** calling `add_special_event("Refresh", "refresh", "r")`
- **THEN** an item with mode=0, text="Refresh", event="refresh", key="r" is appended

### Requirement: add_ex_event appends ex command item
The `add_ex_event(title, ex_event, keyboard_key)` function SHALL append an item that runs an ex command.

#### Scenario: Ex event added
- **WHEN** calling `add_ex_event("Open file", ":e file.md", "o")`
- **THEN** an item with mode=0, event=":e file.md", key="o" is appended

### Requirement: add_external_location appends external link item
The `add_external_location(title, location)` function SHALL append an item that opens an external location.

#### Scenario: External location added
- **WHEN** calling `add_external_location("Website", "https://example.com")`
- **THEN** an item with event="openexternal https://example.com" is appended

### Requirement: append inserts item by weight
The `append(item)` function SHALL insert items in weight-sorted order.

#### Scenario: Item inserted at correct position
- **WHEN** appending items with weights 10, 5, 15
- **THEN** items are ordered by weight: 5, 10, 15

#### Scenario: Equal weight items preserve insertion order
- **WHEN** appending items with same weight
- **THEN** items are appended at the end of same-weight items

### Requirement: list prints all items
The `list()` function SHALL print all items in the menu items list.

#### Scenario: List output
- **WHEN** calling `list()` with items in the list
- **THEN** each item is echoed to the command line

### Requirement: get_by_index returns item at index
The `get_by_index(index)` function SHALL return the item at the specified index from `t:linny_menu.items`.

#### Scenario: Valid index
- **WHEN** calling `get_by_index(0)` with items present
- **THEN** the first item is returned

#### Scenario: Invalid index
- **WHEN** calling `get_by_index(-1)` or index >= length
- **THEN** nil is returned

