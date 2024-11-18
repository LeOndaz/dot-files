return {
  {
    'neovim/nvim-lspconfig',
    config = function(_)
      local capabilities = require('cmp_nvim_lsp').default_capabilities(
        vim.lsp.protocol.make_client_capabilities()
      )
      local lspconfig = require 'lspconfig'

      lspconfig.pylsp.setup {
        capabilities = capabilities,
        cmd = { 'pylsp' },
        root_dir = function()
          return vim.fn.getcwd()
        end,
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = { enabled = false }, -- Disable pycodestyle as ruff covers it
              pyflakes = { enabled = false }, -- Disable pyflakes as ruff covers it
              mccabe = { enabled = false }, -- Disable mccabe as ruff covers it
              ruff = { enabled = true },
              isort = { enabled = true },
            },
          },
        },
      }

      lspconfig.terraformls.setup {}
      vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
        pattern = { '*.tf', '*.tfvars' },
        callback = function()
          vim.lsp.buf.format()
        end,
      })
    end,
  },

  -- fuzzy search and completions
  { 'junegunn/fzf', run = './install --all' },
  { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  {
    'tzachar/fuzzy.nvim',
    requires = { 'nvim-telescope/telescope-fzf-native.nvim' },
  },
  { 'tzachar/cmp-fuzzy-path' },

  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-cmdline' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'L3MON4D3/LuaSnip' },
      { 'rafamadriz/friendly-snippets' },
      { 'onsails/lspkind-nvim' }, -- show docs
    },
    config = function(_)
      -- Setup nvim-cmp
      local cmp = require 'cmp'
      local lspkind = require 'lspkind'
      local luasnip = require 'luasnip'

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm { select = true }, -- Enter
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<Down>'] = cmp.mapping.select_next_item(), -- Arrow Down
          ['<Up>'] = cmp.mapping.select_prev_item(), -- Arrow Up
          ['<Left>'] = cmp.mapping.abort(), -- Arrow Left
          ['<Right>'] = cmp.mapping.confirm { select = true }, -- Arrow Right
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'fuzzy_path' },
          { name = 'path', keyword_length = 3, priority = 100 }, -- Fuzzy path completions
        }, {
          { name = 'buffer' },
        }),
        window = {
          documentation = {
            winhighlight = 'NormalFloat:NormalFloat,FloatBorder:TelescopeBorder',
          },
        },
        formatting = {
          format = lspkind.cmp_format { -- Use lspkind for formatting
            with_text = true, -- Show text alongside icons
            menu = {
              buffer = '[Buffer]',
              nvim_lsp = '[LSP]',
              luasnip = '[LuaSnip]',
              nvim_lua = '[Lua]',
              latex_symbols = '[Latex]',
            },
          },
        },
        completion = {
          completeopt = 'menu,menuone,noselect',
        },
      }
    end,
  },

  -- project view
  {
    'ahmedkhalf/project.nvim',
    config = function(_)
      -- Project workspaces
      local project = require 'project_nvim'

      project.setup {
        -- Set the directory where the project is located
        manual_mode = true, -- Use manual project detection
        detection_methods = { 'lsp', 'pattern' },

        -- what makes a project a project
        patterns = {
          '.git',
          'Makefile',
          'package.json',
          'Cargo.toml',
          'pyproject.toml',
          'requirements.txt',
        },
      }
    end,
  },

  -- format lua
  {
    'ckipp01/stylua-nvim',
    config = function(_)
      -- Initialize stylua
      local stylua = require 'stylua-nvim'

      -- Auto-format Lua files on save
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.lua',
        callback = function()
          stylua.format_file()
        end,
      })
    end,
  },

  {
    'python-lsp/python-lsp-server',
    build = "python3 -m pip install python-lsp-server 'python-lsp-server[all]' ruff isort",
  },
}
