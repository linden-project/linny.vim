## 1. Create Lua paths module

- [x] 1.1 Create `lua/linny/paths.lua` with module structure
- [x] 1.2 Add `l1_index_filepath(tax)` function
- [x] 1.3 Add `l2_index_filepath(tax, term)` function
- [x] 1.4 Add `view_config_filepath(view_name)` function
- [x] 1.5 Add `l1_config_filepath(tax)` function
- [x] 1.6 Add `l2_config_filepath(tax, term)` function
- [x] 1.7 Add `l1_state_filepath(tax)` function
- [x] 1.8 Add `l2_state_filepath(tax, term)` function

## 2. Add unit tests

- [x] 2.1 Create `tests/paths_spec.lua` with test structure
- [x] 2.2 Add tests for `l1_index_filepath`
- [x] 2.3 Add tests for `l2_index_filepath`
- [x] 2.4 Add tests for `view_config_filepath`
- [x] 2.5 Add tests for `l1_config_filepath`
- [x] 2.6 Add tests for `l2_config_filepath`
- [x] 2.7 Add tests for `l1_state_filepath`
- [x] 2.8 Add tests for `l2_state_filepath`
- [x] 2.9 Run tests to verify all pass

## 3. Update VimScript wrappers

- [x] 3.1 Update `linny#l1_index_filepath` to call Lua
- [x] 3.2 Update `linny#l2_index_filepath` to call Lua
- [x] 3.3 Update `linny#view_config_filepath` to call Lua
- [x] 3.4 Update `linny#l1_config_filepath` to call Lua
- [x] 3.5 Update `linny#l2_config_filepath` to call Lua
- [x] 3.6 Update `linny#l1_state_filepath` to call Lua
- [x] 3.7 Update `linny#l2_state_filepath` to call Lua

## 4. Verify

- [x] 4.1 Test menu navigation works
- [x] 4.2 Test config file access works
