## ADDED Requirements

### Requirement: Item dropdown creation
The `actions.dropdown_item()` function SHALL create a popup showing available actions for the current item stored in `vim.t.linny_menu_item_for_dropdown`.

#### Scenario: Show item dropdown
- **WHEN** `actions.dropdown_item()` is called
- **THEN** a popup is created with actions from `build_dropdown_views()` and callback `linny_menu_actions#dropdown_item_callback`

#### Scenario: Empty dropdown
- **WHEN** `actions.dropdown_item()` is called and `build_dropdown_views()` returns empty
- **THEN** no popup is created

### Requirement: Set taxonomy popup
The `actions.show_set_taxonomy(item, name, line)` function SHALL create a popup showing available taxonomies for selection.

#### Scenario: Show taxonomy list
- **WHEN** `actions.show_set_taxonomy()` is called
- **THEN** a popup is created with sorted taxonomy list and callback `linny_menu_actions#dropdown_taxo_item_callback`

### Requirement: Remove taxonomy popup
The `actions.show_remove_taxonomy(item, name, line)` function SHALL create a popup showing taxonomies that can be removed.

#### Scenario: Show taxonomy removal list
- **WHEN** `actions.show_remove_taxonomy()` is called
- **THEN** a popup is created with sorted taxonomy list and callback `linny_menu_actions#dropdown_remove_taxo_item_callback`

### Requirement: Term selection popup
The `actions.show_term_selection(name, taxo, terms, line)` function SHALL create a popup showing terms for the selected taxonomy.

#### Scenario: Show term list
- **WHEN** `actions.show_term_selection()` is called
- **THEN** a popup is created with sorted terms and callback `linny_menu_actions#dropdown_term_item_callback`

### Requirement: Module exports
The actions module SHALL export `dropdown_item`, `show_set_taxonomy`, `show_remove_taxonomy`, `show_term_selection` in addition to existing exports.

#### Scenario: Require module
- **WHEN** `require('linny.menu.actions')` is called
- **THEN** the returned table includes the new dropdown functions plus existing exports
