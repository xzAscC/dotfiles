---@diagnostic disable: undefined-global
require "nvchad.options"

-- add yours here!

vim.opt.termguicolors = true

-- <localleader>：Neovim 默认 nil 时会被展开成空串，octo 等插件注册的
-- <localleader>X 会退化成裸 X 被其他映射截获。显式设成 \ 恢复预期行为。
vim.g.maplocalleader = "\\"

vim.g.sh_fold_enabled = 7

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTreesitterFolds", { clear = true }),
  pattern = { "python", "lua" },
  callback = function()
    local win = vim.api.nvim_get_current_win()

    vim.wo[win].foldmethod = "expr"
    vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo[win].foldlevel = 99
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserShellFolds", { clear = true }),
  pattern = { "sh", "bash", "zsh" },
  callback = function()
    local win = vim.api.nvim_get_current_win()

    vim.wo[win].foldmethod = "syntax"
    vim.wo[win].foldlevel = 99
  end,
})

vim.api.nvim_create_user_command("ClearMarks", function()
  vim.cmd "delmarks!"
  pcall(function()
    vim.cmd "delmarks A-Z0-9"
  end)
  vim.cmd "wshada!"
  vim.notify "Cleared old marks; new marks will still persist"
end, { desc = "Clear local/global marks and persist ShaDa" })

-- NvChad disables Python provider by default; re-enable it for Python tooling.
vim.g.loaded_python3_provider = nil

local nvim_python = vim.fn.expand "~/.local/share/nvim/venv/bin/python"
if vim.fn.executable(nvim_python) == 1 then
  vim.g.python3_host_prog = nvim_python
end

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- vimtex

local is_macos = vim.uv.os_uname().sysname == "Darwin"

if is_macos then
  vim.g.vimtex_view_method = "skim"
elseif vim.fn.executable "zathura" == 1 then
  vim.g.vimtex_view_method = "zathura"
end

vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_compiler_latexmk = {
  options = { "-synctex=1" },
}
vim.g.vimtex_quickfix_mode = 0
vim.o.exrc = true
