return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
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
    routes = {
      {
        filter = {
          event = "notify",
          error = true,
        },
        view = "notify",
        opts = { timeout = false },
      },
    },
    presets = {
      command_palette = true,
    },
  },
}
