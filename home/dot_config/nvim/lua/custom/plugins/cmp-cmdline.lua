return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/cmp-cmdline",
    "zbirenbaum/copilot-cmp",
  },
  config = function(_, opts)
    local cmp = require "cmp"
    local compare = require "cmp.config.compare"
    local copilot_cmp_comparators = require "copilot_cmp.comparators"

    -- copilot ソースを追加
    opts.sources = opts.sources or {}
    table.insert(opts.sources, { name = "copilot", group_index = 2 })

    -- sorting に copilot prioritize を先頭に追加
    opts.sorting = opts.sorting or {}
    opts.sorting.comparators = {
      copilot_cmp_comparators.prioritize,
      compare.offset,
      compare.exact,
      compare.score,
      compare.recently_used,
      compare.locality,
      compare.kind,
      compare.length,
      compare.order,
    }

    -- NvChad デフォルトの cmp 設定を先に適用
    cmp.setup(opts)

    -- その後に cmdline 補完を設定
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
    })

    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })
  end,
}
