-- which-key設定のカスタマイズ
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    -- ? キーで which-key ポップアップを表示するキーマッピング
    vim.keymap.set("n", "?", function()
      require("which-key").show()
    end, { desc = "Which Key" })

    -- グローバルアイコン設定
    opts.icons = vim.tbl_deep_extend("force", opts.icons or {}, {
      breadcrumb = "»",
      separator = "➜",
      group = "+", -- グループのデフォルトアイコン
    })

    -- which-keyインスタンスを取得してグループを登録
    local wk = require "which-key"

    -- 静的グループの登録（アイコンは別プロパティで設定）
    wk.add {
      { "<leader>f", group = "Find", icon = "" },
      { "<leader>b", group = "Buffers", icon = "󰈔" },
      { "<leader>g", group = "Git", icon = "" },
      { "<leader>W", group = "WhichKey", icon = "" },
      { "<leader>L", group = "LSP", icon = "" },
      { "<leader>a", group = "AI/Copilot", icon = "" },
    }
  end,
}
