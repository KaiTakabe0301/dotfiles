-- Custom plugins configuration

-- Load custom init script
vim.schedule(function()
  local init_path = vim.fn.stdpath("config") .. "/lua/custom/init.lua"
  if vim.fn.filereadable(init_path) == 1 then
    dofile(init_path)
  end
end)

return {
  -- Mason-lspconfig for automatic LSP installation
  {
    "mason-org/mason-lspconfig.nvim",
     config = function()
       require "configs.lspconfig"
     end,
    lazy = false,
    opts = {
      automatic_installation = true,
      ensure_installed = {
        "lua_ls",
        "vtsls",
        "html",
        "cssls",
        "pyright",
        "gopls",
        "rust_analyzer",
        "yamlls",
        "jsonls",
        "bashls",
      },
    },
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        { "neovim/nvim-lspconfig", opts = {} },
    },
  },

  -- nvim-vtsls for TypeScript
  {
    "yioneko/nvim-vtsls",
    lazy = false,
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")
      local nvlsp = require("nvchad.configs.lspconfig")

      -- 既定サーバ定義の登録（公式推奨）
      require("lspconfig.configs").vtsls = require("vtsls").lspconfig

      -- 1) on_init で元の semanticTokensProvider を退避
      local function on_init_capture_semantic(client, _)
        client._saved_semantic = client.server_capabilities.semanticTokensProvider
      end

      -- 2) on_attach で NvChad の on_attach を実行 → 復元 → start
      local function on_attach_restore_and_start(client, bufnr)
        -- まず既存の on_attach（キーマップ等）を適用
        pcall(nvlsp.on_attach, client, bufnr)

        -- NvChad に潰されたら元に戻す
        if not client.server_capabilities.semanticTokensProvider and client._saved_semantic then
          client.server_capabilities.semanticTokensProvider = client._saved_semantic
        end

        -- 有効なら開始＋リフレッシュ
        if client.server_capabilities.semanticTokensProvider then
          vim.lsp.semantic_tokens.start(bufnr, client.id)
          vim.defer_fn(function() pcall(vim.lsp.semantic_tokens.refresh, bufnr) end, 50)
        end
      end

      lspconfig.vtsls.setup {
        on_init = on_init_capture_semantic,
        on_attach = on_attach_restore_and_start, -- ←ここが大事。関数名ミス注意！
        capabilities = nvlsp.capabilities,

        -- ★ これが肝：最寄り tsconfig を“優先”してパッケージ単位で root を切る
        root_dir = function(fname)
          return util.root_pattern("tsconfig.json")(fname)
              or util.root_pattern("package.json", "jsconfig.json")(fname)
              or util.find_git_ancestor(fname)
        end,
        single_file_support = false,

        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true, -- ★ 各パッケージの node_modules/typescript を自動使用
            experimental = {
              completion = { enableServerSideFuzzyMatch = true },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = { completeFunctionCalls = true },
            -- pnpm/yarn Workspace でローカル plugin を見つけやすくする保険（任意）
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
      }
    end,
  }




  ,

  -- Enhanced TreeSitter language support
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css", "javascript", "typescript", "tsx", "json",
        "python", "go", "rust", "yaml", "toml", "markdown", "bash",
        "graphql"
      },
    },
  },

  -- Load none-ls configuration
  require("custom.plugins.none-ls"),
}