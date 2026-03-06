-- Unit tests for linny.menu.views module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.menu.views", function()
  local views

  before_each(function()
    package.loaded['linny.menu.views'] = nil
    package.loaded['linny.menu.state'] = nil
    package.loaded['linny.menu'] = nil
    views = require('linny.menu.views')
  end)

  describe("get_list", function()
    it("returns list of view names from config", function()
      local config = { views = { az = { sort = "az" }, date = { sort = "date" } } }
      local result = views.get_list(config)
      assert.are.equal(2, #result)
      assert.is_true(vim.tbl_contains(result, "az"))
      assert.is_true(vim.tbl_contains(result, "date"))
    end)

    it("returns NONE when config has no views", function()
      local result = views.get_list({})
      assert.are.equal(1, #result)
      assert.are.equal("NONE", result[1])
    end)

    it("returns NONE when views is nil", function()
      local result = views.get_list({ views = nil })
      assert.are.equal(1, #result)
      assert.are.equal("NONE", result[1])
    end)

    it("returns NONE when config is nil", function()
      local result = views.get_list(nil)
      assert.are.equal(1, #result)
      assert.are.equal("NONE", result[1])
    end)
  end)

  describe("get_views", function()
    it("returns views dictionary from config", function()
      local config = { views = { az = { sort = "az" } } }
      local result = views.get_views(config)
      assert.is_not_nil(result.az)
      assert.are.equal("az", result.az.sort)
    end)

    it("returns NONE view when config has no views", function()
      local result = views.get_views({})
      assert.is_not_nil(result.NONE)
      assert.are.equal("az", result.NONE.sort)
    end)

    it("returns NONE view when config is nil", function()
      local result = views.get_views(nil)
      assert.is_not_nil(result.NONE)
      assert.are.equal("az", result.NONE.sort)
    end)
  end)

  describe("get_active", function()
    it("returns active_view from state", function()
      local result = views.get_active({ active_view = 2 })
      assert.are.equal(2, result)
    end)

    it("returns 0 when state has no active_view", function()
      local result = views.get_active({})
      assert.are.equal(0, result)
    end)

    it("returns 0 when state is nil", function()
      local result = views.get_active(nil)
      assert.are.equal(0, result)
    end)
  end)

  describe("current_props", function()
    it("returns properties for valid active view", function()
      local views_list = { "az", "date" }
      local views_dict = { az = { sort = "az" }, date = { sort = "date" } }
      local result = views.current_props(1, views_list, views_dict)
      assert.are.equal("date", result.sort)
    end)

    it("returns first view properties when index out of bounds", function()
      local views_list = { "az", "date" }
      local views_dict = { az = { sort = "az" }, date = { sort = "date" } }
      local result = views.current_props(5, views_list, views_dict)
      assert.are.equal("az", result.sort)
    end)

    it("returns first view for index 0", function()
      local views_list = { "az", "date" }
      local views_dict = { az = { sort = "az" }, date = { sort = "date" } }
      local result = views.current_props(0, views_list, views_dict)
      assert.are.equal("az", result.sort)
    end)
  end)

  describe("new_active", function()
    it("cycles forward within bounds", function()
      local result = views.new_active({}, { "a", "b", "c" }, 1, 0)
      assert.are.equal(1, result.active_view)
    end)

    it("wraps to beginning when cycling forward past end", function()
      local result = views.new_active({}, { "a", "b", "c" }, 1, 2)
      assert.are.equal(0, result.active_view)
    end)

    it("cycles backward within bounds", function()
      local result = views.new_active({}, { "a", "b", "c" }, -1, 2)
      assert.are.equal(1, result.active_view)
    end)

    it("wraps to end when cycling backward past beginning", function()
      local result = views.new_active({}, { "a", "b", "c" }, -1, 0)
      assert.are.equal(2, result.active_view)
    end)

    it("preserves other state properties", function()
      local result = views.new_active({ other = "value" }, { "a", "b" }, 1, 0)
      assert.are.equal("value", result.other)
      assert.are.equal(1, result.active_view)
    end)

    it("handles nil state", function()
      local result = views.new_active(nil, { "a", "b" }, 1, 0)
      assert.are.equal(1, result.active_view)
    end)
  end)

  it("module is requireable with all functions", function()
    local ok, mod = pcall(require, 'linny.menu.views')
    assert.is_true(ok, "Should be able to require linny.menu.views")

    assert.is_not_nil(mod.get_list, "Should have get_list")
    assert.is_not_nil(mod.get_views, "Should have get_views")
    assert.is_not_nil(mod.get_active, "Should have get_active")
    assert.is_not_nil(mod.current_props, "Should have current_props")
    assert.is_not_nil(mod.new_active, "Should have new_active")
    assert.is_not_nil(mod.cycle_l1, "Should have cycle_l1")
    assert.is_not_nil(mod.cycle_l2, "Should have cycle_l2")
  end)

  it("is accessible from menu module", function()
    package.loaded['linny.menu'] = nil
    local menu = require('linny.menu')
    assert.is_not_nil(menu.views, "Should have views submodule")
    assert.is_not_nil(menu.views.get_list, "Should have get_list via menu module")
  end)

  it("is accessible from main module", function()
    package.loaded['linny'] = nil
    local linny = require('linny')
    assert.is_not_nil(linny.menu, "Should have menu submodule")
    assert.is_not_nil(linny.menu.views, "Should have views submodule via main")
    assert.is_not_nil(linny.menu.views.get_list, "Should have get_list via main module")
  end)
end)
