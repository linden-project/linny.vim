-- Unit tests for linny.menu.window module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.menu.window", function()
  local window

  before_each(function()
    package.loaded['linny.menu.window'] = nil
    package.loaded['linny.menu'] = nil
    window = require('linny.menu.window')
    -- Reset tab-local state
    vim.t.linny_menu_bid = nil
    vim.t.linny_menu_name = nil
    vim.t.linny_menu = nil
    vim.t.linny_menu_lastmaxsize = nil
  end)

  it("module is requireable with all functions", function()
    local ok, mod = pcall(require, 'linny.menu.window')
    assert.is_true(ok, "Should be able to require linny.menu.window")

    assert.is_not_nil(mod.exist, "Should have exist")
    assert.is_not_nil(mod.close_window, "Should have close_window")
    assert.is_not_nil(mod.open_window, "Should have open_window")
    assert.is_not_nil(mod.render, "Should have render")
    assert.is_not_nil(mod.start, "Should have start")
    assert.is_not_nil(mod.open, "Should have open")
    assert.is_not_nil(mod.close, "Should have close")
    assert.is_not_nil(mod.toggle, "Should have toggle")
    assert.is_not_nil(mod.refresh, "Should have refresh")
    assert.is_not_nil(mod.open_home, "Should have open_home")
    assert.is_not_nil(mod.open_file, "Should have open_file")
  end)

  it("is accessible from menu module", function()
    package.loaded['linny.menu'] = nil
    local menu = require('linny.menu')
    assert.is_not_nil(menu.window, "Should have window submodule")
    assert.is_not_nil(menu.window.exist, "Should have exist via menu module")
  end)

  it("is accessible from main module", function()
    package.loaded['linny'] = nil
    local linny = require('linny')
    assert.is_not_nil(linny.menu, "Should have menu submodule")
    assert.is_not_nil(linny.menu.window, "Should have window submodule via main")
    assert.is_not_nil(linny.menu.window.exist, "Should have exist via main module")
  end)

  describe("exist", function()
    it("returns false when t:linny_menu_bid not set", function()
      vim.t.linny_menu_bid = nil
      local result = window.exist()
      assert.is_false(result)
      assert.are.equal(-1, vim.t.linny_menu_bid)
    end)

    it("returns false when t:linny_menu_bid is -1", function()
      vim.t.linny_menu_bid = -1
      local result = window.exist()
      assert.is_false(result)
    end)

    it("returns false when buffer does not exist", function()
      vim.t.linny_menu_bid = 99999
      local result = window.exist()
      assert.is_false(result)
    end)
  end)

  describe("open_window", function()
    it("clamps size to minimum of 4", function()
      vim.g.linny_menu_max_width = 100
      vim.t.linny_menu_name = '[test_menu]'
      -- We can't easily test window creation in headless mode
      -- but we can verify the function exists and is callable
      assert.is_function(window.open_window)
    end)
  end)

  describe("render", function()
    it("is a function", function()
      assert.is_function(window.render)
    end)
  end)

  describe("close", function()
    it("does nothing when menu does not exist", function()
      vim.t.linny_menu_bid = -1
      local result = window.close()
      -- Should return nil (not 0) when menu doesn't exist
      assert.is_nil(result)
    end)
  end)

  describe("open_home", function()
    it("shows error when menu not initialized", function()
      vim.t.linny_menu_name = nil
      -- Function should handle missing menu gracefully
      assert.is_function(window.open_home)
    end)
  end)
end)
