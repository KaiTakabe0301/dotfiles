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

-- Plugin Keybindings ヘルプ（Snacks.win で一覧 → 詳細表示）
do
  local plugin_help = {
    {
      name = "Flash.nvim",
      pages = {
        {
          title = "Flash.nvim",
          lines = {
            " s       Flash ジャンプ",
            " S       Treesitter 選択",
            " r       Remote Flash (oモード)",
            " R       Treesitter Search (o/xモード)",
            " C-s     Flash Search 切替 (cモード)",
          },
        },
      },
    },
    {
      name = "nvim-surround",
      pages = {
        {
          title = "nvim-surround - キーバインド",
          lines = {
            " ys{motion}{char}   surround 追加",
            " ds{char}           surround 削除",
            " cs{old}{new}       surround 変更",
            " yss{char}          行全体を surround",
            " S{char}            選択範囲を surround (vモード)",
          },
        },
        {
          title = "nvim-surround - motion / char",
          lines = {
            " [motion の例]",
            " iw    inner word       aw    a word",
            " i\"    inner \"...\"      a\"    a \"...\"",
            " i)    inner (...)      a)    a (...)",
            " i]    inner [...]      a]    a [...]",
            " i}    inner {...}      a}    a {...}",
            " it    inner <tag>      at    a <tag>",
            " is    inner sentence   as    a sentence",
            "",
            " [char の例]",
            " ) or (   ()  ※( はスペース付き",
            " ] or [   []  ※[ はスペース付き",
            " } or {   {}  ※{ はスペース付き",
            " > or <   <>  ※< はスペース付き",
            " \" ' `    引用符で囲む",
            " t        <tag>...</tag> (タグ入力)",
          },
        },
      },
    },
  }

  local function calc_width(content, title)
    local max_w = vim.fn.strdisplaywidth(title) + 4
    for _, line in ipairs(content) do
      local w = vim.fn.strdisplaywidth(line)
      if w > max_w then max_w = w end
    end
    return math.min(max_w + 4, vim.o.columns - 4)
  end

  local show_index, show_plugin

  show_index = function()
    local content = { "" }
    for i, plugin in ipairs(plugin_help) do
      table.insert(content, "  " .. i .. ". " .. plugin.name)
    end
    table.insert(content, "")
    table.insert(content, " [Enter: select] [q: quit]")

    local title = "Plugin Help"
    local win = Snacks.win({
      text = content,
      width = calc_width(content, title),
      height = #content,
      border = "rounded",
      title = " " .. title .. " ",
      title_pos = "center",
      enter = true,
      backdrop = 60,
      wo = { cursorline = true },
      keys = {
        q = "close",
        ["<CR>"] = function(self)
          local cursor = vim.api.nvim_win_get_cursor(self.win)
          local idx = cursor[1] - 1
          if idx >= 1 and idx <= #plugin_help then
            self:close()
            vim.schedule(function()
              show_plugin(idx)
            end)
          end
        end,
      },
      on_win = function(self)
        vim.api.nvim_win_set_cursor(self.win, { 2, 0 })
      end,
    })
  end

  show_plugin = function(idx)
    local plugin = plugin_help[idx]
    local pages = plugin.pages
    local current_page = 1

    local function build_content()
      local page = pages[current_page]
      local content = { "" }
      for _, line in ipairs(page.lines) do
        table.insert(content, line)
      end
      table.insert(content, "")
      if #pages > 1 then
        table.insert(content, string.format(
          " [n: next] [p: prev] [b: back] [q: quit]  %d/%d",
          current_page, #pages
        ))
      else
        table.insert(content, " [b: back] [q: quit]")
      end
      return content
    end

    local function get_title()
      return plugin.name .. " - " .. pages[current_page].title
    end

    local content = build_content()
    local title = get_title()
    local win = Snacks.win({
      text = content,
      width = calc_width(content, title),
      height = #content,
      border = "rounded",
      title = " " .. title .. " ",
      title_pos = "center",
      enter = true,
      backdrop = 60,
      keys = {
        q = "close",
        b = function(self)
          self:close()
          vim.schedule(show_index)
        end,
        n = #pages > 1 and function(self)
          if current_page < #pages then
            current_page = current_page + 1
            local c = build_content()
            local t = get_title()
            vim.bo[self.buf].modifiable = true
            vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, c)
            vim.bo[self.buf].modifiable = false
            local w = calc_width(c, t)
            vim.api.nvim_win_set_config(self.win, {
              relative = "editor",
              width = w,
              height = #c,
              col = math.floor((vim.o.columns - w) / 2),
              row = math.floor((vim.o.lines - #c) / 2),
              title = " " .. t .. " ",
              title_pos = "center",
            })
          end
        end or nil,
        p = #pages > 1 and function(self)
          if current_page > 1 then
            current_page = current_page - 1
            local c = build_content()
            local t = get_title()
            vim.bo[self.buf].modifiable = true
            vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, c)
            vim.bo[self.buf].modifiable = false
            local w = calc_width(c, t)
            vim.api.nvim_win_set_config(self.win, {
              relative = "editor",
              width = w,
              height = #c,
              col = math.floor((vim.o.columns - w) / 2),
              row = math.floor((vim.o.lines - #c) / 2),
              title = " " .. t .. " ",
              title_pos = "center",
            })
          end
        end or nil,
      },
    })
  end

  map("n", "<C-h>", show_index, { desc = "Plugin keybindings help" })
end

map("n", "<leader>fw", function()
  require("telescope").extensions.live_grep_args.live_grep_args()
end, { desc = "Live grep (with args) [C-h: help]" })

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
