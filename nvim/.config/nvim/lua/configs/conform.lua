local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_organize_imports", "ruff_format" },
    tex = { "latexindent" },
    latex = { "latexindent" },
  },

  formatters = {
    -- latexindent 默认会在 cwd 写 indent.log，保存时自动格式化会留下垃圾文件
    latexindent = { prepend_args = { "-g", "/dev/null" } },
  },

  format_on_save = function(bufnr)
    -- :FormatDisable / :FormatDisable! 临时关闭（全局 / 当前 buffer）
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 1000, lsp_format = "fallback" }
  end,
}

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, { bang = true, desc = "Disable format on save (! for current buffer only)" })

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, { desc = "Re-enable format on save" })

return options
