return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- eslint設定ファイルの存在チェック
    local eslint_configs = {
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
    }

    lint.linters_by_ft = {
      python = { "ruff", "mypy" },
      go = { "staticcheck", "golangcilint" },
      yaml = { "yamllint" },
      markdown = { "markdownlint" },
      sh = { "shellcheck" },
      bash = { "shellcheck" },
    }

    -- カスタム引数の追加
    -- nvim-lint のリンター定義はテーブルで直接上書きする
    lint.linters.mypy = require("lint.linters.mypy")
    lint.linters.mypy.args = vim.list_extend(
      vim.deepcopy(require("lint.linters.mypy").args),
      { "--ignore-missing-imports" }
    )

    lint.linters.yamllint = require("lint.linters.yamllint")
    lint.linters.yamllint.args = { "-d", "relaxed", "-f", "parsable", "-" }

    lint.linters.markdownlint = require("lint.linters.markdownlint")
    lint.linters.markdownlint.args = vim.list_extend(
      vim.deepcopy(require("lint.linters.markdownlint").args),
      { "--disable", "MD013", "--" }
    )

    -- autocmd でリンティングを自動実行
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
      callback = function(args)
        if vim.bo[args.buf].buftype ~= "" then
          return
        end

        -- 通常のリンティング
        lint.try_lint()

        -- eslint_d: 条件付き（eslint設定ファイルが存在する場合のみ）
        local ft = vim.bo[args.buf].filetype
        local js_fts = {
          javascript = true,
          javascriptreact = true,
          typescript = true,
          typescriptreact = true,
        }
        if js_fts[ft] then
          local found = vim.fs.find(eslint_configs, {
            upward = true,
            path = vim.fs.dirname(vim.api.nvim_buf_get_name(args.buf)),
            stop = vim.uv.os_homedir(),
          })[1]
          if found then
            lint.try_lint({ "eslint_d" })
          end
        end
      end,
    })
  end,
}
