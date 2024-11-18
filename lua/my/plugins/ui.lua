return {
  { -- this pretty black theme :)
    'bluz71/vim-moonfly-colors',
    name = 'moonfly',
    lazy = false,
    priority = 1000,
    config = function(_)
      vim.cmd 'colorscheme moonfly'
    end,
  },

  { -- indentation guides
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = { indent = { char = '▏' } },
  },

  { -- highlight colors in hex, rgb, etc. example: #bb55f0
    'norcalli/nvim-colorizer.lua',
    config = function(_)
      require('colorizer').setup()
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile' }, {
        command = 'ColorizerAttachToBuffer',
        group = vim.api.nvim_create_augroup(
          'my-colorizer-attach',
          { clear = true }
        ),
      })
    end,
  },

  { -- highlight TODO, FIXME, etc prefixes in comments
    'folke/todo-comments.nvim', -- NOTE: example!
    opts = { sign_priority = 5 },
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
}
