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
    -- スワップ（C-a + Alt-h/j/k/l）エッジ検出付き
    {
      "<C-a><M-h>",
      function()
        if vim.bo.filetype == "NvimTree" then
          vim.fn.system("tmux swap-pane -d -t '{left-of}'")
          return
        end
        local cur = vim.api.nvim_get_current_win()
        vim.cmd("wincmd h")
        local neighbor = vim.api.nvim_get_current_win()
        if neighbor == cur then
          vim.fn.system("tmux swap-pane -d -t '{left-of}'")
        elseif vim.bo.filetype == "NvimTree" then
          vim.api.nvim_set_current_win(cur)
          vim.fn.system("tmux swap-pane -d -t '{left-of}'")
        else
          vim.api.nvim_set_current_win(cur)
          require("smart-splits").swap_buf_left()
        end
      end,
      desc = "Swap buffer/pane left",
    },
    {
      "<C-a><M-j>",
      function()
        if vim.bo.filetype == "NvimTree" then
          vim.fn.system("tmux swap-pane -d -t '{down-of}'")
          return
        end
        local cur = vim.api.nvim_get_current_win()
        vim.cmd("wincmd j")
        local neighbor = vim.api.nvim_get_current_win()
        if neighbor == cur then
          vim.fn.system("tmux swap-pane -d -t '{down-of}'")
        elseif vim.bo.filetype == "NvimTree" then
          vim.api.nvim_set_current_win(cur)
          vim.fn.system("tmux swap-pane -d -t '{down-of}'")
        else
          vim.api.nvim_set_current_win(cur)
          require("smart-splits").swap_buf_down()
        end
      end,
      desc = "Swap buffer/pane down",
    },
    {
      "<C-a><M-k>",
      function()
        if vim.bo.filetype == "NvimTree" then
          vim.fn.system("tmux swap-pane -d -t '{up-of}'")
          return
        end
        local cur = vim.api.nvim_get_current_win()
        vim.cmd("wincmd k")
        local neighbor = vim.api.nvim_get_current_win()
        if neighbor == cur then
          vim.fn.system("tmux swap-pane -d -t '{up-of}'")
        elseif vim.bo.filetype == "NvimTree" then
          vim.api.nvim_set_current_win(cur)
          vim.fn.system("tmux swap-pane -d -t '{up-of}'")
        else
          vim.api.nvim_set_current_win(cur)
          require("smart-splits").swap_buf_up()
        end
      end,
      desc = "Swap buffer/pane up",
    },
    {
      "<C-a><M-l>",
      function()
        if vim.bo.filetype == "NvimTree" then
          vim.fn.system("tmux swap-pane -d -t '{right-of}'")
          return
        end
        local cur = vim.api.nvim_get_current_win()
        vim.cmd("wincmd l")
        local neighbor = vim.api.nvim_get_current_win()
        if neighbor == cur then
          vim.fn.system("tmux swap-pane -d -t '{right-of}'")
        elseif vim.bo.filetype == "NvimTree" then
          vim.api.nvim_set_current_win(cur)
          vim.fn.system("tmux swap-pane -d -t '{right-of}'")
        else
          vim.api.nvim_set_current_win(cur)
          require("smart-splits").swap_buf_right()
        end
      end,
      desc = "Swap buffer/pane right",
    },
  },
}
