## Context

Currently Linny uses `g:linny_open_notebook_path` to track the active notebook. Users must manually change this variable to switch notebooks. There's no way to pre-configure a list of known notebooks for quick access.

The existing widget system in `lua/linny/menu/widgets.lua` provides various menu widgets (starred_documents, recent_files, etc.) that follow a consistent pattern: a function that takes `widgetconf` and adds items to the menu.

## Goals / Non-Goals

**Goals:**
- Allow users to configure a list of notebook paths
- Provide a widget to display and select from configured notebooks
- Enable switching between notebooks from the menu
- Add test fixtures to verify multi-notebook scenarios

**Non-Goals:**
- Auto-discovering notebooks on the filesystem
- Recent notebooks tracking (separate feature)
- Notebook-specific settings or profiles

## Decisions

### Decision 1: Use Vim list type for `g:linny_notebooks`

Store notebook paths as a Vim list: `let g:linny_notebooks = ['/path/nb1', '/path/nb2']`

**Alternatives considered:**
- Dictionary with names as keys — rejected for simplicity; notebook names can be derived from paths
- JSON string — rejected; Vim lists are native and easier to configure

### Decision 2: Widget renders notebook items with switch action

The `configured_notebooks` widget adds menu items that, when selected, switch the active notebook by setting `g:linny_open_notebook_path` and reinitializing Linny.

**Rationale:** Follows existing widget patterns. Switching notebooks requires reinitializing the index.

### Decision 3: Second mock notebook for testing

Create `tests/fixtures/mock-notebook-2/` with minimal structure (hugo.yaml, content/sample.md) to test multi-notebook widget scenarios.

**Rationale:** Existing `mock-notebook` can't test list-of-notebooks scenarios alone.

## Risks / Trade-offs

- [Path validation] Invalid paths in list could cause errors → Widget should gracefully handle missing paths, showing them as unavailable
- [Notebook switching overhead] Switching requires full reinitialization → Acceptable trade-off for correct state
