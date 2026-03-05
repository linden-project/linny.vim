## Context

The test file `tests/linny_spec.lua` has a typo in the function name. It calls `linny_version#version` but the actual autoload function is `linny_version#PluginVersion`.

## Goals / Non-Goals

**Goals:**
- Fix the test to use the correct function name

**Non-Goals:**
- Renaming the actual function (it's fine as-is)
- Adding new version functionality

## Decisions

### Decision 1: Update test, not function

Update the test to match the existing function name rather than renaming the function. The function name `PluginVersion` is more descriptive and follows the existing codebase conventions.

## Risks / Trade-offs

None - this is a simple typo fix in the test file.
