# Proposal

## Why

Index building currently requires Hugo, a general-purpose static-site generator
that Linny uses only to emit JSON. `lindexer`, built in the Linden project, emits
the same index files, is faster, is verified against Hugo's output, and needs no
site configuration. Users should not have to install Hugo to use Linny.

## What Changes

- Add a backend seam in `lua/linny/indexer.lua`: prefer `lindexer`, fall back to
  Hugo for one release with a one-time warning.
- Rebuild through `lindexer build --corpus <notebook> --index <notebook>/lindenIndex`.
- Watch through `lindexer watch`, replacing Hugo `--watch`.
- Add `:LinnyIndexWatch` and `:LinnyIndexStop`; keep `:LinnyHugoWatch` and
  `:LinnyHugoStop` as aliases.
- Add `g:linny_index_hook_enabled` and `g:linny_index_watch_enabled`; the existing
  `g:linny_hugo_*` options remain readable as deprecated aliases.
- Read `_indexer_info.json` and warn when no backend is found, the index-format
  version is missing, or the version is below the supported minimum.
- Report the active backend and version in `:checkhealth linny`. Hugo-only
  output-format validation runs only when Hugo is the selected backend.
- Document installing `lindexer` next to the existing `fred` instructions.

Not in this change: deleting the Hugo backend, and the notebook template dropping
Hugo layouts.

## Capabilities

### New Capabilities

- `indexer-integration`: backend detection and precedence, index builds, version
  and format compatibility, and health reporting.
- `indexer-watch`: background watch process, autostart, status display, and the
  watch commands.

### Modified Capabilities

- `hugo-integration`: the menu refresh rebuild requirement moves to
  `indexer-integration`, because it no longer belongs to Hugo.
- `hugo-hook-config`: new index option names, with the old `g:linny_hugo_*` names
  kept as deprecated aliases.
- `hugo-watch-process`: all requirements removed; replaced by `indexer-watch`.
- `startup-health-check`: the Hugo availability and configuration requirements
  removed; replaced by `indexer-integration`.

## Impact

- Lua: new `lua/linny/indexer.lua`; changed `lua/linny/hugo.lua`,
  `lua/linny/menu/window.lua`, `lua/linny/health.lua`.
- Vimscript: `autoload/linny.vim` (commands and option defaults), `plugin/linny.vim`.
- Tests: `tests/hugo_spec.lua` plus new indexer backend and watch specs.
- Docs: `README.md`, `doc/linny.txt`.
- Runtime dependency: the `lindexer` binary on `PATH`; Hugo becomes optional until
  it is removed.
