return {
  "mrjones2014/smart-splits.nvim",
  event = "VeryLazy",
  opts = {
    ignored_filetypes = { "NvimTree" },
  },
  keys = {
    -- スプリット/ペイン間の移動（C-a + h/j/k/l）
    { "<C-a>h", function() require("smart-splits").move_cursor_left() end, desc = "Move to left split/pane" },
    { "<C-a>j", function() require("smart-splits").move_cursor_down() end, desc = "Move to down split/pane" },
    { "<C-a>k", function() require("smart-splits").move_cursor_up() end, desc = "Move to up split/pane" },
    { "<C-a>l", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split/pane" },
    -- リサイズ（C-a + H/J/K/L）
    { "<C-a>H", function() require("smart-splits").resize_left() end, desc = "Resize left" },
    { "<C-a>J", function() require("smart-splits").resize_down() end, desc = "Resize down" },
    { "<C-a>K", function() require("smart-splits").resize_up() end, desc = "Resize up" },
    { "<C-a>L", function() require("smart-splits").resize_right() end, desc = "Resize right" },
  },
}
