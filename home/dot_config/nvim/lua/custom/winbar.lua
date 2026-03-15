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

--- Setup separator highlight groups based on current theme
local function setup_sep_highlights()
  local buf_on_bg = api.nvim_get_hl(0, { name = "TbBufOn" }).bg
  local buf_off_bg = api.nvim_get_hl(0, { name = "TbBufOff" }).bg
  local fill_bg = api.nvim_get_hl(0, { name = "TbFill" }).bg

  -- Separators between tab states
  api.nvim_set_hl(0, "WinBarSepOnToFill", { fg = buf_on_bg, bg = fill_bg })
  api.nvim_set_hl(0, "WinBarSepFillToOn", { fg = buf_on_bg, bg = fill_bg })
  api.nvim_set_hl(0, "WinBarSepOnToOff", { fg = buf_on_bg, bg = buf_off_bg })
  api.nvim_set_hl(0, "WinBarSepOffToOn", { fg = buf_on_bg, bg = buf_off_bg })
  api.nvim_set_hl(0, "WinBarSepOffToFill", { fg = buf_off_bg, bg = fill_bg })
  api.nvim_set_hl(0, "WinBarSepFillToOff", { fg = buf_off_bg, bg = fill_bg })
end

--- Get icon and highlight for a buffer
--- @param name string
--- @param tb_hl string
--- @return string icon_str, string icon_hl_str
local function get_icon(name, tb_hl)
  local icon_str = "󰈚 "
  local icon_hl_str = icon_hl("DevIconDefault", tb_hl)

  if name ~= "" and name ~= "No Name" then
    local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
    if devicons_ok then
      local devicon, devicon_hl_name = devicons.get_icon(name)
      if devicon then
        icon_str = devicon .. " "
        icon_hl_str = icon_hl(devicon_hl_name, tb_hl)
      end
    end
  end

  return icon_str, icon_hl_str
end

--- Style a single buffer tab with variable width
--- @param nr integer buffer number
--- @param bufs integer[] all buffers in this window
--- @param cur integer current buffer number
--- @return string content, boolean is_active, integer display_width
local function style_buf(nr, bufs, cur)
  local is_cur = (cur == nr)
  local on_off = is_cur and "On" or "Off"
  local tb_hl = "TbBuf" .. on_off

  local name = filename(api.nvim_buf_get_name(nr))
  if name == "" then
    name = "No Name"
  else
    name = unique_name(name, nr, bufs)
  end

  local icon_str, icon_hl_str = get_icon(name, tb_hl)

  -- modified / close indicator
  local mod = api.nvim_get_option_value("mod", { buf = nr })
  local close_str
  if is_cur then
    close_str = mod and hl_text("  ", "TbBufOnModified") or hl_text(" 󰅖 ", "TbBufOnClose")
  else
    close_str = mod and hl_text("  ", "TbBufOffModified") or hl_text(" 󰅖 ", "TbBufOffClose")
  end
  close_str = "%" .. nr .. "@WinBarKillBuf@" .. close_str .. "%X"

  -- Calculate display width: icon(2+space) + name + close(3) + padding(2)
  -- icon_str is e.g. " " (icon + space) = ~2 display cols
  local display_width = 2 + #name + 3 + 2
  display_width = math.max(10, math.min(30, display_width))

  -- Truncate name if needed
  local max_name = display_width - 7 -- 2(icon) + 3(close) + 2(padding)
  if #name > max_name then
    name = name:sub(1, max_name - 2) .. ".."
  end

  -- Assemble tab content: space + icon + name + close + space
  local tab = " " .. icon_hl_str .. icon_str .. hl_text(name, tb_hl)
  tab = "%" .. nr .. "@WinBarGoToBuf@" .. tab .. "%X"
  tab = hl_text(tab .. close_str .. hl_text(" ", tb_hl), tb_hl)

  return tab, is_cur, display_width
end

--- Render simple single-buffer winbar (icon + filename only)
--- @param winid integer
--- @return string
local function render_single(winid)
  local winbuf = require("custom.winbuf")
  local bufs = winbuf.get_bufs(winid)
  if #bufs == 0 then return "" end

  local nr = bufs[1]
  local name = filename(api.nvim_buf_get_name(nr))
  if name == "" then name = "No Name" end

  local icon_str, icon_hl_str = get_icon(name, "TbFill")

  local mod = api.nvim_get_option_value("mod", { buf = nr })
  local mod_indicator = mod and hl_text(" ● ", "TbBufOnModified") or ""

  return hl_text(" ", "TbFill") .. icon_hl_str .. icon_str .. hl_text(name, "TbFill") .. mod_indicator .. hl_text("%=", "TbFill")
end

--- Get separator string between two states
--- @param left_on boolean|nil  left tab is active (nil = fill)
--- @param right_on boolean|nil right tab is active (nil = fill)
--- @return string
local function get_separator(left_on, right_on)
  -- left_on/right_on: true=On, false=Off, nil=Fill
  local left_name = left_on == true and "On" or (left_on == false and "Off" or "Fill")
  local right_name = right_on == true and "On" or (right_on == false and "Off" or "Fill")

  if left_name == right_name then
    -- Same state, use thin separator
    local hl_name = "TbBuf" .. (left_name == "Fill" and "Off" or left_name)
    return hl_text("│", hl_name)
  end

  -- Use powerline separator: left block ends, right block begins
  local sep_hl = "WinBarSep" .. left_name .. "To" .. right_name
  return hl_text("", sep_hl)
end

--- Render winbar string for a given window
--- @param winid integer
--- @return string
local function render(winid)
  local winbuf = require("custom.winbuf")
  local bufs = winbuf.get_bufs(winid)
  if #bufs == 0 then return "" end

  -- Single buffer: simple display
  if #bufs == 1 then
    return render_single(winid)
  end

  local cur = api.nvim_win_get_buf(winid)
  local win_width = api.nvim_win_get_width(winid)

  -- Build tab info with variable widths
  local tab_info = {} -- { content, is_active, width }
  local total_width = 0
  for _, nr in ipairs(bufs) do
    local content, is_active, width = style_buf(nr, bufs, cur)
    table.insert(tab_info, { content = content, is_active = is_active, width = width })
    total_width = total_width + width
  end

  -- Determine visible range (ensure current buffer is visible)
  local cur_idx = 1
  for i, info in ipairs(tab_info) do
    if info.is_active then
      cur_idx = i
      break
    end
  end

  -- Calculate which tabs fit, expanding from current buffer
  local start_idx, end_idx = cur_idx, cur_idx
  local used_width = tab_info[cur_idx].width + 2 -- +2 for edge separators

  -- Expand left and right alternately
  while true do
    local expanded = false
    -- Try right
    if end_idx < #tab_info then
      local w = tab_info[end_idx + 1].width + 1 -- +1 for separator
      if used_width + w <= win_width then
        end_idx = end_idx + 1
        used_width = used_width + w
        expanded = true
      end
    end
    -- Try left
    if start_idx > 1 then
      local w = tab_info[start_idx - 1].width + 1
      if used_width + w <= win_width then
        start_idx = start_idx - 1
        used_width = used_width + w
        expanded = true
      end
    end
    if not expanded then break end
  end

  -- Build output with separators
  local parts = {}

  -- Leading separator: Fill → first tab
  local first_on = tab_info[start_idx].is_active
  table.insert(parts, get_separator(nil, first_on))

  for i = start_idx, end_idx do
    table.insert(parts, tab_info[i].content)

    if i < end_idx then
      -- Separator between tabs
      local left_on = tab_info[i].is_active
      local right_on = tab_info[i + 1].is_active
      table.insert(parts, get_separator(left_on, right_on))
    end
  end

  -- Trailing separator: last tab → Fill
  local last_on = tab_info[end_idx].is_active
  table.insert(parts, get_separator(last_on, nil))

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
  -- Setup separator highlights
  setup_sep_highlights()

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

  -- Re-setup highlights on colorscheme change
  api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = function()
      setup_sep_highlights()
      vim.schedule(function()
        M.update_all()
      end)
    end,
  })
end

return M
