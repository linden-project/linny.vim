-- Unit tests for linny.notebook module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.notebook", function()
  local notebook

  before_each(function()
    package.loaded['linny.notebook'] = nil
    notebook = require('linny.notebook')
    -- Reset global variables
    vim.g.linny_open_notebook_path = nil
    vim.g.linny_path_wiki_content = nil
    vim.g.linny_path_wiki_config = nil
    vim.g.linny_index_path = nil
  end)

  describe("init", function()
    it("sets global path variables correctly", function()
      vim.g.linny_open_notebook_path = "/tmp/test_notebook"

      notebook.init()

      assert.are.equal("/tmp/test_notebook/content", vim.g.linny_path_wiki_content)
      assert.are.equal("/tmp/test_notebook/lindenConfig", vim.g.linny_path_wiki_config)
      assert.are.equal("/tmp/test_notebook/lindenIndex", vim.g.linny_index_path)
    end)

    it("expands tilde in path", function()
      vim.g.linny_open_notebook_path = "~/test_notebook"

      notebook.init()

      -- Should contain expanded home path, not tilde
      assert.is_not_nil(vim.g.linny_path_wiki_content:find("/content$"))
      assert.is_nil(vim.g.linny_path_wiki_content:find("~"))
    end)
  end)

  describe("open", function()
    it("returns false for non-existent path", function()
      local result = notebook.open("/nonexistent/path/that/does/not/exist")

      assert.is_false(result)
    end)

    it("sets g:linny_open_notebook_path for valid path", function()
      -- Use /tmp which should always exist
      local test_path = "/tmp"

      -- Mock the Vimscript functions that get called on success
      vim.fn['linny#Init'] = function() end
      vim.fn['linny_menu#start'] = function() end

      local result = notebook.open(test_path)

      assert.is_true(result)
      assert.are.equal("/tmp", vim.g.linny_open_notebook_path)
    end)

    it("returns false for empty string path", function()
      local result = notebook.open("")

      assert.is_false(result)
    end)
  end)

  it("module is requireable and has expected functions", function()
    local ok, mod = pcall(require, 'linny.notebook')
    assert.is_true(ok, "Should be able to require linny.notebook")
    assert.is_not_nil(mod.init, "Should have init function")
    assert.is_not_nil(mod.open, "Should have open function")
  end)

  it("is accessible from main module", function()
    package.loaded['linny'] = nil
    local linny = require('linny')
    assert.is_not_nil(linny.notebook, "Should have notebook submodule")
    assert.is_not_nil(linny.notebook.init, "Should have init via main module")
    assert.is_not_nil(linny.notebook.open, "Should have open via main module")
  end)
end)
