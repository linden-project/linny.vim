-- Unit tests for linny.menu.state module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.menu.state", function()
  local state

  before_each(function()
    package.loaded['linny.menu.state'] = nil
    package.loaded['linny.menu'] = nil
    state = require('linny.menu.state')
    -- Reset tab-local variables
    vim.t.linny_menu_name = nil
    vim.t.linny_menu_items = nil
    vim.t.linny_tasks_count = nil
    vim.t.linny_menu_cursor = nil
    vim.t.linny_menu_line = nil
    vim.t.linny_menu_lastmaxsize = nil
    vim.t.linny_menu_view = nil
    vim.t.linny_menu_taxonomy = nil
    vim.t.linny_menu_term = nil
    -- Reset global tab counter
    vim.g.linnytabnr = 0
  end)

  describe("new_tab_nr", function()
    it("generates unique tab numbers", function()
      vim.g.linnytabnr = 0
      local nr1 = state.new_tab_nr()
      local nr2 = state.new_tab_nr()
      local nr3 = state.new_tab_nr()

      assert.are.equal(1, nr1)
      assert.are.equal(2, nr2)
      assert.are.equal(3, nr3)
    end)

    it("increments g:linnytabnr", function()
      vim.g.linnytabnr = 5
      state.new_tab_nr()
      assert.are.equal(6, vim.g.linnytabnr)
    end)
  end)

  describe("tab_init", function()
    it("initializes tab state for new tab", function()
      vim.g.linnytabnr = 0
      state.tab_init()

      assert.is_not_nil(vim.t.linny_menu_name)
      assert.is_true(vim.startswith(vim.t.linny_menu_name, '[linny_menu]'))
      assert.are.same({}, vim.t.linny_menu_items)
      assert.are.same({}, vim.t.linny_tasks_count)
      assert.are.equal(0, vim.t.linny_menu_cursor)
      assert.are.equal(0, vim.t.linny_menu_line)
      assert.are.equal(0, vim.t.linny_menu_lastmaxsize)
      assert.are.equal('', vim.t.linny_menu_view)
      assert.are.equal('', vim.t.linny_menu_taxonomy)
      assert.are.equal('', vim.t.linny_menu_term)
    end)

    it("skips initialization if already initialized", function()
      vim.g.linnytabnr = 0
      vim.t.linny_menu_name = 'existing_name'
      vim.t.linny_menu_cursor = 999

      state.tab_init()

      -- Should not be modified
      assert.are.equal('existing_name', vim.t.linny_menu_name)
      assert.are.equal(999, vim.t.linny_menu_cursor)
    end)
  end)

  describe("reset", function()
    it("resets menu state variables", function()
      vim.t.linny_menu_items = { item1 = "test" }
      vim.t.linny_menu_line = 42
      vim.t.linny_menu_cursor = 24

      state.reset()

      assert.are.same({}, vim.t.linny_menu_items)
      assert.are.equal(0, vim.t.linny_menu_line)
      assert.are.equal(0, vim.t.linny_menu_cursor)
    end)
  end)

  it("module is requireable with all functions", function()
    local ok, mod = pcall(require, 'linny.menu.state')
    assert.is_true(ok, "Should be able to require linny.menu.state")

    -- Check all expected functions exist
    assert.is_not_nil(mod.tab_init, "Should have tab_init")
    assert.is_not_nil(mod.new_tab_nr, "Should have new_tab_nr")
    assert.is_not_nil(mod.term_leaf_state, "Should have term_leaf_state")
    assert.is_not_nil(mod.term_value_leaf_state, "Should have term_value_leaf_state")
    assert.is_not_nil(mod.write_term_leaf_state, "Should have write_term_leaf_state")
    assert.is_not_nil(mod.write_term_value_leaf_state, "Should have write_term_value_leaf_state")
    assert.is_not_nil(mod.reset, "Should have reset")
  end)

  it("is accessible from menu module", function()
    package.loaded['linny.menu'] = nil
    local menu = require('linny.menu')
    assert.is_not_nil(menu.state, "Should have state submodule")
    assert.is_not_nil(menu.state.tab_init, "Should have tab_init via menu module")
  end)

  it("is accessible from main module", function()
    package.loaded['linny'] = nil
    local linny = require('linny')
    assert.is_not_nil(linny.menu, "Should have menu submodule")
    assert.is_not_nil(linny.menu.state, "Should have state submodule via main")
    assert.is_not_nil(linny.menu.state.tab_init, "Should have tab_init via main module")
  end)
end)
