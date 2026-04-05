return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        yaml = true,
      },
    },
  },
  {
    "zbirenbaum/copilot-cmp",
    event = { "InsertEnter", "LspAttach" },
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      -- Neovim 0.11 で client.is_stopped() がメソッドに変更されたため、
      -- copilot-cmp の source.lua をモンキーパッチして互換性を保つ
      local source = require("copilot_cmp.source")
      local original_is_available = source.is_available
      source.is_available = function(self)
        if self.client then
          local stopped = type(self.client.is_stopped) == "function"
            and self.client:is_stopped()
            or false
          if stopped or self.client.name ~= "copilot" then
            return false
          end
          local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
          return next(get_clients({
            bufnr = vim.api.nvim_get_current_buf(),
            id = self.client.id,
          })) ~= nil
        end
        return original_is_available(self)
      end
      require("copilot_cmp").setup()
    end,
  },
}
