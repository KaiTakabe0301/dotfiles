return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
    config = function()
      local rd = require("rainbow-delimiters")
      -- 色名の順番 = ネスト1,2,3... の適用順
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rd.strategy["global"], -- ほぼ全言語で有効
          vim = rd.strategy["local"], -- VimScriptはローカル推奨
        },
        query = {
          [""] = "rainbow-delimiters", -- デフォルトの括弧クエリ
          lua = "rainbow-blocks", -- lua はブロック強調がきれい
        },
        -- base46 や他のHLより優先されるように少し高め
        priority = { [""] = 210, lua = 210 },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterOrange",
          "RainbowDelimiterYellow",
          "RainbowDelimiterGreen",
          "RainbowDelimiterCyan",
          "RainbowDelimiterBlue",
          "RainbowDelimiterViolet",
        },
      }
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
