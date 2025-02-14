-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

--Set default python3 path
vim.g.python3_host_prog = "/usr/bin/python3"
--Disable smartindent (use "tresitter.indent" better)
vim.opt.smartindent = false
-- Adjust line number width
-- vim.o.signcolumn = "yes:2"
