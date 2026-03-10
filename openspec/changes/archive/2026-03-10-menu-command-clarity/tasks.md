## 1. Lua Functions

- [x] 1.1 Rename `open_home()` in `lua/linny/menu/window.lua` to clearly indicate it resets to root
- [x] 1.2 Create `open_restore()` function that opens with current `t:linny_menu_*` state
- [x] 1.3 `open_restore()` falls back to root view if state variables are empty
- [x] 1.4 Move Hugo watch auto-start logic to only run in `open_home()` (not `open_restore()`)

## 2. Vimscript Commands

- [x] 2.1 Update `linny_menu#start()` to call `open_home()` (reset to root + auto-start)
- [x] 2.2 Update `linny_menu#open()` to call `open_restore()` (restore last state)
- [x] 2.3 Update `linny_menu#toggle()` to delegate: call `open()` or `close()` only
- [x] 2.4 Verify `linny_menu#close()` preserves state (should already work)

## 3. Verification

- [x] 3.1 Test: `LinnyStart` opens at root view
- [x] 3.2 Test: Navigate to taxonomy, close, `LinnyMenuOpen` restores position
- [x] 3.3 Test: `LinnyMenuToggle` when closed opens at last state
- [x] 3.4 Test: `LinnyMenuToggle` when open closes and preserves state
- [x] 3.5 Test: Hugo watch auto-start only triggers on `LinnyStart`

Note: Tests 3.1-3.5 are manual verification steps.
