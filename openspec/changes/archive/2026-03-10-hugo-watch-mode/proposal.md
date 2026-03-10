## Why

Currently, users must manually run `:LinnyRebuildIndex` or press `R` to rebuild the Hugo index after making changes. This is tedious for active editing sessions. Hugo's `--watch` mode can automatically rebuild the index when content files change, providing a smoother editing experience.

## What Changes

- Add configuration option `g:linny_hugo_watch_enabled` to control auto-watch behavior
- Start Hugo in `--watch` mode when LinnyMenu is first opened in a session (if enabled)
- Display Hugo process status in menu footer (below version numbers)
- Add commands to start/stop the Hugo watch process manually
- Track Hugo process lifecycle per Neovim session
- Skip manual Hugo rebuild on R key when watch mode is active (watch handles rebuilds automatically)

## Capabilities

### New Capabilities

- `hugo-watch-process`: Background Hugo process management with `--watch` mode, including start/stop control, status tracking, and automatic startup on menu init

### Modified Capabilities

- `hugo-integration`: Add `start_watch()`, `stop_watch()`, `is_watching()` functions for watch mode control; R key skips manual rebuild when watch is active
- `plugin-initialization`: Add `g:linny_hugo_watch_enabled` configuration option

## Impact

- `lua/linny/hugo.lua`: New watch process management functions
- `lua/linny/menu/window.lua`: Status display in footer, trigger watch on first open
- `autoload/linny.vim`: New commands `:LinnyHugoWatch`, `:LinnyHugoStop`
- `plugin/linny.vim`: Register new commands
