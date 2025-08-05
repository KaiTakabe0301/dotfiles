-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

-- Load custom LSP configuration
require("custom.lspconfig").setup()