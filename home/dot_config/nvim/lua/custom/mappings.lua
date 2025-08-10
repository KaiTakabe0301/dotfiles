local map = vim.keymap.set
local nomap = vim.keymap.del

-- 既存のカスタムマッピング
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jj", "<ESC>")

-- 1. デフォルトの <leader>b (新規バッファ作成) を無効化
-- NvChadのデフォルトマッピングを削除
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    pcall(function()
      nomap("n", "<leader>b")
    end)
  end,
})

-- 2. which-keyのためのバッファグループを設定
-- which-keyが自動的にグループとして認識するように設定
map("n", "<leader>b", function()
  -- 何もしない関数をマップして、which-keyがサブコマンドを表示するようにする
end, { desc = "Buffers" })

-- 3. バッファ関連のマッピングを追加
map("n", "<leader>bb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Force delete buffer" })
