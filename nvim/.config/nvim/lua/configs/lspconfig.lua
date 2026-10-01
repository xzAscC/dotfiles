local nvlsp = require "nvchad.configs.lspconfig"

-- 设置 capabilities/on_init（通过 vim.lsp.config "*"），注册 LspAttach 映射，并启用 lua_ls
nvlsp.defaults()

-- Detect project-local Python venv
local function get_python_path(workspace)
  -- 1. Check VIRTUAL_ENV environment variable
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. "/bin/python"
  end

  workspace = workspace or vim.uv.cwd()

  -- 2. Check for .venv or venv in project root
  for _, venv in ipairs { ".venv", "venv" } do
    local path = workspace .. "/" .. venv .. "/bin/python"
    if vim.fn.executable(path) == 1 then
      return path
    end
  end

  -- 3. Fallback to system python
  local system_python = vim.fn.exepath "python3"
  return system_python ~= "" and system_python or "python3"
end

vim.lsp.config("pyright", {
  before_init = function(_, config)
    config.settings.python.pythonPath = get_python_path(config.root_dir)
  end,
  settings = {
    pyright = {
      -- import 整理交给 ruff
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
})

vim.lsp.config("ruff", {
  on_attach = function(client)
    -- hover 交给 pyright，ruff 只负责 lint / code action
    client.server_capabilities.hoverProvider = false
  end,
})

vim.lsp.config("texlab", {
  settings = {
    texlab = {
      build = {
        onSave = false, -- let vimtex handle compilation
      },
      forwardSearch = {
        executable = "zathura",
        args = { "--synctex-forward", "%l:%f:%p" },
      },
      chktex = {
        onOpenAndSave = true,
      },
    },
  },
})

vim.lsp.config("bashls", {
  filetypes = { "sh", "bash" },
})

vim.lsp.enable { "pyright", "ruff", "texlab", "bashls", "marksman" }
