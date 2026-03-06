## Context

The document context menu (triggered by `m` key on a menu item) currently offers actions like copy, archive, set/remove taxonomy, and open docdir. Users want to copy file paths to share with AI assistants. The menu system already has popup infrastructure for action selection.

## Goals / Non-Goals

**Goals:**
- Add "copy path" action to document context menu
- Let user choose relative or absolute path format
- Copy to system clipboard using best available method
- Support document paths (from `option_data.abs_path`)

**Non-Goals:**
- Copying multiple paths at once
- Copying taxonomy term directory paths (only document files)
- Custom path format templates

## Decisions

### 1. Use popup for path format selection
Show a small popup with "relative" and "absolute" options after selecting "copy path".

Rationale: Consistent with existing taxonomy selection flow. Avoids config complexity.

### 2. Use vim.fn.setreg('+', path) for clipboard
Use the `+` register which maps to system clipboard in both Vim and Neovim.

Rationale: Standard Vim approach, works cross-platform when clipboard support is compiled in.

### 3. Calculate relative path from wiki content root
Relative paths will be relative to `g:linny_path_wiki_content`.

Rationale: This is the natural base for wiki documents.

### 4. Add action to existing dropdown list
Add "copy path" to `build_dropdown_views()` for document items.

Rationale: Follows existing pattern, minimal code change.

## Risks / Trade-offs

**[Risk] Clipboard not available** → Show error message if `vim.fn.has('clipboard')` returns 0. User can still see the path in the message.

**[Risk] Path format confusion** → Keep labels clear: "copy path (relative)" vs "copy path (absolute)".
