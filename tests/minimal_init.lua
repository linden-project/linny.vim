-- Minimal init for plenary tests
-- Uses current working directory as plugin path
local plugin_path = vim.fn.getcwd()
vim.opt.runtimepath:prepend(plugin_path)
vim.cmd([[runtime plugin/linny.vim]])
