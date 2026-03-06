## Context

The `autoload/linny.vim` file contains 7 path utility functions that construct file paths based on taxonomy names, terms, and view names. These are pure functions that read global variables (`g:linny_index_path`, `g:linny_path_wiki_config`, `g:linny_state_path`) and return strings.

## Goals / Non-Goals

**Goals:**
- Create `lua/linny/paths.lua` module with all path functions
- Add comprehensive unit tests for each function
- Update callers to use Lua versions
- Remove VimScript implementations

**Non-Goals:**
- Changing path formats or naming conventions
- Migrating config parser functions (view_config, tax_config, term_config)

## Decisions

### 1. Create dedicated paths.lua module
Create a new `lua/linny/paths.lua` module rather than adding to existing modules.

Rationale: Path utilities are a distinct concern, used across many modules.

### 2. Keep VimScript wrappers for backward compatibility
Keep thin VimScript wrappers that call Lua, so existing `linny#l1_index_filepath()` calls continue to work.

Rationale: Many places call these functions; changing all callers is error-prone.

### 3. Use vim.g for global variable access
Access `vim.g.linny_index_path` etc. directly in Lua.

Rationale: Standard pattern, already used elsewhere in the codebase.

### 4. Normalize term strings in Lua
Use `string.lower()` and `string.gsub()` for case conversion and space-to-dash replacement.

Rationale: Native Lua string functions are efficient and well-tested.

## Risks / Trade-offs

**[Risk] Global variables not initialized** → Functions assume globals exist; callers must ensure `linny#Init()` was called.
