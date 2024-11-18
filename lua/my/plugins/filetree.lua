return {
  'nvim-tree/nvim-tree.lua',
  requires = 'nvim-tree/nvim-web-devicons',
  config = function(_)
    local nvtree = require 'nvim-tree'
    local nvtree_api = require 'nvim-tree.api'

    -- projecvt view #api => https://github.com/nvim-tree/nvim-tree.lua/blob/master/doc/nvim-tree-lua.txt
    nvtree.setup {
      -- Add any additional configuration options here
      view = {
        width = 30,
        side = 'left',
      },
      filters = {
        dotfiles = false,
        custom = { '.git' },
      },
      on_attach = function(bufnr)
        -- delete button deletes current file
        vim.keymap.set(
          'n',
          '<leader>d',
          nvtree_api.fs.remove,
          { buffer = bufnr, desc = 'Delete file' }
        )

        -- Custom keybinding for the right arrow key
        vim.keymap.set('n', '<Right>', function()
          local node = nvtree_api.tree.get_node_under_cursor()
          if node then
            nvtree_api.node.open.edit()
          end
        end, {
          buffer = bufnr,
          desc = 'Handle right arrow key in nvim-tree',
        })
      end,
    }

    -- Function to open nvim-tree
    local function open_nvim_tree()
      nvtree_api.tree.open()
    end

    -- Automatically open nvim-tree when Neovim starts
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = open_nvim_tree,
    })

    -- Autocmd to set modifiable to true in NvimTree buffer
    vim.api.nvim_create_autocmd('BufWinEnter', {
      pattern = 'NvimTree_*',
      callback = function()
        vim.bo.modifiable = true
      end,
    })

    -- open tree with F2
    vim.api.nvim_set_keymap(
      'n',
      '<F2>',
      ':NvimTreeFocus<CR>',
      { noremap = true, silent = true }
    )
  end,
}
