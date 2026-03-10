-- Custom LSP configuration (Neovim 0.11+ API)

local M = {}

M.setup = function()
  -- lua_ls: NvChad defaults に追加の設定をマージ
  vim.lsp.config("lua_ls", {
    -- nvim-lspconfig v2+ が Neovim 0.11.3 向けにネストされた root_markers を定義するため
    -- :checkhealth vim.lsp の table.concat() でエラーになる問題を回避
    root_markers = {
      ".emmyrc.json",
      ".luarc.json",
      ".luarc.jsonc",
      ".luacheckrc",
      ".stylua.toml",
      "stylua.toml",
      "selene.toml",
      "selene.yml",
      ".git",
    },
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })

  -- 他のサーバはデフォルト設定で十分なため、
  -- automatic_enable = true により自動有効化される
end

return M
