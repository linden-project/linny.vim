## 1. Create Lua Module

- [x] 1.1 Create `lua/linny/menu/views.lua` with module structure
- [x] 1.2 Implement `get_list(config)` function
- [x] 1.3 Implement `get_views(config)` function
- [x] 1.4 Implement `get_active(state)` function
- [x] 1.5 Implement `current_props(active_view, views_list, views)` function
- [x] 1.6 Implement `new_active(state, views, direction, active_view)` function
- [x] 1.7 Implement `cycle_l1(direction)` function
- [x] 1.8 Implement `cycle_l2(direction)` function

## 2. Module Integration

- [x] 2.1 Update `lua/linny/menu/init.lua` to export views submodule

## 3. Update VimScript Callers

- [x] 3.1 Update `autoload/linny_menu_views.vim` - replace internal calls with luaeval for migrated functions
- [x] 3.2 Update `autoload/linny_menu_render.vim` to use luaeval() for views functions
- [x] 3.3 Update `autoload/linny_menu.vim` to use luaeval() for views functions
- [x] 3.4 Update `autoload/linny_menu_actions.vim` to use luaeval() for views functions (if any)

## 4. Cleanup

- [x] 4.1 Remove migrated functions from `autoload/linny_menu_views.vim` (keep dropdown/render functions)

## 5. Testing

- [x] 5.1 Create `tests/menu_views_spec.lua` with unit tests for all Lua functions
- [x] 5.2 Run test suite and verify all tests pass
