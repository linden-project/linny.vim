## ADDED Requirements

### Requirement: Module is requireable
The `linny.menu.render` module SHALL be loadable via Lua's require system and accessible through the menu module hierarchy.

#### Scenario: Direct require
- **WHEN** calling `require('linny.menu.render')`
- **THEN** the module loads without error and returns a table with all render functions

#### Scenario: Access via menu module
- **WHEN** calling `require('linny.menu').render`
- **THEN** the render submodule is accessible

#### Scenario: Access via main module
- **WHEN** calling `require('linny').menu.render`
- **THEN** the render submodule is accessible through the main module

### Requirement: level0 renders root view
The `level0(view_name)` function SHALL render the root/view level menu.

#### Scenario: Render root view
- **WHEN** calling `level0("root")`
- **THEN** it sets menu type to "menu_level0", resets state, and calls views render

### Requirement: level1 renders taxonomy level
The `level1(tax)` function SHALL render the taxonomy level menu with terms.

#### Scenario: Render taxonomy
- **WHEN** calling `level1("project")`
- **THEN** it displays navigation, view selector, and lists all terms for that taxonomy

#### Scenario: Group by support
- **WHEN** view props include group_by
- **THEN** terms are grouped by the specified property

#### Scenario: View cycling
- **WHEN** taxonomy has multiple views
- **THEN** it displays view selector with cycle or dropdown based on count

### Requirement: level2 renders term level
The `level2(tax, term)` function SHALL render the term level menu with documents.

#### Scenario: Render term
- **WHEN** calling `level2("project", "my-project")`
- **THEN** it displays navigation, info text, view selector, documents, and config options

#### Scenario: Mount support
- **WHEN** term config has mounts
- **THEN** it displays mounted files from external directories

#### Scenario: Locations support
- **WHEN** term config has locations
- **THEN** it displays external location links

### Requirement: partial_debug_info renders debug section
The `partial_debug_info()` function SHALL render debug information.

#### Scenario: Display debug info
- **WHEN** calling `partial_debug_info()`
- **THEN** it displays menu state variables and index information

### Requirement: partial_footer_items renders footer
The `partial_footer_items()` function SHALL render footer items.

#### Scenario: Display footer
- **WHEN** calling `partial_footer_items()`
- **THEN** it displays refresh, home, help links and version information

### Requirement: display_file_ask_view_props filters by view
The `display_file_ask_view_props(view_props, file_dict)` function SHALL determine if file should be displayed.

#### Scenario: No filters
- **WHEN** view_props has no except or only rules
- **THEN** it returns true (display file)

#### Scenario: Except filter matches
- **WHEN** view_props.except matches file_dict
- **THEN** it returns false (hide file)

#### Scenario: Only filter matches
- **WHEN** view_props.only matches file_dict
- **THEN** it returns true (display file)

#### Scenario: Only filter does not match
- **WHEN** view_props.only does not match file_dict
- **THEN** it returns false (hide file)

### Requirement: test_file_with_display_expression tests conditions
The `test_file_with_display_expression(file_dict, expr)` function SHALL test a file against a display expression.

#### Scenario: IS_SET condition true
- **WHEN** expr is `{key: "IS_SET"}` and file_dict has key
- **THEN** it returns true

#### Scenario: IS_SET condition false
- **WHEN** expr is `{key: "IS_SET"}` and file_dict lacks key
- **THEN** it returns false

#### Scenario: IS_NOT_SET condition true
- **WHEN** expr is `{key: "IS_NOT_SET"}` and file_dict lacks key
- **THEN** it returns true

#### Scenario: Value match
- **WHEN** expr is `{key: "value"}` and file_dict[key] equals "value"
- **THEN** it returns true

#### Scenario: Value mismatch
- **WHEN** expr is `{key: "value"}` and file_dict[key] differs
- **THEN** it returns false
