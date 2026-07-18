---@diagnostic disable: undefined-global

require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<A-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<A-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<A-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<A-l>", "<C-w>l", { desc = "Move to right window" })
map("t", "<A-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window" })
map("t", "<A-j>", "<C-\\><C-n><C-w>j", { desc = "Move to lower window" })
map("t", "<A-k>", "<C-\\><C-n><C-w>k", { desc = "Move to upper window" })
map("t", "<A-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window" })
map("n", "<C-a>", "<cmd>AerialToggle!<CR>", { desc = "Toggle code outline" })
-- NvimTree resizing
map("n", "<leader>t]", "<cmd>NvimTreeResize +5<CR>", { desc = "Widen file tree" })
map("n", "<leader>t[", "<cmd>NvimTreeResize -5<CR>", { desc = "Narrow file tree" })

-- NvimTree built-in keymaps (inside tree window, no custom mapping needed):
--   m   - toggle bookmark on file/dir
--   M   - toggle "no bookmark" filter (only show bookmarked items)
--   W   - collapse all directories
--   E   - expand all directories
--   zc  - collapse single directory
--   zo  - expand single directory
map("n", "<leader>lc", function()
  vim.cmd "VimtexClean"
  vim.cmd "VimtexCompile"
end, { desc = "Clean then compile LaTeX" })

map("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Open diff view" })
map("n", "<leader>gD", "<cmd>DiffviewOpen main...HEAD<CR>", { desc = "Diff vs main branch" })
map("n", "<leader>gc", "<cmd>DiffviewClose<CR>", { desc = "Close diff view" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", { desc = "File history" })
map("n", "<leader>mp", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle Markdown render" })
map("n", "<leader>mP", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle GitHub Markdown preview" })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserLatexKeymaps", { clear = true }),
  pattern = { "tex", "plaintex", "latex" },
  callback = function(args)
    map("i", "<C-b>", "\\textbf{}<Left>", { buffer = args.buf, desc = "Insert LaTeX textbf" })
  end,
})

map("n", "<leader>lp", function()
  local pdf_path = ""
  if vim.b.vimtex and vim.b.vimtex.pdf then
    pdf_path = vim.b.vimtex.pdf
  else
    pdf_path = vim.fn.expand("%:p:r") .. ".pdf"
  end
  if vim.fn.filereadable(pdf_path) == 1 then
    vim.cmd("tabnew " .. vim.fn.fnameescape(pdf_path))
  else
    vim.notify("PDF not found: " .. pdf_path, vim.log.levels.ERROR)
  end
end, { desc = "Open PDF in tab" })

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
