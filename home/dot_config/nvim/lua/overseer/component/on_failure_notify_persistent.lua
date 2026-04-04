---@type overseer.ComponentFileDefinition
return {
  desc = "Show real-time output during task execution, persistent notification on failure",
  params = {
    max_lines = { type = "integer", default = 3, desc = "Max lines to show" },
    delay_ms = { type = "integer", default = 1000, desc = "Delay before showing notifications" },
  },
  constructor = function(params)
    local lines_buf = {}
    local notif_id = nil
    local started_at = nil

    return {
      on_start = function(self, task)
        lines_buf = {}
        notif_id = nil
        started_at = vim.uv.now()
      end,
      on_output_lines = function(self, task, data)
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(lines_buf, line)
          end
        end
        -- max_lines 分だけ保持
        while #lines_buf > params.max_lines do
          table.remove(lines_buf, 1)
        end
        -- delay_ms 経過後に通知を更新
        if started_at and (vim.uv.now() - started_at) >= params.delay_ms then
          local text = "RUNNING " .. task.name .. "\n" .. table.concat(lines_buf, "\n")
          local ret = vim.notify(text, vim.log.levels.INFO, {
            title = "Overseer",
            replace = notif_id,
            timeout = false,
            hide_from_history = true,
          })
          notif_id = ret and ret.id
        end
      end,
      on_complete = function(self, task, status)
        if status == "FAILURE" then
          vim.notify("FAILURE " .. task.name, vim.log.levels.ERROR, {
            title = "Overseer",
            replace = notif_id,
            timeout = false,
          })
        elseif notif_id then
          -- SUCCESS 等: 実行中の通知を消す
          vim.notify("", vim.log.levels.INFO, {
            replace = notif_id,
            timeout = 1,
            hide_from_history = true,
          })
        end
        notif_id = nil
      end,
      on_reset = function(self)
        lines_buf = {}
        notif_id = nil
        started_at = nil
      end,
    }
  end,
}
