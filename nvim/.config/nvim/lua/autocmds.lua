---@diagnostic disable: undefined-global

require "nvchad.autocmds"

local function apply_code_highlights()
  local hl = vim.api.nvim_set_hl

  hl(0, "UserTodo", { fg = "#ff007c", bold = true })
  hl(0, "Todo", { fg = "#ff007c", bold = true })
  hl(0, "@comment.todo", { fg = "#ff007c", bold = true })
  hl(0, "@text.todo", { fg = "#ff007c", bold = true })

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

local octo_diff_winhighlight = {
  DiffAdd = "UserOctoDiffAdd",
  DiffDelete = "UserOctoDiffDelete",
  DiffChange = "UserOctoDiffChange",
  DiffText = "UserOctoDiffText",
}

local function apply_octo_diff_highlights()
  local hl = vim.api.nvim_set_hl

  hl(0, "UserOctoDiffAdd", { bg = "#1e3a2f" })
  hl(0, "UserOctoDiffDelete", { bg = "#3a252c" })
  hl(0, "UserOctoDiffChange", { bg = "#252b3d" })
  hl(0, "UserOctoDiffText", { bg = "#314f5f" })

  hl(0, "OctoReviewDiffAddText", { bg = "#1e3a2f" })
  hl(0, "OctoReviewDiffDeleteText", { bg = "#3a252c" })
  hl(0, "OctoDiffstatAdditions", { fg = "#a6e3a1" })
  hl(0, "OctoDiffstatDeletions", { fg = "#f38ba8" })
end

local function current_buffer_is_octo_diff()
  local ok = pcall(vim.api.nvim_buf_get_var, 0, "octo_diff_props")
  return ok
end

local function window_has_octo_diff_winhighlight()
  for item in vim.wo.winhighlight:gmatch "[^,]+" do
    local from = item:match "^([^:]+):"
    if from and octo_diff_winhighlight[from] then
      return true
    end
  end

  return false
end

local function update_octo_diff_winhighlight()
  local is_octo_diff = current_buffer_is_octo_diff()
  if not is_octo_diff and not window_has_octo_diff_winhighlight() then
    return
  end

  local values = {}

  for item in vim.wo.winhighlight:gmatch "[^,]+" do
    local from, to = item:match "^([^:]+):(.+)$"
    if from and to and not octo_diff_winhighlight[from] then
      values[from] = to
    end
  end

  if is_octo_diff then
    for from, to in pairs(octo_diff_winhighlight) do
      values[from] = to
    end
  end

  local parts = {}
  for from, to in pairs(values) do
    table.insert(parts, from .. ":" .. to)
  end

  table.sort(parts)
  vim.wo.winhighlight = table.concat(parts, ",")
end

apply_octo_diff_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserOctoDiffHighlights", { clear = true }),
  callback = apply_octo_diff_highlights,
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  group = vim.api.nvim_create_augroup("UserOctoDiffWindowHighlights", { clear = true }),
  callback = update_octo_diff_winhighlight,
})

-- octo PR/issue 描述 buffer：折行在单词边界，缩进跟随，提升长描述可读性
-- review diff 窗口不在这里处理，折行会破坏 diff 对齐
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserOctoWrap", { clear = true }),
  pattern = "octo",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.showbreak = "↳ "
  end,
})

local todo_pattern = [[\c\<TODO\>:?]]

local function apply_todo_match()
  if vim.w.todo_match_id then
    return
  end

  vim.w.todo_match_id = vim.fn.matchadd("UserTodo", todo_pattern, 100)
end

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  group = vim.api.nvim_create_augroup("UserTodoHighlights", { clear = true }),
  pattern = "*",
  callback = apply_todo_match,
})

apply_todo_match()

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ShellLineNumbers", { clear = true }),
  pattern = { "sh", "bash", "zsh" },
  callback = function()
    vim.wo.number = true
  end,
})

local ansi_namespace = vim.api.nvim_create_namespace "AnsiColorPreview"

local ansi_colors = {
  [30] = { name = "black", color = "#1e1e2e" },
  [31] = { name = "red", color = "#f38ba8" },
  [32] = { name = "green", color = "#a6e3a1" },
  [33] = { name = "yellow", color = "#f9e2af" },
  [34] = { name = "blue", color = "#89b4fa" },
  [35] = { name = "purple", color = "#cba6f7" },
  [36] = { name = "cyan", color = "#94e2d5" },
  [37] = { name = "white", color = "#cdd6f4" },
  [90] = { name = "bright black", color = "#6c7086" },
  [91] = { name = "bright red", color = "#eba0ac" },
  [92] = { name = "bright green", color = "#94e2d5" },
  [93] = { name = "bright yellow", color = "#fab387" },
  [94] = { name = "bright blue", color = "#74c7ec" },
  [95] = { name = "bright purple", color = "#f5c2e7" },
  [96] = { name = "bright cyan", color = "#89dceb" },
  [97] = { name = "bright white", color = "#f5e0dc" },
}

local ansi_codes = {
  [0] = { name = "reset", hl = "AnsiStyleReset" },
  [1] = { name = "bold", hl = "AnsiStyleBold" },
  [2] = { name = "faint", hl = "AnsiStyleFaint" },
  [3] = { name = "italic", hl = "AnsiStyleItalic" },
  [4] = { name = "underline", hl = "AnsiStyleUnderline" },
  [5] = { name = "blink", hl = "AnsiStyleBlink" },
  [7] = { name = "inverse", hl = "AnsiStyleInverse" },
}

local function apply_ansi_highlights()
  for code, entry in pairs(ansi_colors) do
    vim.api.nvim_set_hl(0, "AnsiFg" .. code, { fg = entry.color })
    vim.api.nvim_set_hl(0, "AnsiBg" .. code, { fg = "#11111b", bg = entry.color })
  end

  vim.api.nvim_set_hl(0, "AnsiPreviewText", { fg = "#6c7086" })
  vim.api.nvim_set_hl(0, "AnsiStyleReset", { fg = "#6c7086" })
  vim.api.nvim_set_hl(0, "AnsiStyleBold", { fg = "#cdd6f4", bold = true })
  vim.api.nvim_set_hl(0, "AnsiStyleFaint", { fg = "#585b70" })
  vim.api.nvim_set_hl(0, "AnsiStyleItalic", { fg = "#cdd6f4", italic = true })
  vim.api.nvim_set_hl(0, "AnsiStyleUnderline", { fg = "#cdd6f4", underline = true })
  vim.api.nvim_set_hl(0, "AnsiStyleBlink", { fg = "#f9e2af", bold = true })
  vim.api.nvim_set_hl(0, "AnsiStyleInverse", { fg = "#1e1e2e", bg = "#cdd6f4" })
end

local function ansi_preview_chunks(params)
  if params == "" then
    params = "0"
  end

  local chunks = {}

  for param in params:gmatch "%d+" do
    local code = tonumber(param)
    local color = ansi_colors[code]

    if color then
      table.insert(chunks, { color.name, "AnsiFg" .. code })
    elseif code and ansi_colors[code - 10] then
      color = ansi_colors[code - 10]
      table.insert(chunks, { "bg " .. color.name, "AnsiBg" .. (code - 10) })
    elseif ansi_codes[code] then
      local style = ansi_codes[code]
      table.insert(chunks, { style.name, style.hl })
    end
  end

  if #chunks == 0 then
    return nil
  end

  chunks[1][1] = "  ● " .. chunks[1][1]

  for index = 2, #chunks do
    chunks[index][1] = " + " .. chunks[index][1]
  end

  return chunks
end

local function render_ansi_previews(args)
  local bufnr = args.buf

  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end

  local filetype = vim.bo[bufnr].filetype
  if filetype ~= "sh" and filetype ~= "bash" and filetype ~= "zsh" then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ansi_namespace, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for line_number, line in ipairs(lines) do
    local virtual_text = {}

    for params in line:gmatch "\27%[([%d;]*)m" do
      local chunks = ansi_preview_chunks(params)
      if chunks then
        vim.list_extend(virtual_text, chunks)
      end
    end

    for params in line:gmatch "\\e%[([%d;]*)m" do
      local chunks = ansi_preview_chunks(params)
      if chunks then
        vim.list_extend(virtual_text, chunks)
      end
    end

    for params in line:gmatch "\\033%[([%d;]*)m" do
      local chunks = ansi_preview_chunks(params)
      if chunks then
        vim.list_extend(virtual_text, chunks)
      end
    end

    if #virtual_text > 0 then
      vim.api.nvim_buf_set_extmark(bufnr, ansi_namespace, line_number - 1, 0, {
        virt_text = virtual_text,
        virt_text_pos = "eol",
      })
    end
  end
end

apply_ansi_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("AnsiColorPreviewHighlights", { clear = true }),
  callback = apply_ansi_highlights,
})

vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "TextChanged", "TextChangedI" }, {
  group = vim.api.nvim_create_augroup("AnsiColorPreview", { clear = true }),
  pattern = "*",
  callback = render_ansi_previews,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TexSyncServer", { clear = true }),
  pattern = { "tex", "latex" },
  callback = function()
    if #vim.fn.serverlist() == 0 then
      vim.fn.serverstart "/tmp/nvimtex.sock"
    end
  end,
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

-- 打开 epub 时直接 fork zathura 接管渲染，并清掉 nvim 里的二进制 buffer
vim.api.nvim_create_autocmd("BufReadCmd", {
  group = vim.api.nvim_create_augroup("UserEpubZathura", { clear = true }),
  pattern = "*.epub",
  callback = function(args)
    if vim.fn.executable "zathura" ~= 1 then
      vim.notify("zathura 未安装，无法打开 epub: " .. args.file, vim.log.levels.ERROR)
      return
    end

    vim.system({ "zathura", "--fork", args.file }, { detach = true })
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) then
        vim.api.nvim_buf_delete(args.buf, { force = true })
      end
    end)
  end,
})
