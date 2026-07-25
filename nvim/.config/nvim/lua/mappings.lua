---@diagnostic disable: undefined-global

require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
-- Window navigation (splits inside one tab). Alt does NOT switch tabs.
map("n", "<A-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<A-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<A-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<A-l>", "<C-w>l", { desc = "Move to right window" })
map("t", "<A-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window" })
map("t", "<A-j>", "<C-\\><C-n><C-w>j", { desc = "Move to lower window" })
map("t", "<A-k>", "<C-\\><C-n><C-w>k", { desc = "Move to upper window" })
map("t", "<A-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window" })

-- Tab page navigation (built-in; e.g. normal edit tab <-> Diffview tab):
--   gt    - next tab
--   gT    - previous tab
--   1gt   - go to tab 1
--   2gt   - go to tab 2
--   :tabn / :tabp / :tabn 2
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

do
  local function kitty_mpv()
    return require "utils.kitty_mpv"
  end
  map({ "n", "x" }, "<leader>mv", function()
    kitty_mpv().play()
  end, { desc = "Play media with Kitty mpv" })
  vim.api.nvim_create_user_command("KittyMpv", function(opts)
    kitty_mpv().play(opts.args ~= "" and opts.args or nil)
  end, { nargs = "?", complete = "file", desc = "Play path/URL with Kitty mpv" })
end

do
  local function opencode()
    return require "utils.opencode"
  end
  local function open(pos, cwd)
    opencode().open {
      pos = pos,
      cwd = cwd ~= "" and cwd or nil,
    }
  end

  map("n", "<leader>oc", function()
    open "float"
  end, { desc = "OpenCode (tmux, float)" })
  map("n", "<leader>oC", function()
    open "sp"
  end, { desc = "OpenCode (tmux, horizontal)" })

  vim.api.nvim_create_user_command("OpenCode", function(opts)
    open("float", opts.args)
  end, { nargs = "?", complete = "dir", desc = "OpenCode in tmux (float term)" })
  vim.api.nvim_create_user_command("OpenCodeSp", function(opts)
    open("sp", opts.args)
  end, { nargs = "?", complete = "dir", desc = "OpenCode in tmux (horizontal split)" })
  vim.api.nvim_create_user_command("OpenCodeVsp", function(opts)
    open("vsp", opts.args)
  end, { nargs = "?", complete = "dir", desc = "OpenCode in tmux (vertical split)" })
end

-- List all markdown tags in cwd as a telescope picker.
-- Nested tags use '/' (e.g. #diary/daily). <CR> greps files containing the tag.
map("n", "<leader>ft", function()
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local builtin = require("telescope.builtin")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  local out = vim.fn.systemlist(
    "rg -oN --no-filename -g '*.md' '#[A-Za-z][A-Za-z0-9_/-]*'"
  )
  if vim.v.shell_error ~= 0 then
    vim.notify("No tags found (or rg failed).", vim.log.levels.WARN)
    return
  end

  local counts = {}
  for _, t in ipairs(out) do
    counts[t] = (counts[t] or 0) + 1
  end

  local tags = {}
  for t, n in pairs(counts) do
    tags[#tags + 1] = string.format("%-30s %3d", t, n)
  end
  table.sort(tags)

  pickers.new({}, {
    prompt_title = "Tags (with counts)",
    finder = finders.new_table({ results = tags }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local sel = action_state.get_selected_entry()
        local tag = sel and sel[1]:match("^(%S+)")
        actions.close(prompt_bufnr)
        if not tag then
          return
        end
        vim.schedule(function()
          builtin.grep_string({ search = tag, additional_args = { "--glob=*.md" } })
        end)
      end)
      return true
    end,
  }):find()
end, { desc = "List all markdown tags" })

-- xattr tags/comment/rating: roundtrips with KDE Dolphin (user.xdg.* + Baloo).
-- Works on any file type since xattr is filesystem-level.
-- Full picker key table and untagged-inventory behavior: lua/utils/xattr.lua header.
--
-- <leader>xt/xc/xr/xs  edit/show current buffer
-- <leader>fx           tag browser → <CR> files → <C-t>/t tag in-place (no close)
do
  local x = function()
    return require "utils.xattr"
  end
  map("n", "<leader>xt", function()
    x().edit_tags()
  end, { desc = "xattr: edit tags" })
  map("n", "<leader>xc", function()
    x().edit_comment()
  end, { desc = "xattr: edit comment" })
  map("n", "<leader>xr", function()
    x().edit_rating()
  end, { desc = "xattr: edit rating" })
  map("n", "<leader>xs", function()
    x().show()
  end, { desc = "xattr: show info" })
  map("n", "<leader>fx", function()
    x().pick_tags()
  end, { desc = "xattr: find by tag (untagged: <C-t>/t to tag)" })

  local function cmd(name, fn)
    vim.api.nvim_create_user_command(name, function(a)
      fn(a.fargs[1] and vim.fn.expand(a.fargs[1]) or nil)
    end, { nargs = "?", complete = "file" })
  end
  cmd("XattrTags", function(p)
    x().edit_tags(p)
  end)
  cmd("XattrComment", function(p)
    x().edit_comment(p)
  end)
  cmd("XattrRating", function(p)
    x().edit_rating(p)
  end)
  cmd("XattrShow", function(p)
    x().show(p)
  end)
  cmd("XattrFind", function()
    x().pick_tags()
  end)
end

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
