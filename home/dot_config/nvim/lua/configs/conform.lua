local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_fix", "black" },
    go = { "goimports", "gofumpt" },
    javascript = { "prettier", "oxfmt", "eslint_d" },
    javascriptreact = { "prettier", "oxfmt", "eslint_d" },
    typescript = { "prettier", "oxfmt", "eslint_d" },
    typescriptreact = { "prettier", "oxfmt", "eslint_d" },
    vue = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    less = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    ["markdown.mdx"] = { "prettier" },
    graphql = { "prettier" },
    handlebars = { "prettier" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
  },

  formatters = {
    black = {
      prepend_args = { "--line-length", "88" },
    },
    shfmt = {
      prepend_args = { "-i", "2", "-ci" },
    },
    prettier = {
      condition = function(self, ctx)
        -- prettier設定ファイルが存在する場合のみ実行（none-lsと同じ条件）
        return vim.fs.find({
          ".prettierrc",
          ".prettierrc.json",
          ".prettierrc.yml",
          ".prettierrc.yaml",
          ".prettierrc.json5",
          ".prettierrc.js",
          ".prettierrc.cjs",
          "prettier.config.js",
          "prettier.config.cjs",
        }, {
          upward = true,
          path = vim.fs.dirname(vim.api.nvim_buf_get_name(ctx.buf)),
          stop = vim.uv.os_homedir(),
        })[1] ~= nil
      end,
    },
    eslint_d = {
      condition = function(self, ctx)
        return vim.fs.find({
          ".eslintrc", ".eslintrc.js", ".eslintrc.cjs",
          ".eslintrc.yaml", ".eslintrc.yml", ".eslintrc.json",
          "eslint.config.js", "eslint.config.cjs",
          "eslint.config.mjs", "eslint.config.ts",
        }, {
          upward = true,
          path = vim.fs.dirname(vim.api.nvim_buf_get_name(ctx.buf)),
          stop = vim.uv.os_homedir(),
        })[1] ~= nil
      end,
    },
  },

  format_on_save = {
    timeout_ms = 5000,
    lsp_format = "fallback",
  },
}

return options
