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

  require "custom.plugins.codediff",

  require "custom.plugins.indent-blankline",

  require "custom.plugins.hlchunk",

  require "custom.plugins.rainbow-delimiters",

  require("custom.plugins.whichkey"),

  require("custom.plugins.nvim-tree"),

  require("custom.plugins.noice"),

  require("custom.plugins.cmp-cmdline"),

  require("custom.plugins.smart-splits"),

  require("custom.plugins.flash"),

  {
    "KaiTakabe0301/telescope-live-grep-args.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      local telescope = require("telescope")
      local lga_actions = require("telescope-live-grep-args.actions")

      telescope.setup({
        extensions = {
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                ["<C-t>"] = lga_actions.quote_prompt({ postfix = " -t " }),
                ["<C-h>"] = function()
                  local lines = {
                    " Live Grep Args - Help ",
                    "─────────────────────────────",
                    " C-k   クォートで囲む",
                    " C-i   --iglob パターン追加",
                    " C-t   -t ファイルタイプ追加",
                    "─────────────────────────────",
                    " ripgrep フラグ (末尾に追加):",
                    "  -i    大文字小文字を無視",
                    "  -w    単語単位で一致",
                    "  -s    大文字小文字を区別",
                    "  -F    正規表現を無効化",
                    "─────────────────────────────",
                    " 例: \"search\" -i -w",
                  }
                  local buf = vim.api.nvim_create_buf(false, true)
                  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                  local width = 33
                  local height = #lines
                  local win = vim.api.nvim_open_win(buf, false, {
                    relative = "editor",
                    width = width,
                    height = height,
                    col = math.floor((vim.o.columns - width) / 2),
                    row = math.floor((vim.o.lines - height) / 2),
                    style = "minimal",
                    border = "rounded",
                  })
                  vim.api.nvim_set_option_value("winhl", "Normal:Normal,FloatBorder:FloatBorder", { win = win })
                  vim.defer_fn(function()
                    if vim.api.nvim_win_is_valid(win) then
                      vim.api.nvim_win_close(win, true)
                    end
                  end, 5000)
                end,
              },
            },
          },
        },
      })
      telescope.load_extension("live_grep_args")
    end,
  },
}
