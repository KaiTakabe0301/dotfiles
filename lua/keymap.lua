-- leaderをSpaceに設定
vim.g.mapleader = " "

local api = vim.api

-- ✨1. Normal Mode
-- 5行ずつ上下に移動
api.nvim_set_keymap('n', '<S-j>', '5j', { noremap = true, silent = true })
api.nvim_set_keymap('n', '<S-k>', '5k', { noremap = true, silent = true })

-- 表示行単位で上下移動
api.nvim_set_keymap('n', 'j', 'gj', { noremap = true })
api.nvim_set_keymap('n', 'k', 'gk', { noremap = true })
api.nvim_set_keymap('n', '<Down>', 'gj', { noremap = true })
api.nvim_set_keymap('n', '<Up>', 'gk', { noremap = true })
-- 逆に普通の行単位で移動したい時のために、逆のmapを設定
api.nvim_set_keymap('n', 'gj', 'j', { noremap = true })
api.nvim_set_keymap('n', 'gk', 'k', { noremap = true })
-- 行頭行末の移動にleaderを使用
api.nvim_set_keymap('n', '<leader>a', '^', { noremap = true })
api.nvim_set_keymap('n', '<leader>e', '$', { noremap = true })
-- バッファの切り替え
api.nvim_set_keymap('n', '<leader>n', ':bnext<CR>', { noremap = true, silent = true })
api.nvim_set_keymap('n', '<leader>p', ':bprev<CR>', { noremap = true, silent = true })
api.nvim_set_keymap('n', '<leader>x', ':bd<CR>', { noremap = true, silent = true })
-- 一文字削除の時は、ブラックホールレジスタに格納
api.nvim_set_keymap('n', 'x', '"_x', { noremap = true, silent = true })
api.nvim_set_keymap('n', 'X', '"_X', { noremap = true, silent = true })
-- 行削除の時は、ブラックホールレジスタに格納
api.nvim_set_keymap('n', 'dd', '"_dd', { noremap = true, silent = true })


-- ✨2. Insert Mode
-- Insert Mode -> Normal Mode を jj で行う
api.nvim_set_keymap('i', 'jj', '<esc>', { noremap = true })
-- Ctrl+d で一文字削除
api.nvim_set_keymap('i', '<C-d>', '<BS>', { noremap = true })
-- Ctrl+hjkl で上下左右に移動
api.nvim_set_keymap('i', '<C-j>', '<Down>', { noremap = true })
api.nvim_set_keymap('i', '<C-k>', '<Up>', { noremap = true })
api.nvim_set_keymap('i', '<C-h>', '<Left>', { noremap = true })
api.nvim_set_keymap('i', '<C-l>', '<Right>', { noremap = true })


-- ✨3. Visual Mode
-- cursor move
api.nvim_set_keymap('v', '<S-j>', '5j', { noremap = true, silent = true })
api.nvim_set_keymap('v', '<S-k>', '5k', { noremap = true, silent = true })


-- ✨4. Command Mode
api.nvim_set_keymap('c', '<C-p>', '<Up>', { noremap = true, silent = true })
api.nvim_set_keymap('c', '<C-n>', '<Down>', { noremap = true, silent = true })
api.nvim_set_keymap('c', '<C-b>', '<Left>', { noremap = true, silent = true })
api.nvim_set_keymap('c', '<C-f>', '<Right>', { noremap = true, silent = true })

-- save file
api.nvim_set_keymap('n', '<leader>w', '<cmd>update<cr>', { noremap = true })
