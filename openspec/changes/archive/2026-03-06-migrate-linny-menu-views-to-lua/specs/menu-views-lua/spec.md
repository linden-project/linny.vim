## ADDED Requirements

### Requirement: Module is requireable
The `linny.menu.views` module SHALL be loadable via Lua's require system and accessible through the menu module hierarchy.

#### Scenario: Direct require
- **WHEN** calling `require('linny.menu.views')`
- **THEN** the module loads without error and returns a table with all view functions

#### Scenario: Access via menu module
- **WHEN** calling `require('linny.menu').views`
- **THEN** the views submodule is accessible

#### Scenario: Access via main module
- **WHEN** calling `require('linny').menu.views`
- **THEN** the views submodule is accessible through the main module

### Requirement: get_list extracts view names from config
The `get_list(config)` function SHALL return a list of view names from a configuration table.

#### Scenario: Config with views
- **WHEN** calling `get_list({views = {az = {...}, date = {...}}})`
- **THEN** it returns a list containing "az" and "date"

#### Scenario: Config without views
- **WHEN** calling `get_list({})`
- **THEN** it returns `{"NONE"}`

#### Scenario: Config with nil views
- **WHEN** calling `get_list({views = nil})`
- **THEN** it returns `{"NONE"}`

### Requirement: get_views extracts views dictionary from config
The `get_views(config)` function SHALL return a dictionary of view configurations.

#### Scenario: Config with views
- **WHEN** calling `get_views({views = {az = {sort = "az"}}})`
- **THEN** it returns `{az = {sort = "az"}}`

#### Scenario: Config without views
- **WHEN** calling `get_views({})`
- **THEN** it returns `{NONE = {sort = "az"}}`

### Requirement: get_active returns active view index from state
The `get_active(state)` function SHALL return the active view index from state.

#### Scenario: State with active_view
- **WHEN** calling `get_active({active_view = 2})`
- **THEN** it returns `2`

#### Scenario: State without active_view
- **WHEN** calling `get_active({})`
- **THEN** it returns `0`

#### Scenario: Empty state
- **WHEN** calling `get_active(nil)` or empty table
- **THEN** it returns `0`

### Requirement: current_props returns view properties
The `current_props(active_view, views_list, views)` function SHALL return the properties for the active view.

#### Scenario: Valid active view index
- **WHEN** calling `current_props(1, {"az", "date"}, {az = {sort = "az"}, date = {sort = "date"}})`
- **THEN** it returns `{sort = "date"}`

#### Scenario: Active view index out of bounds
- **WHEN** calling `current_props(5, {"az", "date"}, {az = {sort = "az"}, date = {sort = "date"}})`
- **THEN** it returns the first view's properties `{sort = "az"}`

### Requirement: new_active calculates next view index after cycling
The `new_active(state, views, direction, active_view)` function SHALL calculate the new active view index.

#### Scenario: Cycle forward within bounds
- **WHEN** calling `new_active({}, {"a", "b", "c"}, 1, 0)`
- **THEN** it returns state with `active_view = 1`

#### Scenario: Cycle forward wraps to beginning
- **WHEN** calling `new_active({}, {"a", "b", "c"}, 1, 2)`
- **THEN** it returns state with `active_view = 0`

#### Scenario: Cycle backward within bounds
- **WHEN** calling `new_active({}, {"a", "b", "c"}, -1, 2)`
- **THEN** it returns state with `active_view = 1`

#### Scenario: Cycle backward wraps to end
- **WHEN** calling `new_active({}, {"a", "b", "c"}, -1, 0)`
- **THEN** it returns state with `active_view = 2`

### Requirement: cycle_l1 cycles taxonomy level view
The `cycle_l1(direction)` function SHALL cycle the view for the current taxonomy.

#### Scenario: Cycle L1 view forward
- **WHEN** calling `cycle_l1(1)` with a taxonomy selected
- **THEN** the state is updated with the next view index and persisted

#### Scenario: Cycle L1 view backward
- **WHEN** calling `cycle_l1(-1)` with a taxonomy selected
- **THEN** the state is updated with the previous view index and persisted

### Requirement: cycle_l2 cycles term level view
The `cycle_l2(direction)` function SHALL cycle the view for the current taxonomy term.

#### Scenario: Cycle L2 view forward
- **WHEN** calling `cycle_l2(1)` with a taxonomy and term selected
- **THEN** the state is updated with the next view index and persisted

#### Scenario: Cycle L2 view backward
- **WHEN** calling `cycle_l2(-1)` with a taxonomy and term selected
- **THEN** the state is updated with the previous view index and persisted
