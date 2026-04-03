return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
    config = function()
      local rd = require("rainbow-delimiters")
      -- 色名の順番 = ネスト1,2,3... の適用順
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = function(bufnr)
            local success, parser = pcall(vim.treesitter.get_parser, bufnr)
            if not success or not parser then
              return nil
            end
            return rd.strategy["global"]
          end,
          vim = rd.strategy["local"], -- VimScriptはローカル推奨
        },
        query = {
          [""] = "rainbow-delimiters", -- デフォルトの括弧クエリ
          lua = "rainbow-blocks", -- lua はブロック強調がきれい
        },
        -- base46 や他のHLより優先されるように少し高め
        priority = { [""] = 210, lua = 210 },
        highlight = {
          "RainbowDelimiterYellow",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
          -- "RainbowDelimiterOrange",
          -- "RainbowDelimiterRed",
          -- "RainbowDelimiterGreen",
          -- "RainbowDelimiterBlue",

        },
      }
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
