return {
  "stevearc/overseer.nvim",
  cmd = {
    "OverseerRun",
    "OverseerToggle",
    "OverseerOpen",
    "OverseerClose",
    "OverseerShell",
    "OverseerTaskAction",
  },
  keys = {
    -- タスク実行・管理 (<leader>o = Overseer)
    { "<leader>oo", "<cmd>OverseerToggle<cr>", desc = "Toggle task list" },
    { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Run task" },
    { "<leader>os", "<cmd>OverseerShell<cr>", desc = "Shell command as task" },
    { "<leader>oa", "<cmd>OverseerTaskAction<cr>", desc = "Task action" },
    { "<leader>ol", function()
      local overseer = require("overseer")
      local task_list = require("overseer.task_list")
      local tasks = overseer.list_tasks({
        status = {
          overseer.STATUS.SUCCESS,
          overseer.STATUS.FAILURE,
          overseer.STATUS.CANCELED,
        },
        sort = task_list.sort_finished_recently,
      })
      if vim.tbl_isempty(tasks) then
        vim.notify("No tasks found", vim.log.levels.WARN)
      else
        overseer.run_action(tasks[1], "restart")
      end
    end, desc = "Restart last task" },
    { "<leader>oq", function()
      local overseer = require("overseer")
      local tasks = overseer.list_tasks({ status = overseer.STATUS.RUNNING })
      if vim.tbl_isempty(tasks) then
        vim.notify("No running tasks", vim.log.levels.WARN)
      else
        tasks[1]:stop()
      end
    end, desc = "Stop running task" },
  },
  config = function()
    local overseer = require("overseer")

    overseer.setup({
      -- DAP 連携を有効化（preLaunchTask / postDebugTask を自動実行）
      dap = true,
      task_list = {
        direction = "bottom",
        min_height = 10,
        max_height = { 20, 0.3 },
        bindings = {
          ["?"] = "ShowHelp",
          ["<CR>"] = "RunAction",
          ["<C-e>"] = "Edit",
          ["o"] = "Open",
          ["<C-v>"] = "OpenVsplit",
          ["<C-s>"] = "OpenSplit",
          ["<C-f>"] = "OpenFloat",
          ["<C-q>"] = "OpenQuickFix",
          ["p"] = "TogglePreview",
          ["{"] = "PrevTask",
          ["}"] = "NextTask",
          ["<C-k>"] = "ScrollOutputUp",
          ["<C-j>"] = "ScrollOutputDown",
          ["dd"] = "Dispose",
          ["q"] = "Close",
        },
      },
      component_aliases = {
        default = {
          "on_exit_set_status",
          { "on_complete_notify", statuses = { "FAILURE" } },
          "on_complete_dispose",
        },
      },
    })

    -- レシピ: 非同期 :Make コマンド
    vim.api.nvim_create_user_command("Make", function(params)
      local cmd, num_subs = vim.o.makeprg:gsub("%$%*", params.args)
      if num_subs == 0 then
        cmd = cmd .. " " .. params.args
      end
      local task = overseer.new_task({
        cmd = vim.fn.expandcmd(cmd),
        components = {
          { "on_output_quickfix", open = not params.bang, open_height = 8, errorformat = vim.o.errorformat },
          "default",
        },
      })
      task:start()
    end, {
      desc = "Async make (overseer)",
      nargs = "*",
      bang = true,
    })

    -- レシピ: 非同期 :Grep コマンド
    vim.api.nvim_create_user_command("Grep", function(params)
      local cmd, num_subs = vim.o.grepprg:gsub("%$%*", params.args)
      if num_subs == 0 then
        cmd = cmd .. " " .. params.args
      end
      local task = overseer.new_task({
        cmd = vim.fn.expandcmd(cmd),
        components = {
          { "on_output_quickfix", errorformat = vim.o.grepformat, open = not params.bang, open_height = 8, items_only = true },
          { "on_complete_dispose", timeout = 30 },
          "default",
        },
      })
      task:start()
    end, {
      desc = "Async grep (overseer)",
      nargs = "*",
      bang = true,
      complete = "file",
    })

    -- レシピ: :OverseerShell の省略形
    vim.cmd.cnoreabbrev("OS", "OverseerShell")
  end,
}
