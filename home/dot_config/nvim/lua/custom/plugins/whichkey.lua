-- which-key設定のカスタマイズ
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
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
      { "<leader>b", group = "Buffers", icon = "󰈔" },
      { "<leader>W", group = "WhichKey", icon = "" },
      { "<leader>L", group = "LSP", icon = "" },
    }
  end,
}
