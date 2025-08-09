-- Custom LSP configuration

local M = {}

M.setup = function()
  local lspconfig = require "lspconfig"
  local nvlsp = require "nvchad.configs.lspconfig"

  -- LSP servers with default config
  local servers = {
    "html",
    "cssls",
    "pyright",
    "gopls",
    "rust_analyzer",
    "yamlls",
    "jsonls",
    "bashls",
  }

  -- Setup servers with default config
  for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
      on_attach = nvlsp.on_attach,
      on_init = nvlsp.on_init,
      capabilities = nvlsp.capabilities,
    }
  end

  -- Lua with enhanced settings
  lspconfig.lua_ls.setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  }
end

return M