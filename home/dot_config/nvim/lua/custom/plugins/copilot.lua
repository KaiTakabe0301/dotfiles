return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    keys = {
      { "<leader>at", "<cmd>Copilot toggle<cr>", desc = "Copilot toggle" },
      { "<leader>as", "<cmd>Copilot status<cr>", desc = "Copilot status" },
      { "<leader>ap", "<cmd>Copilot panel<cr>", desc = "Copilot panel" },
    },
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = false,
        hide_during_completion = true,
        keymap = {
          accept = "<M-y>",
          next = "<M-c>",
          prev = "<M-p>",
          dismiss = "<M-d>",
        },
      },
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
