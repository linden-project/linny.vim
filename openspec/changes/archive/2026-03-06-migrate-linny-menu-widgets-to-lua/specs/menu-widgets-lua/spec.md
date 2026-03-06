## ADDED Requirements

### Requirement: Module is requireable
The `linny.menu.widgets` module SHALL be loadable via Lua's require system and accessible through the menu module hierarchy.

#### Scenario: Direct require
- **WHEN** calling `require('linny.menu.widgets')`
- **THEN** the module loads without error and returns a table with all widget functions

#### Scenario: Access via menu module
- **WHEN** calling `require('linny.menu').widgets`
- **THEN** the widgets submodule is accessible

#### Scenario: Access via main module
- **WHEN** calling `require('linny').menu.widgets`
- **THEN** the widgets submodule is accessible through the main module

### Requirement: recent_files returns recently modified files
The `recent_files(number)` function SHALL return a list of recently modified files from the wiki content directory.

#### Scenario: Get recent files
- **WHEN** calling `recent_files(5)`
- **THEN** it returns up to 5 most recently modified files from the content directory, excluding index files and .docdir

### Requirement: starred_terms_list returns starred terms from index
The `starred_terms_list()` function SHALL return the list of starred terms from the index file.

#### Scenario: Get starred terms
- **WHEN** calling `starred_terms_list()`
- **THEN** it returns the parsed contents of `_index_terms_starred.json`

#### Scenario: Empty starred terms
- **WHEN** calling `starred_terms_list()` and the index file is empty or missing
- **THEN** it returns an empty table

### Requirement: starred_docs_list returns starred documents from index
The `starred_docs_list()` function SHALL return the list of starred documents from the index file.

#### Scenario: Get starred docs
- **WHEN** calling `starred_docs_list()`
- **THEN** it returns the parsed contents of `_index_docs_starred.json`

#### Scenario: Empty starred docs
- **WHEN** calling `starred_docs_list()` and the index file is empty or missing
- **THEN** it returns an empty table

### Requirement: partial_files_listing renders file list to menu
The `partial_files_listing(files_list, view_props, bool_extra_file_info)` function SHALL render a list of files as menu items.

#### Scenario: Basic file listing
- **WHEN** calling `partial_files_listing(files, {sort = "az"}, false)`
- **THEN** it adds document items to the menu sorted alphabetically

#### Scenario: Date sorted listing
- **WHEN** calling `partial_files_listing(files, {sort = "date"}, false)`
- **THEN** it adds document items to the menu sorted by modification date (newest first)

#### Scenario: Listing with extra info and labels
- **WHEN** calling `partial_files_listing(files, {sort = "az", label = "{title}"}, true)`
- **THEN** it uses the label template to format document titles

#### Scenario: Listing with task counts
- **WHEN** calling `partial_files_listing(files, {}, true)` and files have task counts in `t:linny_tasks_count`
- **THEN** it appends task progress (e.g., "[3/5]") to document titles

### Requirement: starred_documents widget renders starred docs
The `starred_documents(widgetconf)` function SHALL render starred documents as menu items.

#### Scenario: Render starred documents
- **WHEN** calling `starred_documents({})`
- **THEN** it adds all starred documents to the menu sorted alphabetically

### Requirement: starred_terms widget renders starred terms
The `starred_terms(widgetconf)` function SHALL render starred terms as menu items.

#### Scenario: Render starred terms
- **WHEN** calling `starred_terms({})`
- **THEN** it adds all starred terms to the menu as taxonomy key-value items, sorted alphabetically

### Requirement: starred_taxonomies widget renders starred taxonomies
The `starred_taxonomies(widgetconf)` function SHALL render starred taxonomies as menu items.

#### Scenario: Render starred taxonomies
- **WHEN** calling `starred_taxonomies({})`
- **THEN** it adds all starred taxonomies to the menu as taxonomy key items, sorted alphabetically

### Requirement: all_taxonomies widget renders all taxonomies
The `all_taxonomies(widgetconf)` function SHALL render all taxonomies as menu items.

#### Scenario: Render all taxonomies
- **WHEN** calling `all_taxonomies({})`
- **THEN** it adds all taxonomies from the index to the menu, sorted alphabetically

### Requirement: recently_modified_documents widget renders recent docs
The `recently_modified_documents(widgetconf)` function SHALL render recently modified documents.

#### Scenario: Default number of recent docs
- **WHEN** calling `recently_modified_documents({})`
- **THEN** it adds the 5 most recently modified documents to the menu

#### Scenario: Custom number of recent docs
- **WHEN** calling `recently_modified_documents({number = 10})`
- **THEN** it adds the 10 most recently modified documents to the menu

### Requirement: all_level0_views widget renders view files
The `all_level0_views(widgetconf)` function SHALL render all level0 view configuration files.

#### Scenario: Render level0 views
- **WHEN** calling `all_level0_views({})`
- **THEN** it adds all .yml files from the views config directory to the menu, sorted alphabetically

### Requirement: menu widget renders custom menu items
The `menu(widgetconf)` function SHALL render custom menu items from configuration.

#### Scenario: Render menu with execute items
- **WHEN** calling `menu({items = {{title = "Open", execute = ":e file.md"}}})`
- **THEN** it adds an ex-command item to the menu with the specified title and command
