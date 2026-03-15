-- Window-scoped buffer tabs displayed in winbar
-- Each window shows its own buffer list as tabs at the top

local M = {}
local api = vim.api
local fn = vim.fn

local skip_ft = {
  NvimTree = true,
  nvdash = true,
  noice = true,
  notify = true,
  qf = true,
  help = true,
  terminal = true,
}

--- Check if a window should be skipped (special windows)
--- @param winid integer
--- @return boolean
local function skip_win(winid)
  if not api.nvim_win_is_valid(winid) then return true end

  local cfg = api.nvim_win_get_config(winid)
  if cfg.relative ~= "" then return true end -- floating window

  local bufnr = api.nvim_win_get_buf(winid)
  local ft = vim.bo[bufnr].filetype
  if skip_ft[ft] then return true end

  local bt = vim.bo[bufnr].buftype
  if bt ~= "" then return true end

  return false
end

--- Extract filename from path
--- @param path string
--- @return string
local function filename(path)
  return path:match("([^/\\]+)[/\\]*$") or ""
end

--- Generate unique name by prepending parent dir when duplicates exist
--- @param name string
--- @param bufnr integer
--- @param bufs integer[]
--- @return string
local function unique_name(name, bufnr, bufs)
  for _, nr in ipairs(bufs) do
    if nr ~= bufnr then
      local other = filename(api.nvim_buf_get_name(nr))
      if other == name then
        return fn.fnamemodify(api.nvim_buf_get_name(bufnr), ":h:t") .. "/" .. name
      end
    end
  end
  return name
end

--- Create highlight-wrapped text
--- @param str string
--- @param hl string
--- @return string
local function hl_text(str, hl)
  return "%#" .. hl .. "#" .. str
end

--- Create a combined highlight from icon fg + tab bg
--- @param fg_group string
--- @param bg_group string
--- @return string highlight format string
local function icon_hl(fg_group, bg_group)
  local combined = fg_group .. "_WinBar_" .. bg_group
  local fg = api.nvim_get_hl(0, { name = fg_group }).fg
  local bg = api.nvim_get_hl(0, { name = bg_group }).bg
  if fg or bg then
    api.nvim_set_hl(0, combined, { fg = fg, bg = bg })
  end
  return "%#" .. combined .. "#"
end

--- Style a single buffer tab
--- @param nr integer buffer number
--- @param bufs integer[] all buffers in this window
--- @param cur integer current buffer number
--- @param max_width integer max width per tab
--- @return string
local function style_buf(nr, bufs, cur, max_width)
  local is_cur = (cur == nr)
  local on_off = is_cur and "On" or "Off"
  local tb_hl = "TbBuf" .. on_off

  -- icon
  local icon_str = "󰈚 "
  local icon_hl_str = icon_hl("DevIconDefault", tb_hl)

  local name = filename(api.nvim_buf_get_name(nr))
  if name == "" then
    name = "No Name"
  else
    name = unique_name(name, nr, bufs)
    local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
    if devicons_ok then
      local devicon, devicon_hl_name = devicons.get_icon(name)
      if devicon then
        icon_str = " " .. devicon .. " "
        icon_hl_str = icon_hl(devicon_hl_name, tb_hl)
      end
    end
  end

  -- truncate name
  local max_name = max_width - 5
  if #name > max_name then
    name = name:sub(1, max_name - 2) .. ".."
  end

  -- padding
  local pad = math.floor((max_width - #name - 5) / 2)
  pad = pad <= 0 and 1 or pad
  local padding = string.rep(" ", pad)

  -- modified / close indicator
  local mod = api.nvim_get_option_value("mod", { buf = nr })
  local close_str
  if is_cur then
    close_str = mod and hl_text("  ", "TbBufOnModified") or hl_text(" 󰅖 ", "TbBufOnClose")
  else
    close_str = mod and hl_text("  ", "TbBufOffModified") or hl_text(" 󰅖 ", "TbBufOffClose")
  end

  -- clickable close button
  close_str = "%" .. nr .. "@WinBarKillBuf@" .. close_str .. "%X"

  -- assemble: clickable name area + close button
  local tab = padding .. icon_hl_str .. icon_str .. hl_text(name, tb_hl) .. padding
  tab = "%" .. nr .. "@WinBarGoToBuf@" .. tab .. "%X"
  tab = hl_text(tab .. close_str, tb_hl)

  return tab
end

--- Render winbar string for a given window
--- @param winid integer
--- @return string
local function render(winid)
  local winbuf = require("custom.winbuf")
  local bufs = winbuf.get_bufs(winid)
  if #bufs == 0 then return "" end

  local cur = api.nvim_win_get_buf(winid)
  local win_width = api.nvim_win_get_width(winid)

  -- Calculate tab width: distribute evenly, capped at 25
  local buf_width = math.min(25, math.floor(win_width / #bufs))
  if buf_width < 10 then buf_width = 10 end

  -- How many tabs fit
  local max_tabs = math.floor(win_width / buf_width)

  -- Ensure current buffer is visible: find its index and window around it
  local cur_idx = 1
  for i, nr in ipairs(bufs) do
    if nr == cur then
      cur_idx = i
      break
    end
  end

  local start_idx = 1
  if #bufs > max_tabs then
    -- Center current buffer in visible range
    start_idx = math.max(1, cur_idx - math.floor(max_tabs / 2))
    if start_idx + max_tabs - 1 > #bufs then
      start_idx = math.max(1, #bufs - max_tabs + 1)
    end
  end

  local end_idx = math.min(#bufs, start_idx + max_tabs - 1)

  local parts = {}
  for i = start_idx, end_idx do
    table.insert(parts, style_buf(bufs[i], bufs, cur, buf_width))
  end

  return table.concat(parts) .. hl_text("%=", "TbFill")
end

--- Update winbar for all normal windows
function M.update_all()
  for _, winid in ipairs(api.nvim_tabpage_list_wins(0)) do
    if api.nvim_win_is_valid(winid) then
      if skip_win(winid) then
        vim.wo[winid].winbar = nil
      else
        vim.wo[winid].winbar = render(winid)
      end
    end
  end
end

--- Setup winbar: register click handlers and autocommands
function M.setup()
  -- VimL click handlers (statusline %@ requires global VimL functions)
  vim.cmd([[
    function! WinBarGoToBuf(bufnr, clicks, btn, modifiers)
      call nvim_win_set_buf(0, a:bufnr)
    endfunction
  ]])

  vim.cmd([[
    function! WinBarKillBuf(bufnr, clicks, btn, modifiers)
      call luaeval('require("custom.winbar").kill_buf(_A)', a:bufnr)
    endfunction
  ]])

  -- Redefine kill_buf as it needs access to winbuf
  M.kill_buf = function(bufnr)
    local winbuf = require("custom.winbuf")
    local winid = api.nvim_get_current_win()
    local bufs = winbuf.get_bufs(winid)

    if #bufs <= 1 then
      -- Last buffer: switch to new empty buffer, then delete
      vim.cmd("enew")
    else
      -- Switch to next buffer before deleting
      local cur = api.nvim_win_get_buf(winid)
      if cur == bufnr then
        winbuf.next()
      end
    end

    -- Delete the buffer
    if api.nvim_buf_is_valid(bufnr) then
      api.nvim_buf_delete(bufnr, { force = false })
    end

    vim.schedule(function()
      M.update_all()
    end)
  end

  -- Autocommands
  local augroup = api.nvim_create_augroup("WinBarBufs", { clear = true })

  api.nvim_create_autocmd({ "BufWinEnter", "BufEnter", "WinEnter" }, {
    group = augroup,
    callback = function()
      vim.schedule(function()
        M.update_all()
      end)
    end,
  })

  api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = augroup,
    callback = function()
      vim.schedule(function()
        M.update_all()
      end)
    end,
  })

  api.nvim_create_autocmd("WinNew", {
    group = augroup,
    callback = function()
      vim.schedule(function()
        M.update_all()
      end)
    end,
  })

  api.nvim_create_autocmd("WinResized", {
    group = augroup,
    callback = function()
      vim.schedule(function()
        M.update_all()
      end)
    end,
  })

  api.nvim_create_autocmd("BufModifiedSet", {
    group = augroup,
    callback = function()
      vim.schedule(function()
        M.update_all()
      end)
    end,
  })
end

return M
