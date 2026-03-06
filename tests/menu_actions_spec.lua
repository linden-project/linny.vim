-- Unit tests for linny.menu.actions module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.menu.actions", function()
  local actions

  before_each(function()
    package.loaded['linny.menu.actions'] = nil
    package.loaded['linny.menu'] = nil
    actions = require('linny.menu.actions')
    -- Reset tab-local state
    vim.t.linny_menu_repeat_last_taxo_term = nil
  end)

  it("module is requireable with all functions", function()
    local ok, mod = pcall(require, 'linny.menu.actions')
    assert.is_true(ok, "Should be able to require linny.menu.actions")

    assert.is_not_nil(mod.job_start, "Should have job_start")
    assert.is_not_nil(mod.build_dropdown_views, "Should have build_dropdown_views")
    assert.is_not_nil(mod.get_item_name, "Should have get_item_name")
    assert.is_not_nil(mod.exec_content_menu, "Should have exec_content_menu")
  end)

  it("is accessible from menu module", function()
    package.loaded['linny.menu'] = nil
    local menu = require('linny.menu')
    assert.is_not_nil(menu.actions, "Should have actions submodule")
    assert.is_not_nil(menu.actions.job_start, "Should have job_start via menu module")
  end)

  it("is accessible from main module", function()
    package.loaded['linny'] = nil
    local linny = require('linny')
    assert.is_not_nil(linny.menu, "Should have menu submodule")
    assert.is_not_nil(linny.menu.actions, "Should have actions submodule via main")
    assert.is_not_nil(linny.menu.actions.job_start, "Should have job_start via main module")
  end)

  describe("build_dropdown_views", function()
    it("returns archive for taxo_key_val items", function()
      local item = { option_type = "taxo_key_val" }
      local views = actions.build_dropdown_views(item)
      assert.are.equal(1, #views)
      assert.are.equal("archive", views[1])
    end)

    it("returns document actions for document items", function()
      local item = { option_type = "document" }
      local views = actions.build_dropdown_views(item)
      assert.is_true(#views >= 6)
      assert.is_true(vim.tbl_contains(views, "copy"))
      assert.is_true(vim.tbl_contains(views, "archive"))
      assert.is_true(vim.tbl_contains(views, "set taxonomy"))
      assert.is_true(vim.tbl_contains(views, "remove taxonomy"))
      assert.is_true(vim.tbl_contains(views, "open docdir"))
    end)

    it("includes repeat action when available", function()
      vim.t.linny_menu_repeat_last_taxo_term = { "category", "work" }
      local item = { option_type = "document" }
      local views = actions.build_dropdown_views(item)
      assert.is_true(vim.tbl_contains(views, "set category: work"))
    end)

    it("returns empty table for other item types", function()
      local item = { option_type = "unknown" }
      local views = actions.build_dropdown_views(item)
      assert.are.equal(0, #views)
    end)
  end)

  describe("get_item_name", function()
    it("returns taxo_term for taxo_key_val items", function()
      local item = {
        option_type = "taxo_key_val",
        option_data = { taxo_term = "my-term" }
      }
      local name = actions.get_item_name(item)
      assert.are.equal("my-term", name)
    end)

    it("extracts name from document text", function()
      local item = {
        option_type = "document",
        text = "[abc] My Document Title"
      }
      local name = actions.get_item_name(item)
      assert.are.equal("My Document Title", name)
    end)

    it("handles document text without brackets", function()
      local item = {
        option_type = "document",
        text = "Plain Title"
      }
      local name = actions.get_item_name(item)
      assert.are.equal("Plain Title", name)
    end)
  end)

  describe("exec_content_menu", function()
    it("returns false for unhandled actions", function()
      local item = { option_type = "document", option_data = {} }
      local handled = actions.exec_content_menu("unknown action", item)
      assert.is_false(handled)
    end)

    it("returns false for popup-dependent actions", function()
      local item = { option_type = "document", option_data = {} }
      local handled = actions.exec_content_menu("set taxonomy", item)
      assert.is_false(handled)

      handled = actions.exec_content_menu("remove taxonomy", item)
      assert.is_false(handled)
    end)
  end)
end)
