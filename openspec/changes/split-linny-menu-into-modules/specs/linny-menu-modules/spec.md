## MODIFIED Requirements

### Requirement: Linny menu module structure

The linny_menu functionality SHALL be organized into focused autoload modules.

#### Scenario: All modules exist
- **WHEN** the plugin is installed
- **THEN** `autoload/linny_menu_state.vim` SHALL exist
- **AND** `autoload/linny_menu_window.vim` SHALL exist
- **AND** `autoload/linny_menu_items.vim` SHALL exist
- **AND** `autoload/linny_menu_render.vim` SHALL exist
- **AND** `autoload/linny_menu_views.vim` SHALL exist
- **AND** `autoload/linny_menu_widgets.vim` SHALL exist
- **AND** `autoload/linny_menu_keymaps.vim` SHALL exist
- **AND** `autoload/linny_menu_actions.vim` SHALL exist
- **AND** `autoload/linny_menu_documents.vim` SHALL exist
- **AND** `autoload/linny_menu_util.vim` SHALL exist

#### Scenario: Backward compatible API
- **WHEN** external code calls `linny_menu#start()`
- **THEN** it SHALL work as before (via compatibility shim)
- **AND** `linny_menu#open()` SHALL work
- **AND** `linny_menu#close()` SHALL work
- **AND** `linny_menu#toggle()` SHALL work
- **AND** `linny_menu#openterm()` SHALL work
- **AND** `linny_menu#openview()` SHALL work

### Requirement: Tab-local state preserved

The menu SHALL maintain separate state per tab.

#### Scenario: Multiple tabs with different menu states
- **GIVEN** two tabs are open
- **WHEN** tab 1 navigates to taxonomy "projects"
- **AND** tab 2 navigates to taxonomy "tags"
- **THEN** tab 1 SHALL show "projects" menu
- **AND** tab 2 SHALL show "tags" menu
- **AND** switching tabs SHALL restore correct menu state

### Requirement: All menu functionality works

All existing menu features SHALL work after the split.

#### Scenario: Menu navigation
- **WHEN** user opens the menu
- **THEN** level 0 (home/views) SHALL render correctly
- **AND** level 1 (taxonomy terms) SHALL render correctly
- **AND** level 2 (term documents) SHALL render correctly

#### Scenario: Keyboard navigation
- **WHEN** user presses navigation keys
- **THEN** cursor movement SHALL work
- **AND** Enter to open SHALL work
- **AND** hotkeys (0, u, v, etc.) SHALL work

#### Scenario: View cycling
- **WHEN** user cycles views with 'v' key
- **THEN** views SHALL cycle correctly
- **AND** dropdown view selection SHALL work

#### Scenario: Document actions
- **WHEN** user opens action menu on a document
- **THEN** copy, archive, set taxonomy actions SHALL work
- **AND** document creation SHALL work

#### Scenario: Widgets
- **WHEN** a view contains widgets
- **THEN** starred documents widget SHALL render
- **AND** starred terms widget SHALL render
- **AND** recent documents widget SHALL render
- **AND** all taxonomies widget SHALL render
