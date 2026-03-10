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
      -- Create temp directory for test
      local test_path = "/tmp/linny_test_notebook_" .. os.time()
      vim.fn.mkdir(test_path, "p")
      vim.g.linny_open_notebook_path = test_path

      local result = notebook.init()

      assert.is_true(result)
      assert.are.equal(test_path .. "/content", vim.g.linny_path_wiki_content)
      assert.are.equal(test_path .. "/lindenConfig", vim.g.linny_path_wiki_config)
      assert.are.equal(test_path .. "/lindenIndex", vim.g.linny_index_path)

      -- Cleanup
      vim.fn.delete(test_path, "rf")
    end)

    it("expands tilde in path", function()
      -- Create temp directory in home for test
      local home = vim.fn.expand("~")
      local test_dir = "linny_test_notebook_tilde_" .. os.time()
      local full_path = home .. "/" .. test_dir
      vim.fn.mkdir(full_path, "p")
      vim.g.linny_open_notebook_path = "~/" .. test_dir

      local result = notebook.init()

      assert.is_true(result)
      -- Should contain expanded home path, not tilde
      assert.is_not_nil(vim.g.linny_path_wiki_content:find("/content$"))
      assert.is_nil(vim.g.linny_path_wiki_content:find("~"))

      -- Cleanup
      vim.fn.delete(full_path, "rf")
    end)

    it("returns false when notebook path not set", function()
      vim.g.linny_open_notebook_path = nil

      local result = notebook.init()

      assert.is_false(result)
    end)

    it("returns false when notebook directory does not exist", function()
      vim.g.linny_open_notebook_path = "/nonexistent/path/that/does/not/exist"

      local result = notebook.init()

      assert.is_false(result)
    end)
  end)

  describe("open", function()
    it("returns false for non-existent path", function()
      local result = notebook.open("/nonexistent/path/that/does/not/exist")

      assert.is_false(result)
    end)

    it("sets g:linny_open_notebook_path for valid path", function()
      -- Create a proper notebook structure
      local test_path = "/tmp/linny_test_open_" .. os.time()
      vim.fn.mkdir(test_path .. "/content", "p")
      vim.fn.mkdir(test_path .. "/lindenConfig", "p")
      vim.fn.mkdir(test_path .. "/lindenIndex", "p")

      -- Mock linny_menu#start since we don't need the actual menu
      vim.fn['linny_menu#start'] = function() end

      local result = notebook.open(test_path)

      assert.is_true(result)
      assert.are.equal(test_path, vim.g.linny_open_notebook_path)
      assert.are.equal(1, vim.g.linny_initialized)

      -- Cleanup
      vim.fn.delete(test_path, "rf")
    end)

    it("returns false when directory exists but missing required subdirectories", function()
      -- Create a directory without the required structure
      local test_path = "/tmp/linny_test_invalid_" .. os.time()
      vim.fn.mkdir(test_path, "p")

      local result = notebook.open(test_path)

      assert.is_false(result)
      -- Menu should not have opened, g:linny_initialized should be 0
      assert.are_not.equal(1, vim.g.linny_initialized)

      -- Cleanup
      vim.fn.delete(test_path, "rf")
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
