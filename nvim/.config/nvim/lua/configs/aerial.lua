---@diagnostic disable: undefined-global

local function is_latex_section_line(line)
  return line:match "^%s*\\section%*?%s*[%[{]"
    or line:match "^%s*\\subsection%*?%s*[%[{]"
    or line:match "^%s*\\subsubsection%*?%s*[%[{]"
end

local function is_tex_filetype(filetype)
  return filetype == "tex" or filetype == "latex" or filetype == "plaintex"
end

local function keep_latex_section_symbol(bufnr, item)
  local line = vim.api.nvim_buf_get_lines(bufnr, item.lnum - 1, item.lnum, false)[1]
  return line and is_latex_section_line(line)
end

local function collect_latex_section_symbols(bufnr, items, output)
  for _, item in ipairs(items) do
    local children = item.children

    if keep_latex_section_symbol(bufnr, item) then
      item.children = nil
      item.parent = nil
      table.insert(output, item)
    end

    if children then
      collect_latex_section_symbols(bufnr, children, output)
    end
  end

  return output
end

-- A "global" variable name: SCREAMING_SNAKE_CASE or a single uppercase letter.
-- Matches MAX_SIZE, PI, X, _INTERNAL; rejects fooBar, my_var, Foo.
local function is_global_var_name(name)
  return type(name) == "string" and name:match "^[A-Z_][A-Z0-9_]*$" ~= nil
end

-- Drop Variable/Constant items whose name is not global-looking.
-- Recurse into children so nested locals inside classes/functions are filtered too.
local function filter_non_global_variables(items)
  local result = {}
  for _, item in ipairs(items) do
    local keep = true
    if item.kind == "Variable" or item.kind == "Constant" then
      keep = is_global_var_name(item.name)
    end

    if keep then
      if item.children then
        item.children = filter_non_global_variables(item.children)
      end
      table.insert(result, item)
    end
  end
  return result
end

return {
  backends = {
    _ = { "lsp", "treesitter", "markdown", "man" },
    tex = { "lsp", "treesitter" },
    latex = { "lsp", "treesitter" },
  },
  layout = {
    default_direction = "right",
    min_width = 30,
  },
  attach_mode = "window",
  close_automatic_events = { "unsupported" },
  highlight_on_hover = true,
  show_guides = true,

  filter_kind = {
    "Class",
    "Constructor",
    "Enum",
    "Function",
    "Interface",
    "Module",
    "Method",
    "Struct",
    "Variable",
    "Constant",
  },
  nerd_font = false,

  post_add_all_symbols = function(bufnr, items)
    local filetype = vim.bo[bufnr].filetype
    if is_tex_filetype(filetype) then
      return collect_latex_section_symbols(bufnr, items, {})
    end

    return filter_non_global_variables(items)
  end,

  guides = {
    mid_item = "├─ ",
    last_item = "└─ ",
    nested_top = "│  ",
    whitespace = "   ",
  },

  icons = {
    tex = {
      Module = "sec ",
      Method = "sec ",
      Collapsed = "▸ ",
    },

    latex = {
      Module = "sec ",
      Method = "sec ",
      Collapsed = "▸ ",
    },

    plaintex = {
      Module = "sec ",
      Method = "sec ",
      Collapsed = "▸ ",
    },

    python = {
      Class = "class ",
      Function = "def ",
      Method = "def ",
      Variable = "var ",
      Constant = "const ",
      Field = "attr ",
      Property = "prop ",
      Module = "mod ",
      Constructor = "new ",
      Collapsed = "▸ ",
    },

    _ = {
      Class = "class ",
      Function = "func ",
      Method = "func ",
      Variable = "var ",
      Constant = "const ",
      Field = "field ",
      Property = "prop ",
      Module = "mod ",
      Collapsed = "▸ ",
    },
  },
}
