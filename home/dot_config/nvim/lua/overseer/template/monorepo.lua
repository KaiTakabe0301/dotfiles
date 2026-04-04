local files = require("overseer.files")
local overseer = require("overseer")

-- Directories to exclude when searching for config files
local exclude_dirs = {
  ["node_modules"] = true,
  [".git"] = true,
  ["dist"] = true,
  ["build"] = true,
  ["target"] = true,
  [".next"] = true,
  [".nuxt"] = true,
  ["vendor"] = true,
  ["__pycache__"] = true,
}

--- Detect the project root via .git directory
---@return string|nil
local function get_project_root()
  local root = vim.fs.find(".git", { upward = true, type = "directory", path = vim.fn.getcwd() })[1]
  if root then
    return vim.fs.dirname(root)
  end
  return nil
end

-- Build a filename lookup table: lowercase filename -> list of handler keys
-- and a separate exact-match table for case-sensitive names.
-- justfile is matched case-insensitively; all others are exact.
---@type table<string, string[]>  filename -> handler keys (exact match)
local filename_to_handlers = {}
---@type table<string, string[]>  lowercase filename -> handler keys (case-insensitive, justfile only)
local filename_to_handlers_ci = {}

--- Register a filename -> handler_key mapping (called during handler table setup below)
---@param handler_key string
---@param filenames string[]
local function register_filenames(handler_key, filenames)
  for _, f in ipairs(filenames) do
    if f:lower() == "justfile" or f:lower() == ".justfile" then
      local lower = f:lower()
      if not filename_to_handlers_ci[lower] then
        filename_to_handlers_ci[lower] = {}
      end
      table.insert(filename_to_handlers_ci[lower], handler_key)
    else
      if not filename_to_handlers[f] then
        filename_to_handlers[f] = {}
      end
      table.insert(filename_to_handlers[f], handler_key)
    end
  end
end

--- Single recursive scan of the project tree.
--- Returns a table: handler_key -> list of filepaths
---@param root string
---@return table<string, string[]>
local function scan_project(root)
  local result = {}
  local function scan(dir)
    local handle = vim.uv.fs_scandir(dir)
    if not handle then
      return
    end
    while true do
      local name, ftype = vim.uv.fs_scandir_next(handle)
      if not name then
        break
      end
      if ftype == "directory" and not exclude_dirs[name] then
        scan(vim.fs.joinpath(dir, name))
      elseif ftype == "file" then
        -- Exact match
        local keys = filename_to_handlers[name]
        if keys then
          local fullpath = vim.fs.joinpath(dir, name)
          -- Skip files at project root (covered by built-in providers)
          if dir ~= root then
            for _, key in ipairs(keys) do
              if not result[key] then
                result[key] = {}
              end
              table.insert(result[key], fullpath)
            end
          end
        end
        -- Case-insensitive match (justfile)
        local lower = name:lower()
        local ci_keys = filename_to_handlers_ci[lower]
        if ci_keys then
          local fullpath = vim.fs.joinpath(dir, name)
          if dir ~= root then
            for _, key in ipairs(ci_keys) do
              if not result[key] then
                result[key] = {}
              end
              table.insert(result[key], fullpath)
            end
          end
        end
      end
    end
  end
  scan(root)
  return result
end

--- Detect package manager from lockfiles (cached per root)
---@type table<string, string>
local npm_manager_cache = {}

---@param root string
---@return string
local function detect_npm_manager(root)
  if npm_manager_cache[root] then
    return npm_manager_cache[root]
  end
  local lockfiles = {
    { file = "pnpm-lock.yaml", mgr = "pnpm" },
    { file = "yarn.lock", mgr = "yarn" },
    { file = "bun.lockb", mgr = "bun" },
    { file = "bun.lock", mgr = "bun" },
    { file = "package-lock.json", mgr = "npm" },
  }
  for _, entry in ipairs(lockfiles) do
    if vim.uv.fs_stat(vim.fs.joinpath(root, entry.file)) then
      npm_manager_cache[root] = entry.mgr
      return entry.mgr
    end
  end
  npm_manager_cache[root] = "npm"
  return "npm"
end

--- Cached vim.fn.executable check
---@type table<string, boolean>
local executable_cache = {}

---@param cmd string
---@return boolean
local function is_executable(cmd)
  if executable_cache[cmd] == nil then
    executable_cache[cmd] = vim.fn.executable(cmd) == 1
  end
  return executable_cache[cmd]
end

--- Get relative path from root
---@param root string
---@param path string
---@return string
local function relative_path(root, path)
  local rel = path:sub(#root + 2) -- +2 for trailing /
  return rel
end

-- Handler definitions for each tool type
-- Each handler has: config_files, process(root, filepath, tasks, cb_done)
-- cb_done() must be called exactly once when processing is complete.
-- For sync handlers, cb_done is called inline. For async, after command finishes.

---@alias HandlerProcessFn fun(root: string, filepath: string, tasks: table[], cb_done: fun())

---@class ToolHandler
---@field config_files string[]
---@field process HandlerProcessFn

---@type table<string, ToolHandler>
local handlers = {}

-- npm / pnpm / yarn / bun
handlers.npm = {
  config_files = { "package.json" },
  process = function(root, filepath, tasks, cb_done)
    local data = files.load_json_file(filepath)
    if not data or not data.scripts then
      cb_done()
      return
    end
    local dir = vim.fs.dirname(filepath)
    local rel = relative_path(root, dir)
    local mgr = detect_npm_manager(root)
    for k in pairs(data.scripts) do
      table.insert(tasks, {
        name = string.format("[%s] %s run %s", rel, mgr, k),
        builder = function()
          return {
            cmd = { mgr, "run", k },
            cwd = dir,
          }
        end,
      })
    end
    cb_done()
  end,
}

-- deno
handlers.deno = {
  config_files = { "deno.json", "deno.jsonc" },
  process = function(root, filepath, tasks, cb_done)
    local data = files.load_json_file(filepath)
    if not data or not data.tasks or vim.tbl_isempty(data.tasks) then
      cb_done()
      return
    end
    local dir = vim.fs.dirname(filepath)
    local rel = relative_path(root, dir)
    for k in pairs(data.tasks) do
      table.insert(tasks, {
        name = string.format("[%s] deno task %s", rel, k),
        builder = function()
          return {
            cmd = { "deno", "task", k },
            cwd = dir,
          }
        end,
      })
    end
    cb_done()
  end,
}

-- composer
handlers.composer = {
  config_files = { "composer.json" },
  process = function(root, filepath, tasks, cb_done)
    local data = files.load_json_file(filepath)
    if not data or not data.scripts or vim.tbl_isempty(data.scripts) then
      cb_done()
      return
    end
    local dir = vim.fs.dirname(filepath)
    local rel = relative_path(root, dir)
    for k in pairs(data.scripts) do
      table.insert(tasks, {
        name = string.format("[%s] composer run %s", rel, k),
        builder = function()
          return {
            cmd = { "composer", "run-script", k },
            cwd = dir,
          }
        end,
      })
    end
    cb_done()
  end,
}

-- make
handlers.make = {
  config_files = { "Makefile" },
  process = function(root, filepath, tasks, cb_done)
    if not is_executable("make") then
      cb_done()
      return
    end
    local dir = vim.fs.dirname(filepath)
    local rel = relative_path(root, dir)
    overseer.builtin.system(
      { "make", "-rRpq" },
      { cwd = dir, text = true, env = { ["LANG"] = "C.UTF-8" } },
      vim.schedule_wrap(function(out)
        if out.code ~= 0 and out.code ~= 1 then
          cb_done()
          return
        end
        local parsing = false
        local prev_line = ""
        for line in vim.gsplit(out.stdout or "", "\n") do
          if line:find("# Files") == 1 then
            parsing = true
          elseif line:find("# Finished Make") == 1 then
            break
          elseif parsing then
            if line:match("^[^%.#%s]") and prev_line:find("# Not a target") ~= 1 then
              local idx = line:find(":")
              if idx then
                local target = line:sub(1, idx - 1)
                table.insert(tasks, {
                  name = string.format("[%s] make %s", rel, target),
                  builder = function()
                    return {
                      cmd = { "make", target },
                      cwd = dir,
                    }
                  end,
                })
              end
            end
          end
          prev_line = line
        end
        cb_done()
      end)
    )
  end,
}

-- just
handlers.just = {
  config_files = { "justfile", "Justfile", ".justfile" },
  process = function(root, filepath, tasks, cb_done)
    if not is_executable("just") then
      cb_done()
      return
    end
    local dir = vim.fs.dirname(filepath)
    local rel = relative_path(root, dir)
    overseer.builtin.system(
      { "just", "--summary" },
      { cwd = dir, text = true },
      vim.schedule_wrap(function(out)
        if out.code ~= 0 then
          cb_done()
          return
        end
        for recipe in vim.gsplit(vim.trim(out.stdout or ""), "%s+") do
          if recipe ~= "" then
            table.insert(tasks, {
              name = string.format("[%s] just %s", rel, recipe),
              builder = function()
                return {
                  cmd = { "just", recipe },
                  cwd = dir,
                }
              end,
            })
          end
        end
        cb_done()
      end)
    )
  end,
}

-- task (Taskfile)
handlers.task = {
  config_files = { "Taskfile.yml", "Taskfile.yaml", "Taskfile.dist.yml", "Taskfile.dist.yaml" },
  process = function(root, filepath, tasks, cb_done)
    if not is_executable("task") then
      cb_done()
      return
    end
    local dir = vim.fs.dirname(filepath)
    local rel = relative_path(root, dir)
    overseer.builtin.system(
      { "task", "--list-all", "--json" },
      { cwd = dir, text = true },
      vim.schedule_wrap(function(out)
        if out.code ~= 0 then
          cb_done()
          return
        end
        local ok, data = pcall(vim.json.decode, out.stdout, { luanil = { object = true } })
        if ok and data and data.tasks then
          for _, target in ipairs(data.tasks) do
            table.insert(tasks, {
              name = string.format("[%s] task %s", rel, target.name),
              desc = target.desc,
              builder = function()
                return {
                  cmd = { "task", target.name },
                  cwd = dir,
                }
              end,
            })
          end
        end
        cb_done()
      end)
    )
  end,
}

-- mix
handlers.mix = {
  config_files = { "mix.exs" },
  process = function(root, filepath, tasks, cb_done)
    if not is_executable("mix") then
      cb_done()
      return
    end
    local dir = vim.fs.dirname(filepath)
    local rel = relative_path(root, dir)
    local mix_commands = { "compile", "test", "format", "deps.get", "clean", "ecto.migrate" }
    for _, cmd in ipairs(mix_commands) do
      table.insert(tasks, {
        name = string.format("[%s] mix %s", rel, cmd),
        builder = function()
          return {
            cmd = { "mix", cmd },
            cwd = dir,
          }
        end,
      })
    end
    cb_done()
  end,
}

-- rake
handlers.rake = {
  config_files = { "Rakefile" },
  process = function(root, filepath, tasks, cb_done)
    if not is_executable("rake") then
      cb_done()
      return
    end
    local dir = vim.fs.dirname(filepath)
    local rel = relative_path(root, dir)
    overseer.builtin.system(
      { "rake", "-T" },
      { cwd = dir, text = true },
      vim.schedule_wrap(function(out)
        if out.code ~= 0 then
          cb_done()
          return
        end
        for line in vim.gsplit(out.stdout or "", "\n") do
          if line ~= "" then
            local task_name = line:match("^rake (%S+)")
            if task_name then
              table.insert(tasks, {
                name = string.format("[%s] rake %s", rel, task_name),
                builder = function()
                  return {
                    cmd = { "rake", task_name },
                    cwd = dir,
                  }
                end,
              })
            end
          end
        end
        cb_done()
      end)
    )
  end,
}

-- cargo-make
handlers["cargo-make"] = {
  config_files = { "Makefile.toml" },
  process = function(root, filepath, tasks, cb_done)
    local data = files.read_file(filepath)
    if not data then
      cb_done()
      return
    end
    local dir = vim.fs.dirname(filepath)
    local rel = relative_path(root, dir)
    for task_name in data:gmatch("%[tasks%.(.-)%]") do
      table.insert(tasks, {
        name = string.format("[%s] cargo make %s", rel, task_name),
        builder = function()
          return {
            cmd = { "cargo-make", "make", task_name },
            cwd = dir,
          }
        end,
      })
    end
    cb_done()
  end,
}

-- mise
handlers.mise = {
  config_files = { "mise.toml", ".mise.toml" },
  process = function(root, filepath, tasks, cb_done)
    if not is_executable("mise") then
      cb_done()
      return
    end
    local dir = vim.fs.dirname(filepath)
    local rel = relative_path(root, dir)
    overseer.builtin.system(
      { "mise", "tasks", "--json" },
      { cwd = dir, text = true },
      vim.schedule_wrap(function(out)
        local ok, data = pcall(vim.json.decode, out.stdout or "", { luanil = { object = true } })
        if ok and data then
          for _, value in pairs(data) do
            table.insert(tasks, {
              name = string.format("[%s] mise run %s", rel, value.name),
              desc = value.description ~= "" and value.description or nil,
              builder = function()
                return {
                  cmd = { "mise", "run", value.name },
                  cwd = dir,
                }
              end,
            })
          end
        end
        cb_done()
      end)
    )
  end,
}

-- tox
handlers.tox = {
  config_files = { "tox.ini" },
  process = function(root, filepath, tasks, cb_done)
    local content = files.read_file(filepath)
    if not content then
      cb_done()
      return
    end
    local dir = vim.fs.dirname(filepath)
    local rel = relative_path(root, dir)
    local targets = {}
    for line in vim.gsplit(content, "\n") do
      local envlist = line:match("^envlist%s*=%s*(.+)$")
      if envlist then
        for t in vim.gsplit(envlist, "%s*,%s*") do
          if t:match("^[a-zA-Z0-9_%-]+$") then
            targets[t] = true
          end
        end
      end
      local name = line:match("^%[testenv:([a-zA-Z0-9_%-]+)%]")
      if name then
        targets[name] = true
      end
    end
    for k in pairs(targets) do
      table.insert(tasks, {
        name = string.format("[%s] tox -e %s", rel, k),
        builder = function()
          return {
            cmd = { "tox", "-e", k },
            cwd = dir,
          }
        end,
      })
    end
    cb_done()
  end,
}

-- mage
handlers.mage = {
  config_files = { "magefile.go" },
  process = function(root, filepath, tasks, cb_done)
    if not is_executable("mage") then
      cb_done()
      return
    end
    local dir = vim.fs.dirname(filepath)
    local rel = relative_path(root, dir)
    overseer.builtin.system(
      { "mage", "-l" },
      { cwd = dir, text = true, env = { MAGEFILE_ENABLE_COLOR = "false" } },
      vim.schedule_wrap(function(out)
        if out.code ~= 0 then
          cb_done()
          return
        end
        for line in vim.gsplit(out.stdout or "", "\n") do
          if line ~= "" then
            local task_name = line:match("^  ([%w:]+)")
            if task_name then
              table.insert(tasks, {
                name = string.format("[%s] mage %s", rel, task_name),
                builder = function()
                  return {
                    cmd = { "mage", task_name },
                    cwd = dir,
                  }
                end,
              })
            end
          end
        end
        cb_done()
      end)
    )
  end,
}

-- devenv
handlers.devenv = {
  config_files = { "devenv.nix" },
  process = function(root, filepath, tasks, cb_done)
    if not is_executable("devenv") then
      cb_done()
      return
    end
    local dir = vim.fs.dirname(filepath)
    local rel = relative_path(root, dir)
    local devenv_commands = { "shell", "up", "test", "build", "gc" }
    for _, cmd in ipairs(devenv_commands) do
      table.insert(tasks, {
        name = string.format("[%s] devenv %s", rel, cmd),
        builder = function()
          return {
            cmd = { "devenv", cmd },
            cwd = dir,
          }
        end,
      })
    end
    cb_done()
  end,
}

-- cargo
handlers.cargo = {
  config_files = { "Cargo.toml" },
  process = function(root, filepath, tasks, cb_done)
    if not is_executable("cargo") then
      cb_done()
      return
    end
    local dir = vim.fs.dirname(filepath)
    local rel = relative_path(root, dir)
    local cargo_commands = { "build", "run", "test", "check", "clean", "clippy", "fmt", "doc", "bench" }
    for _, cmd in ipairs(cargo_commands) do
      table.insert(tasks, {
        name = string.format("[%s] cargo %s", rel, cmd),
        builder = function()
          return {
            cmd = { "cargo", cmd },
            cwd = dir,
          }
        end,
      })
    end
    cb_done()
  end,
}

-- Register all handler filenames for the lookup table
for key, handler in pairs(handlers) do
  register_filenames(key, handler.config_files)
end

---@type overseer.TemplateFileProvider
return {
  cache_key = function()
    return get_project_root()
  end,
  generator = function(_, cb)
    local root = get_project_root()
    if not root then
      return "Not in a git repository"
    end

    -- Single scan of the entire project tree
    local files_by_handler = scan_project(root)

    -- Collect work items from scan results
    ---@type { handler: ToolHandler, filepath: string }[]
    local work_items = {}
    for key, filepaths in pairs(files_by_handler) do
      local handler = handlers[key]
      if handler then
        for _, filepath in ipairs(filepaths) do
          table.insert(work_items, { handler = handler, filepath = filepath })
        end
      end
    end

    if #work_items == 0 then
      return {}
    end

    local ret = {}
    local remaining = #work_items

    local function on_done()
      remaining = remaining - 1
      if remaining == 0 then
        cb(ret)
      end
    end

    for _, item in ipairs(work_items) do
      item.handler.process(root, item.filepath, ret, on_done)
    end
  end,
}
