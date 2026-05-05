
return {
    "KaiTakabe0301/nvim-treesitter",
    branch = "fix/indent-stacked-delimiters-in-arguments",
    init = function()
      -- すべての .tmpl / .gotmpl は gotmpl filetype に倒し、
      -- 二重拡張子（.html.tmpl など）からホスト言語を判定して
      -- gotmpl の text ノードにそのホスト言語を inject する方式で扱う。
      vim.filetype.add({
        extension = {
          tmpl = "gotmpl",
          gotmpl = "gotmpl",
        },
      })
    end,
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css", "javascript", "typescript", "tsx", "json",
        "python", "go", "rust", "yaml", "toml", "markdown", "bash",
        "graphql",
        "gotmpl", "ruby",
      },
    },
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)

      -- main branch の setup() は opts.ensure_installed を見ないため、
      -- install モジュールの API を直接呼んで未インストールの parser を揃える
      local install = require("nvim-treesitter.install")
      if opts.ensure_installed and #opts.ensure_installed > 0 then
        install.ensure_installed(unpack(opts.ensure_installed))
      end
      -- 開いたバッファの filetype に対応する parser がなければ自動 install
      install.setup_auto_install()

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

      -- buffer-local で gotmpl のホスト言語を判定する custom predicate
      -- after/queries/gotmpl/injections.scm の (#gotmpl-host? "json") と組み合わせる
      pcall(vim.treesitter.query.add_predicate, "gotmpl-host?", function(_, _, source, predicate)
        if type(source) ~= "number" then return false end
        return vim.b[source].gotmpl_host == predicate[2]
      end, { force = true, all = false })

      -- gotmpl は NvChad のデフォルト highlight 起動対象外なので明示的に start する
      -- ファイル名の二重拡張子からホスト言語を推測して vim.b.gotmpl_host にセット
      local host_patterns = {
        -- 二重拡張子（content type を表す）
        { "%.html%.tmpl$", "html" },
        { "%.htm%.tmpl$",  "html" },
        { "%.ya?ml%.tmpl$", "yaml" },
        { "%.json%.tmpl$", "json" },
        -- chezmoi 系のファイル名（dot_xxx / private_xxx も拾えるよう [/_]）
        { "[/_]zshrc%.tmpl$", "bash" },
        { "[/_]zshenv%.tmpl$", "bash" },
        { "[/_]zprofile%.tmpl$", "bash" },
        { "[/_]bashrc%.tmpl$", "bash" },
        { "[/_]bash_profile%.tmpl$", "bash" },
        { "[/_]profile%.tmpl$", "bash" },
        { "[/_]Brewfile%.tmpl$", "ruby" },
      }
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "gotmpl",
        callback = function(args)
          local name = vim.api.nvim_buf_get_name(args.buf)
          for _, p in ipairs(host_patterns) do
            if name:match(p[1]) then
              vim.b[args.buf].gotmpl_host = p[2]
              break
            end
          end
          pcall(vim.treesitter.start, args.buf, "gotmpl")
        end,
      })    end,
}
