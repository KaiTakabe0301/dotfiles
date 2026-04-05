
return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css", "javascript", "typescript", "tsx", "json",
        "python", "go", "rust", "yaml", "toml", "markdown", "bash",
        "graphql"
      },
    },
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)

      -- treesitter indent が安定している言語のみ適用
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "lua", "vim",
          "html", "css", "json",
          "python", "go", "rust", "yaml", "toml", "markdown", "bash",
          "graphql",
        },
        callback = function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      -- JS/TS は treesitter indent にバグがあるため cindent を使用
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "javascript", "typescript", "typescriptreact" },
        callback = function()
          vim.bo.indentexpr = ""
          vim.bo.cindent = true
        end,
      })
    end,
}
