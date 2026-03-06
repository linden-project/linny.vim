-- Unit tests for linny.menu.render module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.menu.render", function()
  local render

  before_each(function()
    package.loaded['linny.menu.render'] = nil
    package.loaded['linny.menu'] = nil
    render = require('linny.menu.render')
  end)

  it("module is requireable with all functions", function()
    local ok, mod = pcall(require, 'linny.menu.render')
    assert.is_true(ok, "Should be able to require linny.menu.render")

    assert.is_not_nil(mod.level0, "Should have level0")
    assert.is_not_nil(mod.level1, "Should have level1")
    assert.is_not_nil(mod.level2, "Should have level2")
    assert.is_not_nil(mod.partial_debug_info, "Should have partial_debug_info")
    assert.is_not_nil(mod.partial_footer_items, "Should have partial_footer_items")
    assert.is_not_nil(mod.display_file_ask_view_props, "Should have display_file_ask_view_props")
    assert.is_not_nil(mod.test_file_with_display_expression, "Should have test_file_with_display_expression")
  end)

  it("is accessible from menu module", function()
    package.loaded['linny.menu'] = nil
    local menu = require('linny.menu')
    assert.is_not_nil(menu.render, "Should have render submodule")
    assert.is_not_nil(menu.render.level0, "Should have level0 via menu module")
  end)

  it("is accessible from main module", function()
    package.loaded['linny'] = nil
    local linny = require('linny')
    assert.is_not_nil(linny.menu, "Should have menu submodule")
    assert.is_not_nil(linny.menu.render, "Should have render submodule via main")
    assert.is_not_nil(linny.menu.render.level0, "Should have level0 via main module")
  end)

  describe("test_file_with_display_expression", function()
    it("returns true when IS_SET and key exists", function()
      local file_dict = { status = "active" }
      local expr = { status = "IS_SET" }
      local result = render.test_file_with_display_expression(file_dict, expr)
      assert.is_true(result)
    end)

    it("returns false when IS_SET and key missing", function()
      local file_dict = { title = "Test" }
      local expr = { status = "IS_SET" }
      local result = render.test_file_with_display_expression(file_dict, expr)
      assert.is_false(result)
    end)

    it("returns true when IS_NOT_SET and key missing", function()
      local file_dict = { title = "Test" }
      local expr = { archived = "IS_NOT_SET" }
      local result = render.test_file_with_display_expression(file_dict, expr)
      assert.is_true(result)
    end)

    it("returns false when IS_NOT_SET and key exists", function()
      local file_dict = { archived = true }
      local expr = { archived = "IS_NOT_SET" }
      local result = render.test_file_with_display_expression(file_dict, expr)
      assert.is_false(result)
    end)

    it("returns true when value matches", function()
      local file_dict = { status = "active" }
      local expr = { status = "active" }
      local result = render.test_file_with_display_expression(file_dict, expr)
      assert.is_true(result)
    end)

    it("returns false when value does not match", function()
      local file_dict = { status = "inactive" }
      local expr = { status = "active" }
      local result = render.test_file_with_display_expression(file_dict, expr)
      assert.is_false(result)
    end)

    it("returns false when key missing for value match", function()
      local file_dict = { title = "Test" }
      local expr = { status = "active" }
      local result = render.test_file_with_display_expression(file_dict, expr)
      assert.is_false(result)
    end)
  end)

  describe("display_file_ask_view_props", function()
    it("returns true when no filters", function()
      local view_props = {}
      local file_dict = { title = "Test" }
      local result = render.display_file_ask_view_props(view_props, file_dict)
      assert.is_true(result)
    end)

    it("returns false when except matches", function()
      local view_props = {
        except = {{ archived = "IS_SET" }}
      }
      local file_dict = { archived = true }
      local result = render.display_file_ask_view_props(view_props, file_dict)
      assert.is_false(result)
    end)

    it("returns true when except does not match", function()
      local view_props = {
        except = {{ archived = "IS_SET" }}
      }
      local file_dict = { title = "Test" }
      local result = render.display_file_ask_view_props(view_props, file_dict)
      assert.is_true(result)
    end)

    it("returns true when only matches", function()
      local view_props = {
        only = {{ status = "active" }}
      }
      local file_dict = { status = "active" }
      local result = render.display_file_ask_view_props(view_props, file_dict)
      assert.is_true(result)
    end)

    it("returns false when only does not match", function()
      local view_props = {
        only = {{ status = "active" }}
      }
      local file_dict = { status = "inactive" }
      local result = render.display_file_ask_view_props(view_props, file_dict)
      assert.is_false(result)
    end)

    it("returns true when all only conditions match", function()
      local view_props = {
        only = {
          { status = "active" },
          { priority = "high" }
        }
      }
      local file_dict = { status = "active", priority = "high" }
      local result = render.display_file_ask_view_props(view_props, file_dict)
      assert.is_true(result)
    end)

    it("returns false when not all only conditions match", function()
      local view_props = {
        only = {
          { status = "active" },
          { priority = "high" }
        }
      }
      local file_dict = { status = "active", priority = "low" }
      local result = render.display_file_ask_view_props(view_props, file_dict)
      assert.is_false(result)
    end)
  end)
end)
