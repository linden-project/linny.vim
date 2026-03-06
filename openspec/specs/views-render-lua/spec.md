# views-render-lua Specification

## Purpose
TBD - created by archiving change migrate-linny-menu-views-render-to-lua. Update Purpose after archive.
## Requirements
### Requirement: View rendering
The `views.render(view_name)` function SHALL render all widgets for a view by iterating over the view's widget configuration and dispatching to the appropriate widget renderer.

#### Scenario: Render view with widgets
- **WHEN** `views.render(view_name)` is called with a valid view name
- **THEN** each non-hidden widget in the view config is rendered with its title as a section header

#### Scenario: Skip hidden widgets
- **WHEN** a widget has `hidden = true`
- **THEN** that widget is skipped and not rendered

#### Scenario: Handle unsupported widget type
- **WHEN** a widget has an unsupported type
- **THEN** an error section is added indicating the unsupported widget type

### Requirement: Widget type dispatch
The render function SHALL dispatch to the correct widget renderer based on widget type: `starred_documents`, `menu`, `starred_terms`, `starred_taxonomies`, `all_taxonomies`, `recently_modified_documents`, `all_level0_views`.

#### Scenario: Dispatch starred_documents
- **WHEN** widget type is "starred_documents"
- **THEN** `widgets.starred_documents(widget)` is called

#### Scenario: Dispatch menu
- **WHEN** widget type is "menu"
- **THEN** `widgets.menu(widget)` is called

### Requirement: Configuration link
After rendering widgets, the render function SHALL add a "Configuration" section with a link to edit the view's YAML configuration file.

#### Scenario: Add configuration link
- **WHEN** view rendering completes
- **THEN** a "Configuration" section is added with an "Edit this view" document link pointing to the view's config file

### Requirement: L1 dropdown creation
The `views.dropdown_l1()` function SHALL create a popup showing available L1 views for the current taxonomy, using the Lua popup module.

#### Scenario: Show L1 view dropdown
- **WHEN** `views.dropdown_l1()` is called
- **THEN** a popup is created with the list of views from the taxonomy config

### Requirement: L2 dropdown creation
The `views.dropdown_l2()` function SHALL create a popup showing available L2 views for the current taxonomy term, using the Lua popup module.

#### Scenario: Show L2 view dropdown
- **WHEN** `views.dropdown_l2()` is called
- **THEN** a popup is created with the list of views from the term config

### Requirement: Module exports
The views module SHALL export `render`, `dropdown_l1`, `dropdown_l2` functions in addition to existing exports.

#### Scenario: Require module
- **WHEN** `require('linny.menu.views')` is called
- **THEN** a table with render, dropdown_l1, dropdown_l2 (plus existing cycle_l1, cycle_l2, get_active, get_list) is returned

