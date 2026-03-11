## 1. Configuration Variable Setup

- [x] 1.1 Add `g:linny_notebooks` initialization in `autoload/linny.vim` using `init_variable` pattern with empty list `[]`

## 2. Test Fixtures

- [x] 2.1 Create `tests/fixtures/mock-notebook-2/` directory structure
- [x] 2.2 Add `tests/fixtures/mock-notebook-2/hugo.yaml` minimal config
- [x] 2.3 Add `tests/fixtures/mock-notebook-2/content/sample.md` with frontmatter
- [x] 2.4 Create `tests/fixtures/mock-notebook-2/lindenConfig/` and `lindenIndex/` directories

## 3. Widget Implementation

- [x] 3.1 Add `configured_notebooks(widgetconf)` function to `lua/linny/menu/widgets.lua`
- [x] 3.2 Implement reading from `vim.g.linny_notebooks` list
- [x] 3.3 Render notebook items with basename as title
- [x] 3.4 Mark active notebook (compare with `vim.g.linny_open_notebook_path`)
- [x] 3.5 Implement notebook switch action (set path and reinitialize)

## 4. Verification

- [x] 4.1 Manual test: configure `g:linny_notebooks` with both mock notebooks
- [x] 4.2 Manual test: verify widget displays notebooks and marks active
- [x] 4.3 Manual test: verify switching notebooks works
