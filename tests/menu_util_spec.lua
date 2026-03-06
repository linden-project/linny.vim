-- Unit tests for linny.menu.util module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.menu.util", function()
  local util

  before_each(function()
    package.loaded['linny.menu.util'] = nil
    package.loaded['linny.menu'] = nil
    util = require('linny.menu.util')
  end)

  describe("prepad", function()
    it("pads string with spaces by default", function()
      assert.are.equal("  5", util.prepad("5", 3))
    end)

    it("pads string with custom character", function()
      assert.are.equal("005", util.prepad("5", 3, "0"))
    end)

    it("handles number input", function()
      assert.are.equal(" 42", util.prepad(42, 3))
    end)

    it("returns original if already at target length", function()
      assert.are.equal("abc", util.prepad("abc", 3))
    end)

    it("returns original if longer than target", function()
      assert.are.equal("abcd", util.prepad("abcd", 3))
    end)
  end)

  describe("expand_text", function()
    it("expands expression in text", function()
      assert.are.equal("Value: 2", util.expand_text("Value: %{1+1}"))
    end)

    it("leaves plain text unchanged", function()
      assert.are.equal("Plain text", util.expand_text("Plain text"))
    end)

    it("handles empty string", function()
      assert.are.equal("", util.expand_text(""))
    end)

    it("handles nil", function()
      assert.are.equal("", util.expand_text(nil))
    end)

    it("handles multiple expressions", function()
      assert.are.equal("a=1, b=2", util.expand_text("a=%{1}, b=%{2}"))
    end)
  end)

  describe("slimit", function()
    it("returns empty for limit <= 1", function()
      assert.are.equal("", util.slimit("Hello", 1, 0))
      assert.are.equal("", util.slimit("Hello", 0, 0))
    end)

    it("returns original if shorter than limit", function()
      assert.are.equal("Hi", util.slimit("Hi", 10, 0))
    end)

    it("truncates long strings", function()
      local result = util.slimit("Hello World", 6, 0)
      assert.is_true(vim.fn.strdisplaywidth(result, 0) < 6)
    end)
  end)

  describe("string_capitalize", function()
    it("capitalizes first character", function()
      assert.are.equal("Hello", util.string_capitalize("hello"))
    end)

    it("handles already capitalized", function()
      assert.are.equal("World", util.string_capitalize("World"))
    end)

    it("handles empty string", function()
      assert.are.equal("", util.string_capitalize(""))
    end)

    it("handles nil", function()
      assert.are.equal("", util.string_capitalize(nil))
    end)

    it("handles single character", function()
      assert.are.equal("A", util.string_capitalize("a"))
    end)
  end)

  describe("string_of_length_with_char", function()
    it("creates space padding", function()
      -- Note: Original creates length+1 chars due to >= in loop
      assert.are.equal("      ", util.string_of_length_with_char(" ", 5))
    end)

    it("creates dash line", function()
      assert.are.equal("----", util.string_of_length_with_char("-", 3))
    end)

    it("handles zero length", function()
      assert.are.equal("-", util.string_of_length_with_char("-", 0))
    end)

    it("handles negative length", function()
      assert.are.equal("", util.string_of_length_with_char("-", -1))
    end)
  end)

  describe("calc_active_view_arrow", function()
    it("creates arrow string with position", function()
      local result = util.calc_active_view_arrow({"A", "BB", "CCC"}, 1, 2)
      assert.is_true(result:find("▲") ~= nil)
    end)

    it("handles first view active", function()
      local result = util.calc_active_view_arrow({"A", "BB"}, 0, 2)
      assert.is_true(result:find("▲") ~= nil)
    end)
  end)

  it("module is requireable with all functions", function()
    local ok, mod = pcall(require, 'linny.menu.util')
    assert.is_true(ok, "Should be able to require linny.menu.util")

    -- Check all expected functions exist
    assert.is_not_nil(mod.prepad, "Should have prepad")
    assert.is_not_nil(mod.expand_text, "Should have expand_text")
    assert.is_not_nil(mod.slimit, "Should have slimit")
    assert.is_not_nil(mod.cmdmsg, "Should have cmdmsg")
    assert.is_not_nil(mod.errmsg, "Should have errmsg")
    assert.is_not_nil(mod.highlight, "Should have highlight")
    assert.is_not_nil(mod.string_capitalize, "Should have string_capitalize")
    assert.is_not_nil(mod.string_of_length_with_char, "Should have string_of_length_with_char")
    assert.is_not_nil(mod.calc_active_view_arrow, "Should have calc_active_view_arrow")
  end)

  it("is accessible from menu module", function()
    package.loaded['linny.menu'] = nil
    local menu = require('linny.menu')
    assert.is_not_nil(menu.util, "Should have util submodule")
    assert.is_not_nil(menu.util.string_capitalize, "Should have string_capitalize via menu module")
  end)

  it("is accessible from main module", function()
    package.loaded['linny'] = nil
    local linny = require('linny')
    assert.is_not_nil(linny.menu, "Should have menu submodule")
    assert.is_not_nil(linny.menu.util, "Should have util submodule via main")
    assert.is_not_nil(linny.menu.util.string_capitalize, "Should have string_capitalize via main module")
  end)
end)
