-- none-ls.nvim and mason-null-ls.nvim configuration for linting and formatting

return {
  -- none-ls.nvim (formerly null-ls)
  "nvimtools/none-ls.nvim",

  dependencies = {
    "jay-babu/mason-null-ls.nvim",
    "williamboman/mason.nvim",
    "nvim-lua/plenary.nvim",
    "nvimtools/none-ls-extras.nvim",
    "gbprod/none-ls-shellcheck.nvim",
  },

  event = { "BufReadPre", "BufNewFile" },

  config = function()
    -- Setup mason-null-ls for automatic tool installation
    require("mason-null-ls").setup({
      ensure_installed = {
        -- Python
        "ruff",          -- Fast Python linter and formatter
        "black",         -- Python formatter
        "mypy",          -- Python type checker

        -- Go
        "gofumpt",       -- Go formatter (stricter than gofmt)
        "goimports",     -- Go import formatter
        "staticcheck",   -- Go linter
        "golangci-lint", -- Go meta linter

        -- Rust
        "rustfmt",       -- Rust formatter

        -- TypeScript/JavaScript
        "prettier",      -- Multi-language formatter
        "eslint_d",      -- Fast ESLint daemon

        -- YAML
        "yamllint",      -- YAML linter

        -- Markdown
        "markdownlint",  -- Markdown linter

        -- Lua
        "stylua",        -- Lua formatter

        -- Shell
        "shfmt",         -- Shell formatter
        "shellcheck",    -- Shell linter
      },
      automatic_installation = true,
      handlers = {},
    })

    -- Setup none-ls
    local null_ls = require("null-ls")
    local formatting = null_ls.builtins.formatting
    local diagnostics = null_ls.builtins.diagnostics
    local code_actions = null_ls.builtins.code_actions

    -- none-ls-extras sources
    local extras_formatting = {
      ruff = require("none-ls.formatting.ruff"),
    }
    local extras_diagnostics = {
      ruff = require("none-ls.diagnostics.ruff"),
      eslint_d = require("none-ls.diagnostics.eslint_d"),
    }
    local extras_code_actions = {
      eslint_d = require("none-ls.code_actions.eslint_d"),
    }

    -- Helper function to check if a file exists
    local function file_exists(patterns)
      for _, pattern in ipairs(patterns) do
        if vim.fn.glob(pattern) ~= "" then
          return true
        end
      end
      return false
    end

    null_ls.setup({
      debug = false,
      sources = {
        -- Python
        formatting.black.with({
          extra_args = { "--line-length", "88" },
        }),
        extras_formatting.ruff.with({
          extra_args = { "--fix" },
        }),
        extras_diagnostics.ruff,
        diagnostics.mypy.with({
          extra_args = { "--ignore-missing-imports" },
        }),

        -- Go
        formatting.gofumpt,
        formatting.goimports,
        diagnostics.staticcheck,
        diagnostics.golangci_lint,

        -- Rust
        -- formatting.rustfmt, -- Deprecated: use rust-analyzer instead

        -- TypeScript/JavaScript
        formatting.prettier.with({
          filetypes = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
            "css",
            "scss",
            "less",
            "html",
            "json",
            "jsonc",
            "yaml",
            "markdown",
            "markdown.mdx",
            "graphql",
            "handlebars",
          },
          condition = function()
            return file_exists({
              ".prettierrc",
              ".prettierrc.json",
              ".prettierrc.yml",
              ".prettierrc.yaml",
              ".prettierrc.json5",
              ".prettierrc.js",
              ".prettierrc.cjs",
              "prettier.config.js",
              "prettier.config.cjs",
            })
          end,
        }),
        extras_diagnostics.eslint_d.with({
          condition = function()
            return file_exists({
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.cjs",
              ".eslintrc.yaml",
              ".eslintrc.yml",
              ".eslintrc.json",
              "eslint.config.js",
              "eslint.config.cjs",
              "eslint.config.mjs",
              "eslint.config.ts",
            })
          end,
        }),
        extras_code_actions.eslint_d.with({
          condition = function()
            return file_exists({
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.cjs",
              ".eslintrc.yaml",
              ".eslintrc.yml",
              ".eslintrc.json",
              "eslint.config.js",
              "eslint.config.cjs",
              "eslint.config.mjs",
              "eslint.config.ts",
            })
          end,
        }),

        -- YAML
        diagnostics.yamllint.with({
          extra_args = { "-d", "relaxed" },
        }),

        -- Markdown
        diagnostics.markdownlint.with({
          extra_args = { "--disable", "MD013" }, -- Disable line length rule
        }),

        -- Lua
        formatting.stylua.with({
          extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        }),

        -- Shell
        formatting.shfmt.with({
          extra_args = { "-i", "2", "-ci" }, -- 2 spaces, indent case statements
        }),
        require("none-ls-shellcheck.diagnostics"),
      },

      -- Format on save configuration
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          -- Clear existing autocmds to avoid duplicates
          vim.api.nvim_clear_autocmds({
            group = augroup,
            buffer = bufnr,
          })

          -- Create autocmd for format on save
          local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              -- Format with timeout
              vim.lsp.buf.format({
                bufnr = bufnr,
                timeout_ms = 5000,
                filter = function(c)
                  return c.name == "null-ls"
                end,
              })
            end,
          })
        end
      end,
    })
  end,
}