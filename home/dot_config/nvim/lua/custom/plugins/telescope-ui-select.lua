return {
  "nvim-telescope/telescope-ui-select.nvim",
  lazy = false,
  priority = 100,
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    local open_multi_or_default = function(prompt_bufnr)
      local actions = require("telescope.actions")
      local state = require("telescope.actions.state")
      local picker = state.get_current_picker(prompt_bufnr)
      local multi = picker:get_multi_selection()
      if #multi > 0 then
        actions.close(prompt_bufnr)
        for _, entry in ipairs(multi) do
          if entry.path or entry.filename then
            vim.cmd("edit " .. vim.fn.fnameescape(entry.path or entry.filename))
          end
        end
      else
        actions.select_default(prompt_bufnr)
      end
    end

    local send_selected_to_qf = function(prompt_bufnr)
      local actions = require("telescope.actions")
      actions.send_selected_to_qflist(prompt_bufnr)
      actions.open_qflist(prompt_bufnr)
    end

    require("telescope").setup({
      defaults = {
        mappings = {
          i = {
            ["<CR>"] = open_multi_or_default,
            ["<M-q>"] = send_selected_to_qf,
          },
          n = {
            ["<CR>"] = open_multi_or_default,
            ["<M-q>"] = send_selected_to_qf,
          },
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
    })
    require("telescope").load_extension("ui-select")
  end,
}
