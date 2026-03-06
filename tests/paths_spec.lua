-- Unit tests for linny.paths module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.paths", function()
  local paths

  before_each(function()
    -- Clear any cached module
    package.loaded['linny.paths'] = nil
    paths = require('linny.paths')

    -- Set up test globals
    vim.g.linny_index_path = '/test/index'
    vim.g.linny_path_wiki_config = '/test/config'
    vim.g.linny_state_path = '/test/state'
  end)

  after_each(function()
    -- Cleanup
    vim.g.linny_index_path = nil
    vim.g.linny_path_wiki_config = nil
    vim.g.linny_state_path = nil
  end)

  describe("l1_index_filepath", function()
    it("returns correct path for taxonomy", function()
      local result = paths.l1_index_filepath("Category")
      assert.are.equal("/test/index/category/index.json", result)
    end)

    it("lowercases the taxonomy name", function()
      local result = paths.l1_index_filepath("UPPERCASE")
      assert.are.equal("/test/index/uppercase/index.json", result)
    end)
  end)

  describe("l2_index_filepath", function()
    it("returns correct path for taxonomy term", function()
      local result = paths.l2_index_filepath("Category", "myterm")
      assert.are.equal("/test/index/category/myterm/index.json", result)
    end)

    it("replaces spaces with dashes in term", function()
      local result = paths.l2_index_filepath("Category", "My Term")
      assert.are.equal("/test/index/category/my-term/index.json", result)
    end)

    it("lowercases both taxonomy and term", function()
      local result = paths.l2_index_filepath("CATEGORY", "MY TERM")
      assert.are.equal("/test/index/category/my-term/index.json", result)
    end)
  end)

  describe("view_config_filepath", function()
    it("returns correct path for view", function()
      local result = paths.view_config_filepath("root")
      assert.are.equal("/test/config/views/root.yml", result)
    end)

    it("lowercases the view name", function()
      local result = paths.view_config_filepath("Root")
      assert.are.equal("/test/config/views/root.yml", result)
    end)
  end)

  describe("l1_config_filepath", function()
    it("returns correct path for taxonomy config", function()
      local result = paths.l1_config_filepath("status")
      assert.are.equal("/test/config/L1-CONF-TAX-status.yml", result)
    end)

    it("lowercases the taxonomy name", function()
      local result = paths.l1_config_filepath("Status")
      assert.are.equal("/test/config/L1-CONF-TAX-status.yml", result)
    end)
  end)

  describe("l2_config_filepath", function()
    it("returns correct path for term config", function()
      local result = paths.l2_config_filepath("status", "active")
      assert.are.equal("/test/config/L2-CONF-TAX-status-TRM-active.yml", result)
    end)

    it("replaces spaces with dashes in term", function()
      local result = paths.l2_config_filepath("Status", "In Progress")
      assert.are.equal("/test/config/L2-CONF-TAX-status-TRM-in-progress.yml", result)
    end)
  end)

  describe("l1_state_filepath", function()
    it("returns correct path for taxonomy state", function()
      local result = paths.l1_state_filepath("project")
      assert.are.equal("/test/state/L1-STATE-TAX-project.json", result)
    end)

    it("lowercases the taxonomy name", function()
      local result = paths.l1_state_filepath("Project")
      assert.are.equal("/test/state/L1-STATE-TAX-project.json", result)
    end)
  end)

  describe("l2_state_filepath", function()
    it("returns correct path for term state", function()
      local result = paths.l2_state_filepath("project", "alpha")
      assert.are.equal("/test/state/L2-STATE-TRM-project-TRM-alpha.json", result)
    end)

    it("lowercases both taxonomy and term", function()
      local result = paths.l2_state_filepath("Project", "Alpha")
      assert.are.equal("/test/state/L2-STATE-TRM-project-TRM-alpha.json", result)
    end)
  end)

  it("module is requireable", function()
    local ok, mod = pcall(require, 'linny.paths')
    assert.is_true(ok, "Should be able to require linny.paths")
    assert.is_not_nil(mod.l1_index_filepath, "Should have l1_index_filepath")
    assert.is_not_nil(mod.l2_index_filepath, "Should have l2_index_filepath")
    assert.is_not_nil(mod.view_config_filepath, "Should have view_config_filepath")
    assert.is_not_nil(mod.l1_config_filepath, "Should have l1_config_filepath")
    assert.is_not_nil(mod.l2_config_filepath, "Should have l2_config_filepath")
    assert.is_not_nil(mod.l1_state_filepath, "Should have l1_state_filepath")
    assert.is_not_nil(mod.l2_state_filepath, "Should have l2_state_filepath")
  end)
end)
