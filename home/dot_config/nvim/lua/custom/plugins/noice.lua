return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
    },
    popupmenu = {
      enabled = true,
      backend = "cmp",
    },
    views = {
      cmdline_popup = {
        position = {
          row = "50%",
          col = "50%",
        },
      },
    },
    lsp = {
      signature = { enabled = false },
      hover = { enabled = false },
      progress = { enabled = false },
    },
    presets = {
      command_palette = true,
    },
  },
}
