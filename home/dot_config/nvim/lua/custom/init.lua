-- Custom initialization for NvChad
-- This file is loaded after NvChad's core init

-- Force base46 to recompile and apply theme changes
vim.schedule(function()
  -- Check if base46 is available
  local status_ok, base46 = pcall(require, "base46")
  if not status_ok then
    return
  end

  -- Compile themes with our custom colors
  base46.compile()

  -- Load all highlights including our changed_themes
  base46.load_all_highlights()

  -- Optionally, print a message to confirm recompilation
  -- vim.notify("Base46 theme recompiled with custom colors", vim.log.levels.INFO)
end)

-- どこか早めに読み込まれる init.lua / custom/init.lua などに
if vim.highlight and vim.highlight.priorities then
  local p = vim.highlight.priorities
  -- semantic_tokens を Treesitter より上に
  p.semantic_tokens = math.max((p.treesitter or 100) + 1, p.semantic_tokens or 95)
end