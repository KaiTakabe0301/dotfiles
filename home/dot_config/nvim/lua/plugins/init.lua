return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    opts = require "configs.conform",
  },

  -- Load all custom plugins
  require("custom.plugins"),
}