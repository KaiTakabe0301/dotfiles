return {
  "mason-org/mason-lspconfig.nvim",
  config = function()
    require "configs.lspconfig"
  end,
  lazy = false,
  opts = {
    automatic_installation = true,
    ensure_installed = {
      "lua_ls",
      "vtsls",
      "html",
      "cssls",
      "pyright",
      "gopls",
      "rust_analyzer",
      "yamlls",
      "jsonls",
      "bashls",
    },
  },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    { "neovim/nvim-lspconfig", opts = {} },
  },
}
