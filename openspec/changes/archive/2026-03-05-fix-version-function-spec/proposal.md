## Why

The test `linny_spec.lua` calls `linny_version#version()` but the actual function in `autoload/linny_version.vim` is named `linny_version#PluginVersion()`. This causes the test to fail.

## What Changes

- Fix the test to call the correct function name `linny_version#PluginVersion()`

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- `tests/linny_spec.lua`: Update function call from `linny_version#version` to `linny_version#PluginVersion`
