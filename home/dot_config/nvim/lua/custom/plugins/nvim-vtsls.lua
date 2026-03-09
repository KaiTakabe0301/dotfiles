return {
  "yioneko/nvim-vtsls",
  lazy = false,
  dependencies = { "neovim/nvim-lspconfig" },
  config = function()
    vim.lsp.config("vtsls", {
      -- NvChad の on_init（semanticTokens 無効化）をオーバーライド
      -- vtsls では semantic tokens を有効のままにする
      on_init = function(client, _) end,

      on_attach = function(client, bufnr)
        -- nvim-vtsls のコマンド登録（VtsExec, VtsRename 等）
        require("vtsls")._on_attach(client.id, bufnr)

        -- semantic tokens を有効化・リフレッシュ
        if client.server_capabilities.semanticTokensProvider then
          vim.lsp.semantic_tokens.start(bufnr, client.id)
          vim.defer_fn(function()
            pcall(vim.lsp.semantic_tokens.refresh, bufnr)
          end, 50)
        end
      end,

      root_dir = function(bufnr, on_dir)
        on_dir(
          vim.fs.root(bufnr, { "tsconfig.json" })
            or vim.fs.root(bufnr, { "package.json", "jsconfig.json" })
            or vim.fs.root(bufnr, { ".git" })
        )
      end,
      single_file_support = false,

      settings = {
        complete_function_calls = true,
        vtsls = {
          enableMoveToFileCodeAction = true,
          autoUseWorkspaceTsdk = true,
          experimental = {
            completion = { enableServerSideFuzzyMatch = true },
          },
        },
        typescript = {
          updateImportsOnFileMove = { enabled = "always" },
          suggest = { completeFunctionCalls = true },
          tsserver = { pluginPaths = { "." } },
          inlayHints = {
            enumMemberValues = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            parameterNames = { enabled = "literals" },
            parameterTypes = { enabled = true },
            propertyDeclarationTypes = { enabled = true },
            variableTypes = { enabled = false },
          },
        },
      },
    })

    -- LspDetach 時に nvim-vtsls のクリーンアップを実行
    vim.api.nvim_create_autocmd("LspDetach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "vtsls" then
          require("vtsls")._on_detach(args.data.client_id, args.buf)
        end
      end,
    })
  end,
}
