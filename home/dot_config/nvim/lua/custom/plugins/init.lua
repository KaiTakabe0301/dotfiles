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

  require "custom.plugins.gitsigns",

  require "custom.plugins.codediff",

  require "custom.plugins.indent-blankline",

  require "custom.plugins.hlchunk",

  require "custom.plugins.rainbow-delimiters",

  require("custom.plugins.whichkey"),

  require("custom.plugins.nvim-tree"),

  require("custom.plugins.notify"),

  require("custom.plugins.noice"),

  require("custom.plugins.copilot"),

  require("custom.plugins.cmp-cmdline"),

  require("custom.plugins.smart-splits"),

  require("custom.plugins.flash"),

  require("custom.plugins.nvim-surround"),

  require("custom.plugins.snacks"),

  require("custom.plugins.auto-save"),

  require("custom.plugins.telescope-ui-select"),

  require("custom.plugins.overseer"),

  {
    "KaiTakabe0301/telescope-live-grep-args.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        extensions = {
          live_grep_args = {
            auto_quoting = true,
          },
        },
      })
      telescope.load_extension("live_grep_args")
    end,
  },
}
