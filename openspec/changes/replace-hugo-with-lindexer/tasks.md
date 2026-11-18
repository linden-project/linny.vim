# Tasks

## 1. Backend seam

- [x] 1.1 Add `lua/linny/indexer.lua` with `detect`, `build`, `start_watch`,
      `stop_watch`, `is_watching`, `status`, and `clear_cache`.
- [x] 1.2 Implement ordered detection for `lindexer` then `hugo`, caching the
      result and version per session.
- [x] 1.3 Implement `build(notebook)` for both backends, returning
      `{ok, error}` and never raising.
- [x] 1.4 Add the one-time fallback notice when Hugo is selected.

## 2. Format compatibility

- [x] 2.1 Add the `index_format_version` minimum constant and a reader for
      `<notebook>/lindenIndex/_indexer_info.json`.
- [x] 2.2 Warn once per session when the field is missing or below the minimum,
      naming the backend and both versions.
- [x] 2.3 Skip the check when `_indexer_info.json` is absent after a successful
      build, with a distinct warning.

## 3. Configuration

- [x] 3.1 Read `g:linny_index_hook_enabled`, falling back to
      `g:linny_hugo_hook_enabled`, default `1`.
- [x] 3.2 Read `g:linny_index_watch_enabled`, falling back to
      `g:linny_hugo_watch_enabled`, default `0`.
- [x] 3.3 Keep the existing `g:linny_hugo_*` defaults in `autoload/linny.vim` so
      user configs that test them keep working.

## 4. Menu and commands

- [x] 4.1 Route `M.refresh` in `lua/linny/menu/window.lua` through
      `indexer.build` and `indexer.is_watching`.
- [x] 4.2 Replace the Hugo footer with `[Index: watching]` and `[Index: stopped]`.
- [x] 4.3 Add `:LinnyIndexWatch` and `:LinnyIndexStop`; point
      `:LinnyHugoWatch` and `:LinnyHugoStop` at the same handlers.
- [x] 4.4 Autostart watch once per session through the seam when enabled.

## 5. Health

- [x] 5.1 Return `indexer = {backend, available, version}` from `validate()`.
- [x] 5.2 Render an `Indexer` section in `:checkhealth linny`; make a missing
      backend a warning.
- [x] 5.3 Run Hugo output-format validation only when Hugo is the selected
      backend.

## 6. Tests and docs

- [x] 6.1 Test detection order, fallback notice, and cache clearing.
- [x] 6.2 Test build success and failure with mocked `jobstart` and `system`.
- [x] 6.3 Test the format-version warnings for missing and too-old values.
- [x] 6.4 Test watch start, stop, status, autostart, and cleanup.
- [x] 6.5 Cover the refresh path through `tests/indexer_spec.lua` and keep
      `tests/hugo_spec.lua` for the Hugo backend.
- [x] 6.6 Document installing `lindexer` next to `fred` in `README.md` and
      `doc/linny.txt`, and update the indexer section that names Carl.

## Notes

- `lindexer` `v0.2.0` is tagged and pushed (linden-index commit `bea9f938`); the
  backend seam can target that version.
