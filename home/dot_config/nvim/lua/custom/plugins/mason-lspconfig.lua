return {
  "mason-org/mason-lspconfig.nvim",
  config = function(_, opts)
    -- 1. NvChad defaults（グローバル config、LspAttach keymaps、lua_ls 設定）
    -- 2. カスタムサーバ設定（vim.lsp.config API）
    require("configs.lspconfig")
    -- 3. mason-lspconfig（automatic_enable で全サーバを vim.lsp.enable）
    require("mason-lspconfig").setup(opts)
  end,
  lazy = false,
  opts = {
    ensure_installed = {
      "lua_ls",
      "stylua",
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
    automatic_enable = true,
  },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    { "neovim/nvim-lspconfig", opts = {} },
  },
}
