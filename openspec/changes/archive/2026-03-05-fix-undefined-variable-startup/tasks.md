## 1. Fix variable references

- [x] 1.1 Replace `if g:linnycfg_setup_autocommands` with `if get(g:, 'linnycfg_setup_autocommands', 1)` in `plugin/linny.vim:9`
- [x] 1.2 Add `let g:linny_wikitags_register = get(g:, 'linny_wikitags_register', {})` at the start of `linny#RegisterLinnyWikitag()` in `autoload/linny.vim`

## 2. Verify

- [x] 2.1 Test that plugin loads without any E121 errors
