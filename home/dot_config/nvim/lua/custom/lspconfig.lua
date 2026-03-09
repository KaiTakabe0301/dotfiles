-- Custom LSP configuration (Neovim 0.11+ API)

local M = {}

M.setup = function()
  -- stylua: LSP サーバとして format-on-save を設定
  vim.lsp.config("stylua", {
    on_attach = function(_, bufnr)
      local augroup = vim.api.nvim_create_augroup("StyluaFormatting", { clear = false })
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({
            bufnr = bufnr,
            timeout_ms = 5000,
            filter = function(c)
              return c.name == "stylua"
            end,
          })
        end,
      })
    end,
  })

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
