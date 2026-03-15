-- Custom initialization for NvChad
-- This file is loaded after NvChad's core init

-- Force base46 to recompile and apply theme changes
vim.schedule(function()
  -- Check if base46 is available
  local status_ok, base46 = pcall(require, "base46")
  if not status_ok then
    return
  end

  -- Compile themes with our custom colors
  base46.compile()

  -- Load all highlights including our changed_themes
  base46.load_all_highlights()

  -- Optionally, print a message to confirm recompilation
  -- vim.notify("Base46 theme recompiled with custom colors", vim.log.levels.INFO)
end)

-- どこか早めに読み込まれる init.lua / custom/init.lua などに
if vim.highlight and vim.highlight.priorities then
  local p = vim.highlight.priorities
  -- semantic_tokens を Treesitter より上に
  p.semantic_tokens = math.max((p.treesitter or 100) + 1, p.semantic_tokens or 95)
end

-- 不可視文字を表示
vim.opt.list = true

-- 表示方法を指定
vim.opt.listchars = {
  space = "·", -- 半角スペースを「·」で表示
  tab = "→ ", -- タブを「→」＋スペースで表示
  trail = "•", -- 行末のスペースを「•」で表示
  extends = "❯", -- 画面幅を超える部分
  precedes = "❮", -- 行頭が画面外の場合
  nbsp = "␣", -- ノーブレークスペース
}

-- nvdash のリサイズ時カーソルエラー (E5108) を修正
-- リサイズ後に "refresh" アクションで open() を呼び、カーソル再設定とキーマップ再構築を実行する
vim.api.nvim_create_autocmd({ "WinResized", "VimResized" }, {
  callback = function()
    vim.schedule(function()
      local buf = vim.g.nvdash_buf
      local win = vim.g.nvdash_win
      if buf and win
        and vim.api.nvim_buf_is_valid(buf)
        and vim.api.nvim_win_is_valid(win)
        and vim.api.nvim_win_get_buf(win) == buf
        and vim.bo[buf].filetype == "nvdash" then
        vim.bo[buf].ma = true
        pcall(require("nvchad.nvdash").open, buf, win, "refresh")
      end
    end)
  end,
})

-- ウィンドウスコープのバッファ管理を有効化
require("custom.winbuf").setup()
require("custom.winbar").setup()
