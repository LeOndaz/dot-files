-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- consts
vim.opt.number = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.modifiable = true

-- builtin treesitter based folding, `:help fold-commands` for keybinds
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldtext = ''
vim.opt.foldenable = false

-- copied the maps from my config but changed the '+' buffer to '*', afaik this
-- is the sensible clipboard buffer in mac
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"*y', { desc = 'yank to clipboard' })
vim.keymap.set(
  { 'n', 'v' },
  '<leader>Y',
  '"*y$',
  { desc = 'yank to clipboard' }
)
vim.keymap.set(
  { 'n', 'v' },
  '<leader>p',
  '"*p',
  { desc = 'paste from clipboard' }
)
vim.keymap.set(
  { 'n', 'v' },
  '<leader>P',
  '"*P',
  { desc = 'paste from clipboard' }
)
vim.keymap.set(
  { 'n', 'v' },
  '<leader>d',
  '"_d',
  { desc = 'delete to the void' }
)
vim.keymap.set(
  { 'n', 'v' },
  '<leader>D',
  '"_D',
  { desc = 'delete to the void' }
)
vim.keymap.set(
  { 'n', 'v' },
  '<leader>c',
  '"_c',
  { desc = 'change to the void' }
)
vim.keymap.set(
  { 'n', 'v' },
  '<leader>C',
  '"_C',
  { desc = 'change to the void' }
)

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  callback = function()
    vim.highlight.on_yank()
  end,
  group = vim.api.nvim_create_augroup('my-highlight-yank', { clear = true }),
})

-- built in
--[[
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'help' }, -- non modifiable files
  callback = function()
    vim.bo.modifiable = false
  end,
})
]]

require 'my'
