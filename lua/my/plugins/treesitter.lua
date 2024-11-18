return {
  { 'p00f/nvim-ts-rainbow' },

  -- matching bracket pairs
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function(_)
      -- matching pairs
      require('nvim-treesitter.configs').setup {
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        rainbow = {
          enable = true,
          extended_mode = true, -- Highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
          max_file_lines = nil, -- Do not enable for files with more than n lines, int
          colors = {
            '#68a0b0', -- Blue
            '#b4be82', -- Green
            '#dc8c34', -- Orange
            '#ff6c6b', -- Red
            '#c678dd', -- Purple
            '#e5c07b', -- Yellow
          },
        },
      }
    end,
  },
}
