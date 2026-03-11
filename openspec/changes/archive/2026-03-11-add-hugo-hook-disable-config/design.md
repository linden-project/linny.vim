## Context

The current `M.refresh()` function in `lua/linny/menu/window.lua` always attempts Hugo detection and manual index rebuilding when watch mode is not active. The only way to skip this is if watch mode is running (`hugo.is_watching()` returns true).

Users who don't use Hugo at all, or who want a faster refresh without Hugo operations, have no way to disable this behavior. The existing `g:linny_hugo_watch_enabled` config only controls auto-start of watch mode, not the R key behavior.

## Goals / Non-Goals

**Goals:**
- Allow users to fully disable Hugo hooks on refresh via a single config variable
- Maintain backward compatibility (default behavior unchanged)
- Keep the implementation minimal and consistent with existing patterns

**Non-Goals:**
- Changing the behavior of `:LinnyHugoWatch` or `:LinnyHugoStop` commands
- Modifying watch mode auto-start behavior (that remains controlled by `g:linny_hugo_watch_enabled`)
- Adding UI to toggle this setting at runtime

## Decisions

### Decision 1: New config variable `g:linny_hugo_hook_enabled`

Add `g:linny_hugo_hook_enabled` (default: `1`) that gates all Hugo operations in the refresh function.

**Alternatives considered:**
- Reuse `g:linny_hugo_watch_enabled` — rejected because it conflates two distinct behaviors (auto-start vs hook-on-refresh)
- Add `g:linny_hugo_refresh_enabled` — rejected in favor of the more general "hook" naming that could apply to future Hugo integration points

### Decision 2: Check config at refresh time

Check `vim.g.linny_hugo_hook_enabled` at the start of `M.refresh()` before any Hugo operations.

**Rationale:** This is the minimal change. The config is read fresh each refresh, allowing runtime changes if the user sets the variable.

### Decision 3: Initialize variable in autoload/linny.vim

Initialize `g:linny_hugo_hook_enabled` to `1` in `autoload/linny.vim` using the existing `init_variable` pattern via Lua.

**Rationale:** Consistent with how `g:linny_hugo_watch_enabled` is initialized.

## Risks / Trade-offs

- [Config proliferation] Adding another config variable increases surface area. → Mitigated by clear naming and documentation.
- [User confusion between watch_enabled and hook_enabled] → Mitigated by distinct naming; `watch_enabled` controls auto-start, `hook_enabled` controls R key behavior.
