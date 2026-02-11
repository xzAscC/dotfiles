require "nvchad.autocmds"

local function apply_code_highlights()
  local hl = vim.api.nvim_set_hl

  hl(0, "@function", { fg = "#7aa2f7", bold = true })
  hl(0, "@function.call", { fg = "#89b4fa" })
  hl(0, "@method", { fg = "#7dcfff" })
  hl(0, "@keyword", { fg = "#cba6f7" })
  hl(0, "@type", { fg = "#f9e2af" })
  hl(0, "@variable", { fg = "#cdd6f4" })
  hl(0, "@string", { fg = "#a6e3a1" })
  hl(0, "@comment", { fg = "#6c7086", italic = true })

  hl(0, "@lsp.type.function", { fg = "#7aa2f7", bold = true })
  hl(0, "@lsp.type.method", { fg = "#7dcfff" })
  hl(0, "@lsp.type.variable", { fg = "#cdd6f4" })
end

apply_code_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserCodeHighlights", { clear = true }),
  callback = apply_code_highlights,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("CloseNvimTreeOnLastWindow", { clear = true }),
  callback = function()
    if vim.bo.filetype ~= "NvimTree" then
      return
    end

    if vim.fn.winnr("$") == 1 then
      vim.cmd "quit"
    end
  end,
})
