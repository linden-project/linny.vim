## Context

The `lua/linny/hugo.lua` module currently provides `detect()` and `build_index()` functions for one-shot Hugo operations. The R key in menu views triggers `build_index()` before refreshing. Users want automatic index rebuilding during active editing sessions without manual intervention.

Hugo supports `--watch` mode which monitors file changes and rebuilds automatically. Neovim provides `vim.fn.jobstart()` for background process management with callbacks for stdout/stderr/exit.

## Goals / Non-Goals

**Goals:**
- Automatic index rebuilding when editing with minimal user intervention
- Clear visibility into Hugo watch process status
- Manual control to start/stop watch mode
- Graceful handling when Hugo is unavailable or watch fails

**Non-Goals:**
- Real-time menu refresh when index changes (user still presses R to refresh view)
- Multiple concurrent Hugo processes
- Watch mode for non-notebook directories

## Decisions

### Decision 1: Use Neovim's jobstart for background process

Use `vim.fn.jobstart()` to run Hugo in background with `--watch` flag.

**Rationale**: Native Neovim API, handles stdout/stderr callbacks, provides job ID for process control. No external dependencies.

**Alternative considered**: `vim.loop` (libuv) - More complex, less familiar pattern in codebase.

### Decision 2: Store process state in module-local variable

Track job ID and status in `lua/linny/hugo.lua` module-local variables (`_watch_job_id`, `_watch_status`).

**Rationale**: Consistent with existing `_cache` pattern in hugo.lua. Process is per-session, not per-buffer.

### Decision 3: Auto-start on first LinnyMenu open (if enabled)

When `g:linny_hugo_watch_enabled` is truthy and LinnyMenu opens for the first time in a session, automatically start watch mode.

**Rationale**: Seamless experience - user enables config once, watch starts when they begin using Linny.

### Decision 4: R key checks watch status before rebuilding

In `lua/linny/menu/window.lua:refresh()`, check `hugo.is_watching()` before calling `build_index()`. If watching, skip manual rebuild.

**Rationale**: Avoids redundant rebuilds. Watch mode already handles file changes. R still refreshes the menu view.

### Decision 5: Status display in menu footer

Add watch status indicator to menu footer (rendered by `linny_menu#openandshow`). Format: `[Hugo: watching]` or `[Hugo: stopped]`.

**Rationale**: Non-intrusive visibility. Footer already shows version info.

## Risks / Trade-offs

**Risk**: Hugo process outlives Neovim session if not properly cleaned up
→ **Mitigation**: Register `VimLeavePre` autocmd to stop watch process on exit

**Risk**: Watch mode consumes resources on large notebooks
→ **Mitigation**: Disabled by default (`g:linny_hugo_watch_enabled = 0`). User opts in.

**Risk**: Hugo output fills buffer/logs
→ **Mitigation**: Only capture stderr for errors. Discard stdout (rebuild output).

**Trade-off**: Menu doesn't auto-refresh when index changes
→ User still presses R to see updated content. Keeps implementation simple, avoids complexity of file watchers on index files.
