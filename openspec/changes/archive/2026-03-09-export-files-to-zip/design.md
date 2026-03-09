## Context

The level 2 menu shows documents within a taxonomy term. Recent changes added `copy_term_paths_to_clipboard` functionality via the `Y` hotkey. The export-to-zip feature extends this pattern to create zip archives of term documents.

The existing `get_term_document_paths(tax, term)` function already retrieves all document paths for a term. The `group_by` view property organizes documents into groups based on frontmatter values.

## Goals / Non-Goals

**Goals:**
- Add "export to zip" option to document context menu
- Support both flat and folder-structured exports
- Use system `zip` command for portability
- Prompt for folder structure when `group_by` view is active

**Non-Goals:**
- Custom archive formats (tar, 7z)
- Compression level options
- Export filters (only starred, date range, etc.)
- Progress indicator for large exports

## Decisions

### 1. Add to context menu, not hotkey
Export to zip requires user input (path, structure choice). A context menu option fits this workflow better than a direct hotkey.

Rationale: Unlike `Y` for copying paths (immediate clipboard action), zip export is a multi-step operation.

### 2. Use system `zip` command
Shell out to `zip -r` via `vim.fn.jobstart()` rather than a Lua zip library.

Rationale: No additional dependencies. The `zip` command is available on most systems. Async execution prevents UI blocking.

### 3. Detect group_by from current view props
Check `view_props.group_by` to determine if folder structure prompt is needed.

Rationale: The view configuration already tracks this. No additional state needed.

### 4. Default output path based on term name
Suggest `~/Downloads/<term>.zip` as default, allowing user override.

Rationale: Predictable location, easy to find the exported file.

## Risks / Trade-offs

**[Risk] zip command not available** → Check `vim.fn.executable('zip')` before attempting export. Show clear error message if missing.

**[Risk] Large term with many documents** → Async job prevents blocking, but no progress feedback. Acceptable for typical term sizes.

**[Trade-off] No cross-platform GUI file picker** → Using `vim.fn.input()` for path. Native file picker would require platform-specific code.
