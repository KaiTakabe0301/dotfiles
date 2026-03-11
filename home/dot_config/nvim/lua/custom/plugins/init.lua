-- Custom plugins initialization

-- Load custom init script
vim.schedule(function()
  local init_path = vim.fn.stdpath "config" .. "/lua/custom/init.lua"
  if vim.fn.filereadable(init_path) == 1 then
    dofile(init_path)
  end
end)

return {
  -- mason.nvim v2 オーバーライド（NvChad デフォルトの williamboman/mason.nvim を置き換え）
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
    opts = {
      PATH = "prepend",
      ensure_installed = {
        -- Formatters
        "black",
        "gofumpt",
        "goimports",
        "prettier",
        "shfmt",
        "stylua",
        -- Linters
        "ruff",
        "mypy",
        "staticcheck",
        "golangci-lint",
        "eslint_d",
        "yamllint",
        "markdownlint",
        "shellcheck",
      },
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
      max_concurrent_installers = 10,
    },
  },

  require("custom.plugins.mason-lspconfig"),

  require "custom.plugins.nvim-vtsls",

  require "custom.plugins.nvim-treesitter",

  require "custom.plugins.nvim-lint",

  require "custom.plugins.lazygit-nvim",

  require "custom.plugins.indent-blankline",

  require "custom.plugins.hlchunk",

  require "custom.plugins.rainbow-delimiters",

  require("custom.plugins.whichkey"),

  require("custom.plugins.nvim-tree"),

  require("custom.plugins.noice"),

  require("custom.plugins.cmp-cmdline"),

  require("custom.plugins.smart-splits"),
}
