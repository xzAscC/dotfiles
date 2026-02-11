require "nvchad.options"

-- add yours here!

vim.opt.termguicolors = true

-- NvChad disables Python provider by default; re-enable it for Python tooling.
vim.g.loaded_python3_provider = nil

local nvim_python = vim.fn.expand "~/.local/share/nvim/venv/bin/python"
if vim.fn.executable(nvim_python) == 1 then
  vim.g.python3_host_prog = nvim_python
end

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

if vim.fn.executable "fish" == 1 then
  vim.o.shell = "fish"
end

-- vimtex

local is_macos = vim.uv.os_uname().sysname == "Darwin"

if is_macos then
  vim.g.vimtex_view_method = "skim"
elseif vim.fn.executable "zathura" == 1 then
  vim.g.vimtex_view_method = "zathura"
end

vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_quickfix_mode = 0
