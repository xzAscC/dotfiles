---@diagnostic disable: undefined-global

local function is_tex_filetype(filetype)
  return filetype == "tex" or filetype == "latex" or filetype == "plaintex"
end

-- texlab tags every LaTeX sectioning level (\part, \chapter, \section,
-- \subsection, \subsubsection, \paragraph, \subparagraph) with the single
-- SymbolKind "Module". No non-section construct shares that kind (figures,
-- tables, algorithms and listings are "Method"; equations are "Constant";
-- itemize/enumerate are "Enum"). Selecting by kind avoids re-reading live
-- buffer lines, which went stale whenever an edit shifted lines between LSP
-- refreshes and dropped valid sections from the outline.
local LATEX_SECTION_KIND = "Module"

local function collect_latex_section_symbols(items, output)
  for _, item in ipairs(items) do
    local children = item.children

    if item.kind == LATEX_SECTION_KIND then
      item.children = nil
      item.parent = nil
      table.insert(output, item)
    end

    if children then
      collect_latex_section_symbols(children, output)
    end
  end

  return output
end

-- After \appendix texlab numbers sections with letters ("A Proofs", "B.1 Code")
-- instead of digits. Retag those as "Namespace" (unused by texlab) so they get
-- their own icon. Requiring a digit-numbered section elsewhere guards against
-- unnumbered titles like "A Brief History" when no .aux file exists yet.
local LATEX_APPENDIX_KIND = "Namespace"

local function mark_latex_appendix_sections(items)
  local numbered = false
  for _, item in ipairs(items) do
    if item.name:match "^%d" then
      numbered = true
      break
    end
  end

  if numbered then
    for _, item in ipairs(items) do
      if item.name:match "^%u[%.%d]*%s" then
        item.kind = LATEX_APPENDIX_KIND
      end
    end
  end

  return items
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
      return mark_latex_appendix_sections(collect_latex_section_symbols(items, {}))
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
      Namespace = "app ",
      Collapsed = "▸ ",
    },

    latex = {
      Module = "sec ",
      Method = "sec ",
      Namespace = "app ",
      Collapsed = "▸ ",
    },

    plaintex = {
      Module = "sec ",
      Method = "sec ",
      Namespace = "app ",
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
