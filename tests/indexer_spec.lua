describe("linny.indexer", function()
  local indexer
  local original

  local function spy()
    local s = { count = 0, calls = {} }
    s.fn = function(...)
      s.count = s.count + 1
      table.insert(s.calls, { ... })
    end
    return s
  end

  local function temp_notebook()
    local dir = vim.fn.tempname()
    vim.fn.mkdir(dir .. '/lindenIndex', 'p')
    return dir
  end

  local function write_info(notebook, info)
    local path = notebook .. '/lindenIndex/_indexer_info.json'
    local file = assert(io.open(path, 'w'))
    file:write(vim.json.encode(info))
    file:close()
  end

  before_each(function()
    package.loaded['linny.indexer'] = nil
    package.loaded['linny.hugo'] = nil
    indexer = require('linny.indexer')
    indexer.clear_cache()

    original = {
      exepath = vim.fn.exepath,
      system = vim.fn.system,
      jobstart = vim.fn.jobstart,
      jobstop = vim.fn.jobstop,
      notify = vim.notify,
    }

    vim.g.linny_index_hook_enabled = nil
    vim.g.linny_hugo_hook_enabled = nil
    vim.g.linny_index_watch_enabled = nil
    vim.g.linny_hugo_watch_enabled = nil
  end)

  after_each(function()
    vim.fn.exepath = original.exepath
    vim.fn.system = original.system
    vim.fn.jobstart = original.jobstart
    vim.fn.jobstop = original.jobstop
    vim.notify = original.notify
    vim.g.linny_index_hook_enabled = nil
    vim.g.linny_hugo_hook_enabled = nil
    vim.g.linny_index_watch_enabled = nil
    vim.g.linny_hugo_watch_enabled = nil
  end)

  describe("detect", function()
    it("prefers lindexer when it is on PATH", function()
      vim.fn.exepath = function(name)
        return name == 'lindexer' and '/usr/bin/lindexer' or ''
      end
      indexer._run_command = function() return 'lindexer 0.2.0', 0 end

      local result = indexer.detect()
      assert.are.equal('lindexer', result.backend)
      assert.is_true(result.available)
      assert.are.equal('0.2.0', result.version)
    end)

    it("falls back to Hugo and notifies once", function()
      local notified = spy()
      vim.notify = notified.fn
      vim.fn.exepath = function(name)
        return name == 'hugo' and '/usr/bin/hugo' or ''
      end
      indexer._run_command = function() return 'hugo v0.155.3+extended', 0 end

      local first = indexer.detect()
      assert.are.equal('hugo', first.backend)
      assert.are.equal(1, notified.count)

      indexer.detect(true)
      assert.are.equal(1, notified.count)
    end)

    it("reports no backend when nothing is installed", function()
      vim.fn.exepath = function() return '' end
      local result = indexer.detect()
      assert.is_false(result.available)
      assert.is_nil(result.backend)
    end)

    it("caches and clears the detection result", function()
      vim.fn.exepath = function(name)
        return name == 'lindexer' and '/usr/bin/lindexer' or ''
      end
      indexer._run_command = function() return 'lindexer 0.2.0', 0 end

      local first = indexer.detect()
      assert.are.equal(first, indexer.detect())
      indexer.clear_cache()
      assert.are_not.equal(first, indexer.detect())
    end)
  end)

  describe("build", function()
    it("requires a notebook path", function()
      local result = indexer.build(nil)
      assert.is_false(result.ok)
      assert.are.equal('No notebook path provided', result.error)
    end)

    it("runs the lindexer build command", function()
      local notebook = temp_notebook()
      vim.fn.exepath = function(name)
        return name == 'lindexer' and '/usr/bin/lindexer' or ''
      end
      indexer._run_command = function() return 'ok', 0 end
      indexer.detect()
      local commands = {}
      indexer._run_command = function(command)
        table.insert(commands, command)
        return 'ok', 0
      end
      write_info(notebook, { product_name = 'lindexer', index_format_version = 1 })

      local result = indexer.build(notebook)
      assert.is_true(result.ok)
      assert.are.equal('lindexer', result.backend)
      assert.are.equal(1, #commands)
      assert.matches('lindexer build %-%-corpus', commands[1])
      assert.matches('%-%-index', commands[1])
    end)

    it("reports backend failure without raising", function()
      local notebook = temp_notebook()
      vim.fn.exepath = function(name)
        return name == 'lindexer' and '/usr/bin/lindexer' or ''
      end
      indexer._run_command = function(command)
        if command:match('version') then return 'lindexer 0.2.0', 0 end
        return 'boom', 1
      end

      local result = indexer.build(notebook)
      assert.is_false(result.ok)
      assert.are.equal('boom', result.error)
    end)

    it("reports no backend", function()
      local notebook = temp_notebook()
      vim.fn.exepath = function() return '' end
      local result = indexer.build(notebook)
      assert.is_false(result.ok)
      assert.are.equal('No index backend found', result.error)
    end)
  end)

  describe("check_format", function()
    it("warns when the metadata file is missing", function()
      local notified = spy()
      vim.notify = notified.fn
      local result = indexer.check_format(temp_notebook(), 'lindexer')
      assert.is_false(result.ok)
      assert.matches('metadata missing', result.warning)
    end)

    it("warns when the format version is missing", function()
      local notebook = temp_notebook()
      write_info(notebook, { product_name = 'lindexer' })
      local result = indexer.check_format(notebook, 'hugo')
      assert.is_false(result.ok)
      assert.matches('format unknown', result.warning)
      assert.matches('hugo', result.warning)
    end)

    it("warns when the format version is too old", function()
      local notebook = temp_notebook()
      write_info(notebook, { index_format_version = 0 })
      local result = indexer.check_format(notebook, 'lindexer')
      assert.is_false(result.ok)
      assert.matches('older than', result.warning)
      assert.matches('1', result.warning)
    end)

    it("accepts a supported format version", function()
      local notebook = temp_notebook()
      write_info(notebook, { index_format_version = 1 })
      local result = indexer.check_format(notebook, 'lindexer')
      assert.is_true(result.ok)
      assert.are.equal(1, result.version)
    end)

    it("warns once per session", function()
      local notified = spy()
      vim.notify = notified.fn
      local notebook = temp_notebook()
      write_info(notebook, { index_format_version = 0 })
      indexer.check_format(notebook, 'lindexer')
      indexer.check_format(notebook, 'lindexer')
      assert.are.equal(1, notified.count)
    end)
  end)

  describe("configuration", function()
    it("defaults the hook to enabled", function()
      assert.is_true(indexer.hook_enabled())
    end)

    it("reads the deprecated hugo hook alias", function()
      vim.g.linny_hugo_hook_enabled = 0
      assert.is_false(indexer.hook_enabled())
    end)

    it("prefers the new hook variable over the alias", function()
      vim.g.linny_hugo_hook_enabled = 0
      vim.g.linny_index_hook_enabled = 1
      assert.is_true(indexer.hook_enabled())
    end)

    it("defaults watch to disabled and reads the alias", function()
      assert.is_false(indexer.watch_enabled())
      vim.g.linny_hugo_watch_enabled = 1
      assert.is_true(indexer.watch_enabled())
      vim.g.linny_index_watch_enabled = 0
      assert.is_false(indexer.watch_enabled())
    end)
  end)

  describe("watch", function()
    local function detect_lindexer()
      vim.fn.exepath = function(name)
        return name == 'lindexer' and '/usr/bin/lindexer' or ''
      end
      indexer._run_command = function() return 'lindexer 0.2.0', 0 end
    end

    it("starts lindexer watch with a state dir and index", function()
      detect_lindexer()
      local started
      vim.fn.jobstart = function(command)
        started = command
        return 42
      end

      local notebook = temp_notebook()
      local result = indexer.start_watch(notebook)
      assert.is_true(result.ok)
      assert.are.equal(42, result.job_id)
      assert.are.equal('lindexer', started[1])
      assert.are.equal('watch', started[2])
      assert.are.equal('--corpus', started[3])
      assert.are.equal(notebook, started[4])
      assert.are.equal('--state-dir', started[5])
      assert.matches('/linny/', started[6])
      assert.are.equal('--index', started[7])
      assert.are.equal(notebook .. '/lindenIndex', started[8])
      assert.is_true(indexer.is_watching())
    end)

    it("returns the existing process instead of starting a second one", function()
      detect_lindexer()
      local calls = 0
      vim.fn.jobstart = function() calls = calls + 1; return 42 end
      local notebook = temp_notebook()

      indexer.start_watch(notebook)
      local second = indexer.start_watch(notebook)
      assert.is_true(second.ok)
      assert.is_true(second.already)
      assert.are.equal(1, calls)
    end)

    it("fails without a backend", function()
      vim.fn.exepath = function() return '' end
      local started = false
      vim.fn.jobstart = function() started = true; return 1 end

      local result = indexer.start_watch(temp_notebook())
      assert.is_false(result.ok)
      assert.is_false(started)
    end)

    it("returns an empty result without a notebook", function()
      local result = indexer.start_watch(nil)
      assert.are.same({}, result)
    end)

    it("stops the active watch and clears the job id", function()
      detect_lindexer()
      vim.fn.jobstart = function() return 42 end
      local stopped
      vim.fn.jobstop = function(job) stopped = job end

      indexer.start_watch(temp_notebook())
      local result = indexer.stop_watch()
      assert.is_true(result.stopped)
      assert.are.equal(42, stopped)
      assert.is_false(indexer.is_watching())
    end)

    it("reports stopped when nothing is running", function()
      local result = indexer.stop_watch()
      assert.is_false(result.stopped)
    end)

    it("reports status with the owning backend", function()
      detect_lindexer()
      vim.fn.jobstart = function() return 42 end
      indexer.start_watch(temp_notebook())

      local status = indexer.status()
      assert.is_true(status.watching)
      assert.are.equal('lindexer', status.backend)
      assert.are.equal('watching', indexer.get_watch_status())
    end)

    it("autostarts once when enabled", function()
      detect_lindexer()
      local calls = 0
      vim.fn.jobstart = function() calls = calls + 1; return 42 end
      vim.g.linny_index_watch_enabled = 1
      vim.g.linny_open_notebook_path = temp_notebook()

      local result = indexer.auto_start_watch()
      assert.is_true(result.ok)
      indexer.auto_start_watch()
      assert.are.equal(1, calls)
      assert.is_true(indexer.watch_auto_started())
    end)

    it("does not autostart when disabled", function()
      detect_lindexer()
      local calls = 0
      vim.fn.jobstart = function() calls = calls + 1; return 42 end
      vim.g.linny_open_notebook_path = temp_notebook()

      assert.is_nil(indexer.auto_start_watch())
      assert.are.equal(0, calls)
    end)

    it("stops the watch process on exit", function()
      detect_lindexer()
      vim.fn.jobstart = function() return 42 end
      local stopped
      vim.fn.jobstop = function(job) stopped = job end

      indexer.start_watch(temp_notebook())
      vim.api.nvim_exec_autocmds('VimLeavePre', {})
      assert.are.equal(42, stopped)
    end)
  end)
end)
