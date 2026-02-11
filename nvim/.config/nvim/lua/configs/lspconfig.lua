local nvlsp = require "nvchad.configs.lspconfig"

nvlsp.defaults()

local servers = { "pyright" }

for _, server in ipairs(servers) do
  vim.lsp.config(server, {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  })

  vim.lsp.enable(server)
end
