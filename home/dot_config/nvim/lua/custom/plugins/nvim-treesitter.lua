
return {
    "KaiTakabe0301/nvim-treesitter",
    branch = "fix/indent-stacked-delimiters-in-arguments",
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

      -- treesitter indent を適用
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "lua", "vim",
          "html", "css", "json",
          "python", "go", "rust", "yaml", "toml", "markdown", "bash",
          "graphql",
          "javascript", "typescript", "typescriptreact",
        },
        callback = function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
}
