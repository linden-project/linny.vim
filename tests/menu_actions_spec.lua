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

  describe("copy_path_to_clipboard", function()
    before_each(function()
      vim.g.linny_open_notebook_path = "/home/user/notebook"
      vim.g.linny_path_wiki_content = "/home/user/notebook/content"
    end)

    after_each(function()
      vim.g.linny_open_notebook_path = nil
      vim.g.linny_path_wiki_content = nil
      vim.fn.setreg('+', '')
    end)

    it("copies absolute path to clipboard", function()
      local item = {
        option_type = "document",
        option_data = { abs_path = "/home/user/notebook/content/docs/test.md" }
      }
      -- Skip if clipboard not available
      if vim.fn.has('clipboard') == 0 then
        return
      end
      local result = actions.copy_path_to_clipboard(item, "absolute")
      assert.is_true(result)
      assert.are.equal("/home/user/notebook/content/docs/test.md", vim.fn.getreg('+'))
    end)

    it("copies relative path to clipboard (relative to notebook root)", function()
      local item = {
        option_type = "document",
        option_data = { abs_path = "/home/user/notebook/content/docs/test.md" }
      }
      -- Skip if clipboard not available
      if vim.fn.has('clipboard') == 0 then
        return
      end
      local result = actions.copy_path_to_clipboard(item, "relative")
      assert.is_true(result)
      assert.are.equal("content/docs/test.md", vim.fn.getreg('+'))
    end)

    it("returns false for item without path", function()
      local item = { option_type = "document", option_data = {} }
      local result = actions.copy_path_to_clipboard(item, "absolute")
      assert.is_false(result)
    end)
  end)

  describe("build_dropdown_views with copy path", function()
    it("includes copy path for document items", function()
      local item = { option_type = "document" }
      local views = actions.build_dropdown_views(item)
      assert.is_true(vim.tbl_contains(views, "copy path"))
    end)
  end)

  describe("get_term_document_paths", function()
    local original_wiki_content
    local original_notebook_path

    before_each(function()
      original_wiki_content = vim.g.linny_path_wiki_content
      original_notebook_path = vim.g.linny_open_notebook_path
      vim.g.linny_open_notebook_path = "/home/user/notebook"
      vim.g.linny_path_wiki_content = "/home/user/notebook/content"
    end)

    after_each(function()
      vim.g.linny_path_wiki_content = original_wiki_content
      vim.g.linny_open_notebook_path = original_notebook_path
    end)

    it("returns empty table when no documents in term", function()
      -- Mock empty term
      vim.fn['linny#l2_index_filepath'] = function() return '/tmp/empty.json' end
      vim.fn['linny#parse_json_file'] = function() return {} end

      local paths = actions.get_term_document_paths("category", "empty")
      assert.are.equal(0, #paths)
    end)
  end)

  describe("copy_term_paths_to_clipboard", function()
    before_each(function()
      vim.g.linny_open_notebook_path = "/home/user/notebook"
      vim.g.linny_path_wiki_content = "/home/user/notebook/content"
      vim.t.linny_menu_taxonomy = nil
      vim.t.linny_menu_term = nil
    end)

    after_each(function()
      vim.g.linny_open_notebook_path = nil
      vim.g.linny_path_wiki_content = nil
      vim.t.linny_menu_taxonomy = nil
      vim.t.linny_menu_term = nil
      vim.fn.setreg('+', '')
    end)

    it("returns false when no taxonomy selected", function()
      vim.t.linny_menu_taxonomy = nil
      vim.t.linny_menu_term = "work"
      local result = actions.copy_term_paths_to_clipboard("absolute")
      assert.is_false(result)
    end)

    it("returns false when no term selected", function()
      vim.t.linny_menu_taxonomy = "category"
      vim.t.linny_menu_term = nil
      local result = actions.copy_term_paths_to_clipboard("absolute")
      assert.is_false(result)
    end)

    it("returns false when taxonomy is empty string", function()
      vim.t.linny_menu_taxonomy = ""
      vim.t.linny_menu_term = "work"
      local result = actions.copy_term_paths_to_clipboard("absolute")
      assert.is_false(result)
    end)
  end)

  describe("module exports term paths functions", function()
    it("exports get_term_document_paths", function()
      assert.is_not_nil(actions.get_term_document_paths)
      assert.is_function(actions.get_term_document_paths)
    end)

    it("exports copy_term_paths_to_clipboard", function()
      assert.is_not_nil(actions.copy_term_paths_to_clipboard)
      assert.is_function(actions.copy_term_paths_to_clipboard)
    end)

    it("exports show_term_paths_format_popup", function()
      assert.is_not_nil(actions.show_term_paths_format_popup)
      assert.is_function(actions.show_term_paths_format_popup)
    end)
  end)
end)
