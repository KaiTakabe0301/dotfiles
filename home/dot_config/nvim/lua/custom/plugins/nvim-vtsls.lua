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

        -- 保存時にコードアクションを自動実行
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            local function apply_code_action(kind)
              local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
              params.context = { only = { kind }, diagnostics = {} }
              local result = client:request_sync("textDocument/codeAction", params, 3000, bufnr)
              if result and result.result then
                for _, action in ipairs(result.result) do
                  if not action.edit and not action.command then
                    local resolved = client:request_sync("codeAction/resolve", action, 3000, bufnr)
                    if resolved and resolved.result then
                      action = resolved.result
                    end
                  end
                  if action.edit then
                    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
                  end
                  if action.command then
                    local command = type(action.command) == "table" and action.command or action
                    client:request_sync("workspace/executeCommand", {
                      command = command.command,
                      arguments = command.arguments,
                    }, 3000, bufnr)
                  end
                end
              end
            end

            apply_code_action("source.addMissingImports")
            apply_code_action("source.removeUnusedImports")
          end,
        })

        -- semantic tokens は 0.12 では既定でグローバル有効、LspAttach 後に
        -- 自動アタッチされるため明示的な enable は不要（bufnr と client_id は
        -- 排他で両指定は不可）。初回アタッチ直後に再取得してハイライトを反映する。
        if client.server_capabilities.semanticTokensProvider then
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
