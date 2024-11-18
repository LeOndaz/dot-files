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
}
