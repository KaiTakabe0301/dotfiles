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

-- 3. バッファ関連のマッピングを追加
map("n", "<leader>bb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
map("n", "<leader>bd", smart_buffer_delete, { desc = "Delete buffer (smart)" })
map("n", "<leader>bn", function() require("custom.winbuf").next() end, { desc = "Next buffer (window-scoped)" })
map("n", "<leader>bp", function() require("custom.winbuf").prev() end, { desc = "Previous buffer (window-scoped)" })
map("n", "<leader>bc", "<cmd>enew<cr>", { desc = "Create new buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Force delete buffer" })

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
