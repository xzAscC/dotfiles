local vim = rawget(_G, "vim")
local nvlsp = require "nvchad.configs.lspconfig"

nvlsp.defaults()

-- Detect project-local Python venv
local function get_python_path(workspace)
  -- 1. Check VIRTUAL_ENV environment variable
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. "/bin/python"
  end

  workspace = workspace or vim.uv.cwd()

  -- 2. Check for .venv or venv in project root
  local candidates = {
    workspace .. "/.venv/bin/python",
    workspace .. "/venv/bin/python",
  }

  for _, path in ipairs(candidates) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end

  -- 3. Fallback to system python
  return vim.fn.exepath("python3") or "python3"
end

vim.lsp.config("pyright", {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  before_init = function(_, config)
    config.settings = config.settings or {}
    config.settings.python = config.settings.python or {}
    config.settings.python.pythonPath = get_python_path(config.root_dir)
  end,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
})

vim.lsp.enable "pyright"

vim.lsp.config("texlab", {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
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

vim.lsp.enable "texlab"

vim.lsp.config("bashls", {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  filetypes = { "sh", "bash" },
})

vim.lsp.enable "bashls"
