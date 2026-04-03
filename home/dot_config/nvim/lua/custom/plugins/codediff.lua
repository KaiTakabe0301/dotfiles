local function show_codediff_help()
  local lines = {
    " CodeDiff - Keybindings ",
    "─────────────────────────────────",
    " Navigation:",
    "  ]c / [c     次/前の変更箇所",
    "  ]f / [f     次/前のファイル",
    "  ]x / [x     次/前のコンフリクト",
    "─────────────────────────────────",
    " Actions:",
    "  -           ステージ/アンステージ",
    "  <leader>hs  ハンクをステージ",
    "  <leader>hu  ハンクをアンステージ",
    "  <leader>hr  ハンクを破棄",
    "  do / dp     変更を取得/送信",
    "─────────────────────────────────",
    " View:",
    "  t           レイアウト切替 (side/inline)",
    "  <leader>b   エクスプローラ表示切替",
    "  <leader>e   エクスプローラにフォーカス",
    "  gf          前のタブで開く",
    "  gm          移動コード整列",
    "─────────────────────────────────",
    " Conflict Resolution:",
    "  <leader>co  Current (ours) を採用",
    "  <leader>ct  Incoming (theirs) を採用",
    "  <leader>cb  両方採用",
    "  <leader>cx  両方破棄",
    "─────────────────────────────────",
    "  q           閉じる",
    "  g?          プラグインヘルプ",
  }
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local width = 40
  local height = #lines
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.api.nvim_set_option_value("winhl", "Normal:Normal,FloatBorder:FloatBorder", { win = win })
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, nowait = true })
end

return {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  keys = {
    { "<leader>gd", "<cmd>CodeDiff<cr>", desc = "CodeDiff (差分表示)" },
    { "<leader>gh", "<cmd>CodeDiff history<cr>", desc = "CodeDiff History (履歴)" },
  },
  config = function(_, opts)
    require("codediff").setup(opts)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "codediff*",
      callback = function(ev)
        vim.keymap.set("n", "<C-h>", show_codediff_help, { buffer = ev.buf, desc = "CodeDiff Help" })
      end,
    })
  end,
  opts = {
    diff = {
      layout = "side-by-side",
      jump_to_first_change = true,
      cycle_next_hunk = true,
      cycle_next_file = true,
    },
    explorer = {
      position = "left",
      width = 40,
      view_mode = "tree",
    },
    history = {
      position = "bottom",
      height = 15,
    },
  },
}
