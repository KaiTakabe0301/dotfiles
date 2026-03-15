-- Window-scoped buffer management
-- Each window maintains its own buffer list for scoped bnext/bprev navigation

local M = {}

--- @type table<integer, integer[]>  winid → {bufnr, ...}
local _win_bufs = {}

-- Filetypes to skip when registering buffers
local skip_ft = {
  NvimTree = true,
  nvdash = true,
  noice = true,
  notify = true,
  qf = true,
  help = true,
  terminal = true,
}

--- Find index of value in list
--- @param list integer[]
--- @param val integer
--- @return integer|nil
local function find_index(list, val)
  for i, v in ipairs(list) do
    if v == val then return i end
  end
  return nil
end

--- Register a buffer to a window's list
--- @param winid integer
--- @param bufnr integer
function M.register(winid, bufnr)
  if not _win_bufs[winid] then
    _win_bufs[winid] = {}
  end
  -- Avoid duplicates
  if not find_index(_win_bufs[winid], bufnr) then
    table.insert(_win_bufs[winid], bufnr)
  end
end

--- Unregister a buffer from a window's list
--- @param winid integer
--- @param bufnr integer
function M.unregister(winid, bufnr)
  local bufs = _win_bufs[winid]
  if not bufs then return end
  local idx = find_index(bufs, bufnr)
  if idx then
    table.remove(bufs, idx)
  end
end

--- Get valid, buflisted buffers for a window
--- @param winid integer
--- @return integer[]
function M.get_bufs(winid)
  local bufs = _win_bufs[winid] or {}
  local result = {}
  for _, bufnr in ipairs(bufs) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
      table.insert(result, bufnr)
    end
  end
  -- Update stored list to remove stale entries
  _win_bufs[winid] = result
  return result
end

--- Switch to next buffer in window scope
function M.next()
  local winid = vim.api.nvim_get_current_win()
  local bufs = M.get_bufs(winid)
  if #bufs <= 1 then return end
  local cur = vim.api.nvim_get_current_buf()
  local idx = find_index(bufs, cur) or 1
  local next_idx = (idx % #bufs) + 1
  vim.api.nvim_win_set_buf(winid, bufs[next_idx])
end

--- Switch to previous buffer in window scope
function M.prev()
  local winid = vim.api.nvim_get_current_win()
  local bufs = M.get_bufs(winid)
  if #bufs <= 1 then return end
  local cur = vim.api.nvim_get_current_buf()
  local idx = find_index(bufs, cur) or 1
  local prev_idx = ((idx - 2) % #bufs) + 1
  vim.api.nvim_win_set_buf(winid, bufs[prev_idx])
end

--- Move current buffer right (later) in the window's list
function M.move_right()
  local winid = vim.api.nvim_get_current_win()
  local bufs = M.get_bufs(winid)
  if #bufs <= 1 then return end
  local cur = vim.api.nvim_get_current_buf()
  local idx = find_index(bufs, cur)
  if not idx or idx >= #bufs then return end
  bufs[idx], bufs[idx + 1] = bufs[idx + 1], bufs[idx]
end

--- Move current buffer left (earlier) in the window's list
function M.move_left()
  local winid = vim.api.nvim_get_current_win()
  local bufs = M.get_bufs(winid)
  if #bufs <= 1 then return end
  local cur = vim.api.nvim_get_current_buf()
  local idx = find_index(bufs, cur)
  if not idx or idx <= 1 then return end
  bufs[idx], bufs[idx - 1] = bufs[idx - 1], bufs[idx]
end

--- Setup autocommands for window-scoped buffer tracking
function M.setup()
  local augroup = vim.api.nvim_create_augroup("WinScopedBufs", { clear = true })

  -- Register buffer when it enters a window
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = augroup,
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      local winid = vim.api.nvim_get_current_win()

      -- Skip non-listed buffers
      if not vim.bo[bufnr].buflisted then return end

      -- Skip special filetypes
      local ft = vim.bo[bufnr].filetype
      if skip_ft[ft] then return end

      -- Skip special buffer types (terminal, prompt, etc.)
      local bt = vim.bo[bufnr].buftype
      if bt ~= "" then return end

      -- Skip floating windows
      local win_config = vim.api.nvim_win_get_config(winid)
      if win_config.relative ~= "" then return end

      M.register(winid, bufnr)
    end,
  })

  -- Clean up when a window is closed
  vim.api.nvim_create_autocmd("WinClosed", {
    group = augroup,
    callback = function(args)
      local winid = tonumber(args.match)
      if winid then
        _win_bufs[winid] = nil
      end
    end,
  })

  -- Remove deleted buffers from all windows
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = augroup,
    callback = function(args)
      local bufnr = args.buf
      for winid, _ in pairs(_win_bufs) do
        M.unregister(winid, bufnr)
      end
    end,
  })
end

return M
