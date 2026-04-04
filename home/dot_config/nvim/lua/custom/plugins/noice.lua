return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  keys = {
    {
      "<leader>nd",
      function()
        vim.cmd("Noice dismiss")
        require("notify").dismiss({ pending = true, silent = true })
      end,
      desc = "Dismiss all notifications",
    },
    {
      "<leader>ns",
      function()
        local wins = vim.api.nvim_list_wins()
        local notify_wins = {}
        for _, win in ipairs(wins) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          if ft == "notify" and vim.api.nvim_win_get_config(win).relative ~= "" then
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            table.insert(notify_wins, { win = win, text = table.concat(lines, " ") })
          end
        end
        if #notify_wins == 0 then
          vim.notify("No notifications to dismiss", vim.log.levels.INFO)
          return
        end
        vim.ui.select(notify_wins, {
          prompt = "Select notification to dismiss",
          format_item = function(item) return item.text end,
        }, function(choice)
          if choice then
            local buf = vim.api.nvim_win_get_buf(choice.win)
            pcall(vim.api.nvim_win_close, choice.win, true)
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
          end
        end)
      end,
      desc = "Select and dismiss a notification",
    },
  },
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
    },
    popupmenu = {
      enabled = true,
      backend = "cmp",
    },
    views = {
      cmdline_popup = {
        position = {
          row = "50%",
          col = "50%",
        },
      },
    },
    lsp = {
      signature = { enabled = false },
      hover = { enabled = false },
      progress = { enabled = false },
    },
    presets = {
      command_palette = true,
    },
  },
}
