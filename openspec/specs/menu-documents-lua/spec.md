# menu-documents-lua Specification

## Purpose
TBD - created by archiving change migrate-linny-menu-documents-to-lua. Update Purpose after archive.
## Requirements
### Requirement: Module is requireable
The `linny.menu.documents` module SHALL be loadable via Lua's require system and accessible through the menu module hierarchy.

#### Scenario: Direct require
- **WHEN** calling `require('linny.menu.documents')`
- **THEN** the module loads without error and returns a table with all document functions

#### Scenario: Access via menu module
- **WHEN** calling `require('linny.menu').documents`
- **THEN** the documents submodule is accessible

#### Scenario: Access via main module
- **WHEN** calling `require('linny').menu.documents`
- **THEN** the documents submodule is accessible through the main module

### Requirement: replace_frontmatter_key modifies frontmatter
The `replace_frontmatter_key(file_lines, key, new_value)` function SHALL replace a key's value in YAML frontmatter.

#### Scenario: Replace existing key
- **WHEN** calling `replace_frontmatter_key(lines, "title", "New Title")` on a file with `title: Old Title`
- **THEN** the line is replaced with `title: New Title`

#### Scenario: Key within frontmatter boundaries
- **WHEN** the file has frontmatter delimited by `---`
- **THEN** only keys within the frontmatter section are modified

### Requirement: copy duplicates document with new title
The `copy(source_path, new_title)` function SHALL create a copy of a document with a new title.

#### Scenario: Successful copy
- **WHEN** calling `copy("/path/to/doc.md", "New Document")`
- **THEN** it creates a new file with the title replaced in frontmatter and opens it

#### Scenario: Source not readable
- **WHEN** calling `copy("/nonexistent.md", "New Doc")`
- **THEN** it displays an error message

#### Scenario: Target already exists
- **WHEN** calling `copy("/path/to/doc.md", "Existing")` where target file exists
- **THEN** it does not overwrite the existing file

### Requirement: open_in_right_pane preserves menu layout
The `open_in_right_pane(path)` function SHALL open a file in a right pane while preserving the menu.

#### Scenario: Open from menu buffer
- **WHEN** calling `open_in_right_pane("/path/to/doc.md")` while in linny_menu buffer
- **THEN** it opens the file in a vertical split to the right and restores menu width

#### Scenario: Open from non-menu buffer
- **WHEN** calling `open_in_right_pane("/path/to/doc.md")` while not in linny_menu buffer
- **THEN** it opens the file normally with `:e`

### Requirement: new_in_leaf creates document in current taxonomy/term
The `new_in_leaf(title)` function SHALL create a new document with the current taxonomy/term set.

#### Scenario: Create with taxonomy and term
- **WHEN** calling `new_in_leaf("My Document")` with `t:linny_menu_taxonomy` and `t:linny_menu_term` set
- **THEN** it creates a document with that taxonomy/term in frontmatter

#### Scenario: Apply frontmatter template
- **WHEN** the term config has a `frontmatter_template`
- **THEN** the template values are included in the new document's frontmatter

#### Scenario: File already exists
- **WHEN** calling `new_in_leaf("Existing Doc")` where the file exists
- **THEN** it opens the existing file without overwriting

### Requirement: archive_l2_config archives term config
The `archive_l2_config(taxonomy, taxo_term)` function SHALL set archive flag on a term config.

#### Scenario: Archive existing config
- **WHEN** calling `archive_l2_config("project", "my-project")` with existing config
- **THEN** it adds `archive: true` to the frontmatter

#### Scenario: Archive non-existing config
- **WHEN** calling `archive_l2_config("project", "new-project")` without existing config
- **THEN** it creates a minimal config file with `archive: true`

### Requirement: create_l2_config creates or opens term config
The `create_l2_config(taxonomy, taxo_term)` function SHALL create a new term config or open existing one.

#### Scenario: Open existing config
- **WHEN** calling `create_l2_config("project", "existing")` with existing config
- **THEN** it opens the config file in a split

#### Scenario: Create new config
- **WHEN** calling `create_l2_config("project", "new-project")` without existing config
- **THEN** it creates a config file with default template and opens it

### Requirement: create_l1_config creates taxonomy config
The `create_l1_config(taxonomy)` function SHALL create a taxonomy config file.

#### Scenario: Create taxonomy config
- **WHEN** calling `create_l1_config("category")`
- **THEN** it creates a config file with default template and opens it in a split

