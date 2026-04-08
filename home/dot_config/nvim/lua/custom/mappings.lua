-- NvChad v2.5の正しい形式で設定

local map = vim.keymap.set
local nomap = vim.keymap.del

-- 既存のカスタムマッピング
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jj", "<ESC>")

-- 1. デフォルトの <leader>b (新規バッファ作成) を無効化
-- NvChadのデフォルトマッピングを即座に上書き（遅延削除だとタイミング問題が発生するため）
map("n", "<leader>b", "<Nop>", { desc = "Buffers prefix" })

-- 2. スマートなバッファ削除関数（ウィンドウスコープ対応）
local function smart_buffer_delete()
  local winbuf = require("custom.winbuf")
  local bufnr = vim.api.nvim_get_current_buf()
  local winid = vim.api.nvim_get_current_win()

  -- Pinned buffers cannot be deleted
  if winbuf.is_pinned(winid, bufnr) then return end

  local bufs = winbuf.get_bufs(winid)

  -- ウィンドウスコープ内のバッファが1つ以下の場合
  if #bufs <= 1 then
    -- nvim-treeが開いているか確認
    local nvim_tree_open = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      if ft == 'NvimTree' then
        nvim_tree_open = true
        vim.api.nvim_set_current_win(win)
        break
      end
    end

    -- nvim-treeが開いていない場合は開く
    if not nvim_tree_open then
      vim.cmd('NvimTreeOpen')
    end

    -- 元のバッファを削除
    vim.cmd('bdelete! ' .. bufnr)
  else
    -- スコープ内の次バッファに切替後、削除
    winbuf.next()
    vim.cmd('bdelete! ' .. bufnr)
  end
end

-- Pin toggle
map("n", "<leader>bi", function()
  local winbuf = require("custom.winbuf")
  local winid = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  winbuf.toggle_pin(winid, bufnr)
  require("custom.winbar").update_all()
end, { desc = "Toggle pin buffer" })

-- 3. バッファ関連のマッピングを追加
map("n", "<leader>bb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
map("n", "<leader>bd", smart_buffer_delete, { desc = "Delete buffer (smart)" })
map("n", "<leader>bn", function() require("custom.winbuf").next() end, { desc = "Next buffer (window-scoped)" })
map("n", "<leader>bp", function() require("custom.winbuf").prev() end, { desc = "Previous buffer (window-scoped)" })
map("n", "<leader>bc", "<cmd>enew<cr>", { desc = "Create new buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Force delete buffer" })
map("n", "<leader>bo", function() require("custom.winbar").kill_other_bufs() end, { desc = "Close other buffers (keep pinned)" })
map("n", "<leader>bl", function()
  require("custom.winbuf").move_right()
  require("custom.winbar").update_all()
end, { desc = "Move buffer right" })
map("n", "<leader>bh", function()
  require("custom.winbuf").move_left()
  require("custom.winbar").update_all()
end, { desc = "Move buffer left" })

-- 4. デフォルトのwhich-keyマッピングを無効化（即座に上書き）
map("n", "<leader>wK", "<Nop>", { desc = "" })
map("n", "<leader>wk", "<Nop>", { desc = "" })
map("n", "<leader>wa", "<Nop>", { desc = "" })
map("n", "<leader>wr", "<Nop>", { desc = "" })
map("n", "<leader>wl", "<Nop>", { desc = "" })

-- 5. which-key関連を<leader>Wに移動
map("n", "<leader>WK", "<cmd>WhichKey <CR>", { desc = "All keymaps" })
map("n", "<leader>Wk", function()
  vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
end, { desc = "Query lookup" })

-- 6. LSP関連を<leader>Lに設定（ワークスペース関連）
map("n", "<leader>La", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder" })
map("n", "<leader>Lr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder" })
map("n", "<leader>Ll", function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, { desc = "List workspace folders" })

-- Telescope: ファイルタイプで絞り込み検索
map("n", "<leader>ft", function()
  vim.ui.input({ prompt = "File extension: " }, function(ext)
    if not ext or ext == "" then return end
    local globs = {}
    for e in ext:gmatch("[^,]+") do
      table.insert(globs, "--glob")
      table.insert(globs, "*." .. e:match("^%s*(.-)%s*$"))
    end
    require("telescope.builtin").find_files({
      find_command = vim.list_extend({ "rg", "--files" }, globs),
    })
  end)
end, { desc = "Find files by extension" })

-- Plugin Keybindings ヘルプ用ハイライトグループ（NVChad風）
vim.api.nvim_set_hl(0, "HelpCatRed", { fg = "#1e1e2e", bg = "#f38ba8", bold = true })
vim.api.nvim_set_hl(0, "HelpCatGreen", { fg = "#1e1e2e", bg = "#a6e3a1", bold = true })
vim.api.nvim_set_hl(0, "HelpCatYellow", { fg = "#1e1e2e", bg = "#f9e2af", bold = true })
vim.api.nvim_set_hl(0, "HelpCatBlue", { fg = "#1e1e2e", bg = "#89b4fa", bold = true })
vim.api.nvim_set_hl(0, "HelpCatPink", { fg = "#1e1e2e", bg = "#f5c2e7", bold = true })
vim.api.nvim_set_hl(0, "HelpCatPurple", { fg = "#1e1e2e", bg = "#cba6f7", bold = true })
vim.api.nvim_set_hl(0, "HelpKey", { fg = "#89b4fa", bold = true })
vim.api.nvim_set_hl(0, "HelpDesc", { fg = "#cdd6f4" })

--- プレビューデータ（テキスト行 + extmarks）を生成するヘルパー
---@param sections table[] { name: string, hl: string, keys: string[][] }
---@param preview_width number
---@return string text, table[] extmarks
local function build_preview(sections, preview_width)
  local lines = {}
  local extmarks = {}
  local row = 0

  for i, section in ipairs(sections) do
    if i > 1 then
      table.insert(lines, "")
      row = row + 1
    end

    -- カテゴリラベル行（中央配置、overlay で色付き）
    local label = " " .. section.name .. " "
    local pad = math.floor((preview_width - #label) / 2)
    table.insert(lines, string.rep(" ", preview_width))
    table.insert(extmarks, {
      row = row + 1,
      col = math.max(pad, 0),
      virt_text = { { label, section.hl } },
      virt_text_pos = "overlay",
    })
    row = row + 1

    table.insert(lines, "")
    row = row + 1

    -- 各キーバインド行
    for _, item in ipairs(section.keys) do
      local key_str = item[1]
      local desc_str = item[2]
      local gap = preview_width - #key_str - #desc_str - 4
      local line = "  " .. desc_str .. string.rep(" ", math.max(gap, 1)) .. key_str
      table.insert(lines, line)

      table.insert(extmarks, {
        row = row + 1,
        col = 2,
        end_col = 2 + #desc_str,
        hl_group = "HelpDesc",
      })
      local key_start = #line - #key_str
      table.insert(extmarks, {
        row = row + 1,
        col = key_start,
        end_col = key_start + #key_str,
        hl_group = "HelpKey",
      })
      row = row + 1
    end
  end

  return table.concat(lines, "\n"), extmarks
end

-- Plugin Keybindings ヘルプ（Snacks.picker でプラグイン一覧 + プレビュー表示）
map("n", "<leader>?", function()
  local plugin_help = {
    {
      name = "Flash.nvim",
      sections = {
        {
          name = "Jump",
          hl = "HelpCatBlue",
          keys = {
            { "s", "Flash jump" },
            { "S", "Treesitter select" },
            { "r", "Remote Flash (o mode)" },
            { "R", "Treesitter Search (o/x mode)" },
            { "C-s", "Flash Search toggle (c mode)" },
          },
        },
      },
    },
    {
      name = "Overseer.nvim",
      sections = {
        {
          name = "Commands",
          hl = "HelpCatGreen",
          keys = {
            { "<leader>oo", "Toggle task list" },
            { "<leader>or", "Run task (template)" },
            { "<leader>os", "Shell command as task" },
            { "<leader>oa", "Task action (select)" },
            { "<leader>ol", "Restart last task" },
            { "<leader>oq", "Stop running task" },
            { ":Make", "Async make (quickfix)" },
            { ":Grep", "Async grep (quickfix)" },
            { ":OS <cmd>", "Run shell cmd as task" },
          },
        },
        {
          name = "Task List",
          hl = "HelpCatYellow",
          keys = {
            { "?", "Show help" },
            { "<CR>", "Run action" },
            { "o", "Open task output" },
            { "p", "Toggle preview" },
            { "dd", "Dispose task" },
            { "<C-e>", "Edit task" },
            { "<C-q>", "Send to quickfix" },
            { "<C-v>/<C-s>", "Open vsplit/split" },
            { "<C-f>", "Open in float" },
            { "{ / }", "Prev/Next task" },
            { "<C-k>/<C-j>", "Scroll output up/down" },
            { "q", "Close task list" },
          },
        },
      },
    },
    {
      name = "nvim-surround",
      sections = {
        {
          name = "Keybindings",
          hl = "HelpCatPurple",
          keys = {
            { "ys{motion}{char}", "surround add" },
            { "ds{char}", "surround delete" },
            { "cs{old}{new}", "surround change" },
            { "yss{char}", "surround line" },
            { "S{char}", "surround selection (v mode)" },
          },
        },
        {
          name = "Motion Examples",
          hl = "HelpCatPink",
          keys = {
            { "iw / aw", "inner word / a word" },
            { 'i" / a"', 'inner "..." / a "..."' },
            { "i) / a)", "inner (...) / a (...)" },
            { "i] / a]", "inner [...] / a [...]" },
            { "i} / a}", "inner {...} / a {...}" },
            { "it / at", "inner <tag> / a <tag>" },
          },
        },
        {
          name = "Char Examples",
          hl = "HelpCatRed",
          keys = {
            { ") or (", "()  ( adds space" },
            { "] or [", "[]  [ adds space" },
            { "} or {", "{}  { adds space" },
            { "> or <", "<>  < adds space" },
            { [[" ' `]], "quote with char" },
            { "t", "<tag>...</tag> (tag input)" },
          },
        },
      },
    },
    {
      name = "Copilot",
      sections = {
        {
          name = "Insert Mode (Suggestion)",
          hl = "HelpCatBlue",
          keys = {
            { "<M-c>", "Trigger / Next suggestion" },
            { "<M-y>", "Accept suggestion" },
            { "<M-p>", "Previous suggestion" },
            { "<M-d>", "Dismiss suggestion" },
          },
        },
        {
          name = "Normal Mode (<leader>a)",
          hl = "HelpCatGreen",
          keys = {
            { "<leader>at", "Toggle Copilot on/off" },
            { "<leader>as", "Copilot status" },
            { "<leader>ap", "Copilot panel" },
          },
        },
      },
    },
  }

  local items = {}
  for _, plugin in ipairs(plugin_help) do
    table.insert(items, {
      text = plugin.name,
      sections = plugin.sections,
    })
  end

  Snacks.picker.pick({
    title = "Plugin Keybindings Help",
    items = items,
    format = function(item)
      return { { "  " .. item.text, "Function" } }
    end,
    preview = function(ctx)
      ctx.preview:reset()
      local winfo = vim.fn.getwininfo(ctx.win)[1]
      local pw = winfo.width - winfo.textoff - 2
      local text, extmarks = build_preview(ctx.item.sections, pw)
      local lines = vim.split(text, "\n")
      ctx.preview:set_lines(lines)
      local ns = vim.api.nvim_create_namespace("help_preview")
      for _, extmark in ipairs(extmarks) do
        local e = vim.deepcopy(extmark)
        local row = e.row or 1
        local col = e.col or 0
        e.col = nil
        e.row = nil
        vim.api.nvim_buf_set_extmark(ctx.buf, ns, row - 1, col, e)
      end
    end,
    layout = {
      layout = {
        box = "horizontal",
        width = 0.85,
        height = 0.7,
        {
          box = "vertical",
          border = "rounded",
          { win = "input", height = 1, border = "bottom" },
          { win = "list" },
        },
        { win = "preview", width = 0.65, border = "rounded" },
      },
    },
    confirm = function(picker)
      picker:close()
    end,
  })
end, { desc = "Plugin keybindings help" })

map("n", "<leader>fw", function()
  local lga_actions = require("telescope-live-grep-args.actions")
  require("telescope").extensions.live_grep_args.live_grep_args({
    attach_mappings = function(_, map)
      map("i", "<C-k>", lga_actions.quote_prompt(), { desc = "Quote prompt" })
      map("i", "<C-g>", lga_actions.quote_prompt({ postfix = " --iglob " }), { desc = "Add --iglob pattern" })
      map("i", "<C-t>", lga_actions.quote_prompt({ postfix = " -t " }), { desc = "Add -t filetype" })
      return true
    end,
  })
end, { desc = "Live grep (with args) [C-/: which_key]" })

map("n", "<leader>fW", function()
  vim.ui.input({ prompt = "File extension: " }, function(ext)
    if not ext or ext == "" then return end
    local patterns = {}
    for e in ext:gmatch("[^,]+") do
      table.insert(patterns, "*." .. e:match("^%s*(.-)%s*$"))
    end
    require("telescope.builtin").live_grep({
      glob_pattern = patterns,
    })
  end)
end, { desc = "Live grep by extension" })

-- horizontal term toggle（n/t 両モードで <C-\> に統一）
map({ "n", "t" }, "<C-\\>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "Toggle horizontal terminal" })
