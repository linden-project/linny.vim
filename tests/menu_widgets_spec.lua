-- Unit tests for linny.menu.widgets module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.menu.widgets", function()
  local widgets

  before_each(function()
    package.loaded['linny.menu.widgets'] = nil
    package.loaded['linny.menu.items'] = nil
    package.loaded['linny.menu'] = nil
    widgets = require('linny.menu.widgets')
    -- Reset tab-local state for each test
    vim.t.linny_menu_items = {}
    vim.t.linny_menu = nil
  end)

  it("module is requireable with all functions", function()
    local ok, mod = pcall(require, 'linny.menu.widgets')
    assert.is_true(ok, "Should be able to require linny.menu.widgets")

    assert.is_not_nil(mod.recent_files, "Should have recent_files")
    assert.is_not_nil(mod.starred_terms_list, "Should have starred_terms_list")
    assert.is_not_nil(mod.starred_docs_list, "Should have starred_docs_list")
    assert.is_not_nil(mod.partial_files_listing, "Should have partial_files_listing")
    assert.is_not_nil(mod.starred_documents, "Should have starred_documents")
    assert.is_not_nil(mod.starred_terms, "Should have starred_terms")
    assert.is_not_nil(mod.starred_taxonomies, "Should have starred_taxonomies")
    assert.is_not_nil(mod.all_taxonomies, "Should have all_taxonomies")
    assert.is_not_nil(mod.recently_modified_documents, "Should have recently_modified_documents")
    assert.is_not_nil(mod.all_level0_views, "Should have all_level0_views")
    assert.is_not_nil(mod.menu, "Should have menu")
  end)

  it("is accessible from menu module", function()
    package.loaded['linny.menu'] = nil
    local menu = require('linny.menu')
    assert.is_not_nil(menu.widgets, "Should have widgets submodule")
    assert.is_not_nil(menu.widgets.recent_files, "Should have recent_files via menu module")
  end)

  it("is accessible from main module", function()
    package.loaded['linny'] = nil
    local linny = require('linny')
    assert.is_not_nil(linny.menu, "Should have menu submodule")
    assert.is_not_nil(linny.menu.widgets, "Should have widgets submodule via main")
    assert.is_not_nil(linny.menu.widgets.recent_files, "Should have recent_files via main module")
  end)

  describe("starred_terms_list", function()
    it("returns empty table when index file missing", function()
      -- Set up a non-existent path
      vim.g.linny_index_path = "/tmp/nonexistent_linny_test_path"
      local result = widgets.starred_terms_list()
      assert.is_table(result)
    end)
  end)

  describe("starred_docs_list", function()
    it("returns empty table when index file missing", function()
      vim.g.linny_index_path = "/tmp/nonexistent_linny_test_path"
      local result = widgets.starred_docs_list()
      assert.is_table(result)
    end)
  end)

  describe("menu", function()
    it("handles empty items", function()
      -- Should not error with empty config
      widgets.menu({})
      assert.is_true(true)
    end)

    it("handles items without execute", function()
      -- Should not error when items lack execute key
      widgets.menu({ items = {{ title = "Test" }} })
      assert.is_true(true)
    end)
  end)
end)
