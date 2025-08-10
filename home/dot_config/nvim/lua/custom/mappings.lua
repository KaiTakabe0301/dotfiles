-- NvChad v2.5の正しい形式で設定

local map = vim.keymap.set
local nomap = vim.keymap.del

-- 既存のカスタムマッピング
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jj", "<ESC>")

-- 1. デフォルトの <leader>b (新規バッファ作成) を無効化
-- NvChadのデフォルトマッピングを削除
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      pcall(vim.keymap.del, "n", "<leader>b")
    end, 100)
  end,
})

-- 2. スマートなバッファ削除関数
local function smart_buffer_delete()
  local bufnr = vim.api.nvim_get_current_buf()
  local buflisted = vim.fn.getbufinfo({buflisted = 1})
  
  -- リストされているバッファが1つだけの場合
  if #buflisted == 1 then
    -- nvim-treeが開いているか確認
    local nvim_tree_open = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
      if ft == 'NvimTree' then
        nvim_tree_open = true
        vim.api.nvim_set_current_win(win)  -- nvim-treeにフォーカスを移動
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
    -- 通常のバッファ削除
    vim.cmd('bdelete')
  end
end

-- 3. バッファ関連のマッピングを追加
map("n", "<leader>bb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
map("n", "<leader>bd", smart_buffer_delete, { desc = "Delete buffer (smart)" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Force delete buffer" })

-- 4. デフォルトのwhich-keyマッピングを削除して移動
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      -- which-key関連の削除
      pcall(vim.keymap.del, "n", "<leader>wK")
      pcall(vim.keymap.del, "n", "<leader>wk")

      -- 念のためLSP関連も削除（存在する場合）
      pcall(vim.keymap.del, "n", "<leader>wa")
      pcall(vim.keymap.del, "n", "<leader>wr")
      pcall(vim.keymap.del, "n", "<leader>wl")
    end, 100)
  end,
})

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
