require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<C-a>", "<cmd>AerialToggle!<CR>", { desc = "Toggle code outline" })
map("n", "<leader>t]", "<cmd>NvimTreeResize +5<CR>", { desc = "Widen file tree" })
map("n", "<leader>t[", "<cmd>NvimTreeResize -5<CR>", { desc = "Narrow file tree" })
map("n", "<leader>tw", function()
  local width = tonumber(vim.fn.input "NvimTree width: ")

  if not width then
    vim.notify("Invalid width", vim.log.levels.WARN)
    return
  end

  vim.cmd("NvimTreeResize " .. width)
end, { desc = "Set file tree width" })
map("n", "<leader>p", function()
  local pdf = vim.fn.expand "%:p:r" .. ".pdf"
  local sysname = vim.uv.os_uname().sysname

  if vim.fn.filereadable(pdf) == 0 then
    vim.notify("PDF not found: " .. pdf, vim.log.levels.WARN)
    return
  end

  if vim.ui.open then
    vim.ui.open(pdf)
    return
  end

  local open_args

  if sysname == "Darwin" then
    open_args = { "open", pdf }
  else
    open_args = { "xdg-open", pdf }
  end

  local ok = pcall(vim.system, open_args, { detach = true })
  if not ok then
    vim.notify("Failed to open PDF with system opener", vim.log.levels.ERROR)
  end
end, { desc = "Open compiled PDF" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }

    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "gD", vim.lsp.buf.declaration, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
  end,
})

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
