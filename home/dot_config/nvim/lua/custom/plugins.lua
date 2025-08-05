-- Custom plugins configuration

return {
  -- Mason-lspconfig for automatic LSP installation
  {
    "mason-org/mason-lspconfig.nvim",
     config = function()
       require "configs.lspconfig"
     end,
    lazy = false,
    opts = {
      automatic_installation = true,
    },
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        { "neovim/nvim-lspconfig", opts = {} },
    },
  },

  -- nvim-vtsls for TypeScript
  {
    "yioneko/nvim-vtsls",
    lazy = true,
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("vtsls").config({
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              completeFunctionCalls = true,
            },
          },
        },
      })
    end,
  },

  -- Enhanced TreeSitter language support
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css", "javascript", "typescript", "tsx", "json",
        "python", "go", "rust", "yaml", "toml", "markdown", "bash"
      },
    },
  },

  -- Load none-ls configuration
  require("custom.plugins.none-ls"),
}