-- Helper script to force recompile base46 themes
-- Run this with :lua require("custom.recompile-theme").recompile()

local M = {}

M.recompile = function()
  -- Clear existing cache
  local cache_dir = vim.fn.stdpath("data") .. "/base46"
  if vim.fn.isdirectory(cache_dir) == 1 then
    vim.fn.system("rm -rf " .. cache_dir .. "/*")
    vim.notify("Base46 cache cleared", vim.log.levels.INFO)
  end
  
  -- Recompile
  local status_ok, base46 = pcall(require, "base46")
  if status_ok then
    base46.compile()
    base46.load_all_highlights()
    vim.notify("Base46 theme recompiled successfully!", vim.log.levels.INFO)
  else
    vim.notify("Failed to load base46", vim.log.levels.ERROR)
  end
end

return M