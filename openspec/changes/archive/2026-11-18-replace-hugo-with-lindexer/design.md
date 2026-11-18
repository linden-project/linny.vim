# Design

## Context

Index building is currently owned by `lua/linny/hugo.lua`, which shells out to
`hugo` in a notebook that must carry a Hugo site configuration. `lindexer` produces
the same JSON tree from the notebook alone and is verified against Hugo's output.
The plugin needs one seam so callers stop branching on Hugo, while Hugo stays
available for users who have not installed `lindexer` yet.

## Goals and Non-Goals

Goals:

- One backend seam for detection, build, watch, and status.
- `lindexer` preferred; Hugo fallback for this release.
- Index format version checked after every build.
- Users install `lindexer` themselves, like `fred`.

Non-goals:

- Deleting the Hugo backend in this change.
- Downloading or installing binaries from inside Neovim.
- Changing the notebook template or its Hugo layouts.

## Decisions

### Backend seam as a single module

`lua/linny/indexer.lua` exposes `detect()`, `build(notebook)`,
`start_watch(notebook)`, `stop_watch()`, `is_watching()`, and `status()`. No caller
outside the module inspects the backend name to decide what to run.

Alternative considered: extend `lua/linny/hugo.lua` with a `backend` switch. That
keeps the Hugo name in code that is no longer about Hugo, and it makes the later
deletion harder. The seam is a new module; `hugo.lua` stays as the Hugo
implementation behind it.

### Detection is ordered and cached per session

`detect()` tries `lindexer`, then `hugo`, using `vim.fn.executable`. The result is
cached in a module-local table with the backend name and version. A failed
detection is cached too, so a missing binary does not spawn a subprocess on every
refresh. `M.clear_cache()` clears both.

### Alias handling for options

`g:linny_index_hook_enabled` wins when set. When unset, the plugin reads
`g:linny_hugo_hook_enabled`, then the default `1`. The same pattern applies to
`g:linny_index_watch_enabled` and `g:linny_hugo_watch_enabled`, default `0`. Alias
reads happen at use time, not at load time, so late `:let` in a user config is
honoured.

### Watch needs a state directory

`lindexer watch` requires `--state-dir` because it maintains a SQLite store while
watching. The plugin passes
`stdpath('cache')/linny/<notebook-basename>` and creates it when missing. The store
is disposable and outside the notebook, so it never appears in the user's notes or
git status.

Watch command:

```
lindexer watch --corpus <notebook> --state-dir <cache> --index <notebook>/lindenIndex
```

The Hugo backend keeps its existing watcher, unchanged, behind the same seam.

### Index format compatibility

`lindexer` writes `index_format_version` into `_indexer_info.json` (integer). The
plugin defines one minimum constant and warns, with the backend name, the reported
version, and the minimum, when the field is missing or lower. A warning never
blocks the refresh: the user still sees the index that was written.

`g:linnycfg_index_version` stays untouched. It is written today and read nowhere;
repurposing it would conflate notebook configuration with a plugin capability.

### One-time notices

A module-local flag records that the fallback notice or an incompatible-format
notice has been shown this session. Repeat builds stay quiet. Messages use
`vim.notify` with `WARN`.

### Health output shape

`validate()` keeps its `ok`, `errors`, `notebook` members and replaces `hugo` and
`hugo_config` with:

```lua
indexer = { backend = "lindexer", available = true, version = "0.3.1" }
```

`hugo_config` is still populated when Hugo is the selected backend, because the
Hugo path needs it. `checkhealth` renders an `Indexer` section first and the
`Hugo Configuration` section only for the Hugo backend. A missing backend produces
a warning, never an `ok = false`.

## Risks and Trade-offs

- Two backends for one release doubles the test surface. Mitigated by testing the
  seam with a mocked detection result and keeping the Hugo module untouched.
- `lindexer watch` holds a SQLite file in the cache directory. Losing it is
  harmless; watch rebuilds it on start.
- Version drift between plugin and binary is detected only after a build. Health
  reports the detected version so the user can see it before relying on the index.

## Migration

Users get `lindexer` and keep working. Without it, Hugo is used and a one-time
notice recommends the install. When Hugo support is deleted in a later change, the
notice becomes an error.
