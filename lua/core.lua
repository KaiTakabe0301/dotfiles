-- 表示
-- -番号表示
vim.opt.number = true
-- -特殊文字表示
vim.opt.list = true
vim.opt.listchars = { tab = '>-', trail = '*', nbsp = '+' }
-- -エラー時の音を画面表示に
vim.opt.visualbell = true
-- -括弧の連携
vim.opt.showmatch = true
vim.opt.matchtime = 1
-- -ヘルプファイル
vim.opt.helplang = 'ja,en'
-- -tabバーの表示
vim.opt.showtabline = 2
-- -検索した単語のハイライト
vim.opt.hls = true
-- -画面を縦分割した際に、右側に開く
vim.opt.splitright = true
-- -テキストの折り返しを防ぐ
-- vim.opt.nowrap = true


-- 入力時
-- -インデントをC言語風に
vim.opt.smartindent = true
-- -タブ文字
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- 検索
-- -大文字無視
vim.opt.ignorecase = true
-- -大文字で検索したら区別をつける
vim.opt.smartcase = true
-- -検索が末尾までいったら先頭から検索
vim.opt.wrapscan = true

-- カーソル移動
-- - 行を跨いでの移動
vim.opt.whichwrap = 'b,s,h,l,<,>,[,]'
-- - 削除時の対象
vim.opt.backspace = 'start,eol,indent'

-- ファイル環境
-- -フォーマット
vim.opt.fileformats = 'unix'

-- クリップボード連携
vim.opt.clipboard = 'unnamedplus'

-- マウス有効
vim.opt.mouse = 'a'

