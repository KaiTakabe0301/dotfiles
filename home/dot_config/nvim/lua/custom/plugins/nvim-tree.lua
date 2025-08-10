return {
  "nvim-tree/nvim-tree.lua",
  opts = function(_, opts)
    -- on_attach関数でカスタムキーマッピングを設定
    local function my_on_attach(bufnr)
      local api = require("nvim-tree.api")
      
      local function opts(desc)
        return {
          desc = "nvim-tree: " .. desc,
          buffer = bufnr,
          noremap = true,
          silent = true,
          nowait = true
        }
      end
      
      -- デフォルトのマッピングを維持
      api.config.mappings.default_on_attach(bufnr)
      
      -- カスタムマッピング
      vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
      vim.keymap.set('n', 'h', api.node.open.horizontal, opts('Open: Horizontal Split'))
    end
    
    opts.on_attach = my_on_attach
    
    -- ウィンドウピッカーを無効化（分割がすぐに開くように）
    opts.actions = opts.actions or {}
    opts.actions.open_file = vim.tbl_extend("force",
      opts.actions.open_file or {},
      { 
        window_picker = { enable = false },
        quit_on_open = false  -- ファイルを開いてもnvim-treeを閉じない
      }
    )
    
    -- hijack_netrwを有効にして、空のバッファでnvim-treeが開くようにする
    opts.hijack_netrw = true
    opts.hijack_directories = {
      enable = true,
      auto_open = true,
    }
    
    return opts
  end,
}