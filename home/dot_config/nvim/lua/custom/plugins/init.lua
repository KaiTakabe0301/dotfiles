-- Custom plugins initialization

-- Load custom init script
vim.schedule(function()
  local init_path = vim.fn.stdpath("config") .. "/lua/custom/init.lua"
  if vim.fn.filereadable(init_path) == 1 then
    dofile(init_path)
  end
end)

return {
  require("custom.plugins.mason-lspconfig"),

  require("custom.plugins.nvim-vtsls"),

  require("custom.plugins.nvim-treesitter"),

  require("custom.plugins.none-ls"),

  require("custom.plugins.lazygit-nvim"),

  require("custom.plugins.indent-blankline"),

  require("custom.plugins.hlchunk"),

  require("custom.plugins.rainbow-delimiters"),
}
