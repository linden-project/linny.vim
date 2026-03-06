## Context

The level 2 menu shows documents within a taxonomy term (e.g., "category: work"). Tab variables `vim.t.linny_menu_taxonomy` and `vim.t.linny_menu_term` store the current context. Document paths are loaded from the term's index file via `linny#l2_index_filepath(tax, term)`.

The `export-paths-to-clipboard` change already provides `copy_path_to_clipboard()` and format selection popup infrastructure.

## Goals / Non-Goals

**Goals:**
- Add `Y` hotkey in level 2 menu to trigger bulk path copy
- Reuse existing format selection popup
- Copy all visible document paths (newline-separated)

**Non-Goals:**
- Filtering which documents to include (copies all in term)
- Custom separators or path formats
- Hotkey for level 1 menu (taxonomy terms, not documents)

## Decisions

### 1. Add keymap only for menu_level2
The `Y` hotkey only applies when viewing a term's documents, not at taxonomy or root level.

Rationale: Only level 2 has document paths to copy.

### 2. Read paths from index file directly
Use `linny#l2_index_filepath(tax, term)` to get document list, then construct full paths with `vim.g.linny_path_wiki_content`.

Rationale: Same data source as menu rendering, ensures consistency.

### 3. Reuse format popup and callback pattern
Show same "relative/absolute" popup, use similar callback pattern.

Rationale: Consistent UX, less code duplication.

## Risks / Trade-offs

**[Risk] Large number of paths** → No limit imposed; clipboard can handle thousands of lines. User responsibility to select appropriate terms.
