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

    -- monorepo 対応: サブディレクトリのタスクを自動検出
    -- プロジェクト種別の定義テーブル (追加するだけで対応言語を拡張可能)
    local project_types = {
      {
        marker = "package.json",
        ignore = { "node_modules" },
        detect_cmd = function(dir)
          if vim.fn.filereadable(dir .. "/pnpm-lock.yaml") == 1 then return "pnpm"
          elseif vim.fn.filereadable(dir .. "/yarn.lock") == 1 then return "yarn"
          elseif vim.fn.filereadable(dir .. "/bun.lockb") == 1 or vim.fn.filereadable(dir .. "/bun.lock") == 1 then return "bun"
          else return "npm" end
        end,
        parse_tasks = function(content)
          local ok, data = pcall(vim.json.decode, content)
          if ok and data and data.scripts then return vim.tbl_keys(data.scripts) end
          return {}
        end,
        build_cmd = function(cmd, task_name) return { cmd, "run", task_name } end,
      },
      {
        marker = "Makefile",
        parse_tasks = function(content)
          local targets = {}
          for target in content:gmatch("\n([%w_%-]+)%s*:") do
            if not target:match("^%.") then targets[target] = true end
          end
          return vim.tbl_keys(targets)
        end,
        build_cmd = function(_, task_name) return { "make", task_name } end,
      },
      {
        marker = "Cargo.toml",
        parse_tasks = function()
          return { "build", "test", "run", "check", "clippy", "fmt", "bench" }
        end,
        build_cmd = function(_, task_name) return { "cargo", task_name } end,
      },
      {
        marker = "go.mod",
        parse_tasks = function()
          return { "build ./...", "test ./...", "vet ./...", "fmt ./..." }
        end,
        build_cmd = function(_, task_name)
          local parts = {}
          for w in task_name:gmatch("%S+") do table.insert(parts, w) end
          local cmd = { "go" }
          for _, p in ipairs(parts) do table.insert(cmd, p) end
          return cmd
        end,
      },
      {
        marker = "pyproject.toml",
        parse_tasks = function(content)
          -- [project.scripts] セクションからスクリプト名を抽出
          local tasks = {}
          local in_scripts = false
          for line in content:gmatch("[^\n]+") do
            if line:match("^%[project%.scripts%]") then
              in_scripts = true
            elseif line:match("^%[") then
              in_scripts = false
            elseif in_scripts then
              local name = line:match("^([%w_%-]+)%s*=")
              if name then table.insert(tasks, name) end
            end
          end
          -- 基本タスクは常に提供
          if vim.tbl_isempty(tasks) then
            return { "test", "lint", "typecheck" }
          end
          return tasks
        end,
        detect_cmd = function(dir)
          if vim.fn.filereadable(dir .. "/poetry.lock") == 1 then return "poetry"
          elseif vim.fn.filereadable(dir .. "/uv.lock") == 1 then return "uv"
          else return "python" end
        end,
        build_cmd = function(cmd, task_name)
          if cmd == "poetry" then return { "poetry", "run", task_name }
          elseif cmd == "uv" then return { "uv", "run", task_name }
          else return { "python", "-m", task_name } end
        end,
      },
    }

    -- 除外パターン (全プロジェクト共通)
    local global_ignore = { "node_modules", "%.git/", "target/", "dist/", "__pycache__", "%.venv", "vendor/" }

    local function should_ignore(path, extra_ignore)
      for _, pat in ipairs(global_ignore) do
        if path:match(pat) then return true end
      end
      if extra_ignore then
        for _, pat in ipairs(extra_ignore) do
          if path:match(pat) then return true end
        end
      end
      return false
    end

    overseer.register_template({
      name = "monorepo",
      priority = 40,
      params = {},
      generator = function(opts, cb)
        local root = opts.dir
        local tasks = {}

        for _, ptype in ipairs(project_types) do
          local marker_files = vim.fn.globpath(root, "**/" .. ptype.marker, false, true)
          -- ルート直下のマーカーも含める
          local root_marker = root .. "/" .. ptype.marker
          if vim.fn.filereadable(root_marker) == 1 then
            table.insert(marker_files, root_marker)
          end

          -- 重複排除
          local seen = {}
          for _, fpath in ipairs(marker_files) do
            local canonical = vim.fn.resolve(fpath)
            if not seen[canonical] and not should_ignore(fpath, ptype.ignore) then
              seen[canonical] = true
              local ok, lines = pcall(vim.fn.readfile, fpath)
              if ok then
                local content = table.concat(lines, "\n")
                local pkg_dir = vim.fn.fnamemodify(fpath, ":h")
                local rel_dir = vim.fn.fnamemodify(pkg_dir, ":.")
                if rel_dir == "." then rel_dir = "(root)" end

                local cmd_name = ptype.detect_cmd and ptype.detect_cmd(pkg_dir) or ptype.marker:gsub("%..*$", "")
                local task_names = ptype.parse_tasks(content)

                for _, task_name in ipairs(task_names) do
                  local built_cmd = ptype.build_cmd(cmd_name, task_name)
                  table.insert(tasks, {
                    name = string.format("%s %s [%s]", built_cmd[1], task_name, rel_dir),
                    builder = function()
                      return {
                        cmd = built_cmd,
                        cwd = pkg_dir,
                        components = { "default" },
                      }
                    end,
                  })
                end
              end
            end
          end
        end

        cb(tasks)
      end,
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
