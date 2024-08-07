-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- consts
vim.opt.number = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.modifiable = true

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "help" }, -- non modifiable files
	callback = function()
		vim.bo.modifiable = false
	end,
})

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{ "neovim/nvim-lspconfig" },
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-path" },
		{ "hrsh7th/cmp-cmdline" },
		{ "saadparwaiz1/cmp_luasnip" },
		{ "L3MON4D3/LuaSnip" },
		{ "rafamadriz/friendly-snippets" },

		-- fuzzy search and completions
		{ "junegunn/fzf", run = "./install --all" },
		{ "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
		{ "tzachar/fuzzy.nvim", requires = { "nvim-telescope/telescope-fzf-native.nvim" } },
		{ "tzachar/cmp-fuzzy-path" },

		-- project view
		{ "ahmedkhalf/project.nvim" },
		{ "nvim-tree/nvim-tree.lua", requires = "nvim-tree/nvim-web-devicons" },

		-- show docs
		{ "onsails/lspkind-nvim" },

		-- format lua
		{ "ckipp01/stylua-nvim" },

		-- matching bracket pairs
		{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
		{ "p00f/nvim-ts-rainbow" },

		{
			"python-lsp/python-lsp-server",
			build = "python3 -m pip install python-lsp-server 'python-lsp-server[all]' ruff isort",
		},
	},

	-- automatically check for plugin updates
	checker = { enabled = true },
})

-- Setup nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")

-- Setup nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = {
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enter
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
		["<Down>"] = cmp.mapping.select_next_item(), -- Arrow Down
		["<Up>"] = cmp.mapping.select_prev_item(), -- Arrow Up
		["<Left>"] = cmp.mapping.abort(), -- Arrow Left
		["<Right>"] = cmp.mapping.confirm({ select = true }), -- Arrow Right
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "fuzzy_path" },
		{ name = "path", keyword_length = 3, priority = 100 }, -- Fuzzy path completions
	}, {
		{ name = "buffer" },
	}),
	window = {
		documentation = {
			winhighlight = "NormalFloat:NormalFloat,FloatBorder:TelescopeBorder",
		},
	},
	formatting = {
		format = lspkind.cmp_format({ -- Use lspkind for formatting
			with_text = true, -- Show text alongside icons
			menu = {
				buffer = "[Buffer]",
				nvim_lsp = "[LSP]",
				luasnip = "[LuaSnip]",
				nvim_lua = "[Lua]",
				latex_symbols = "[Latex]",
			},
		}),
	},
	completion = {
		completeopt = "menu,menuone,noselect",
	},
})

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

lspconfig.pylsp.setup({
	capabilities = capabilities,
	cmd = { "pylsp" },
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
})

lspconfig.terraformls.setup({})
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	pattern = { "*.tf", "*.tfvars" },
	callback = function()
		vim.lsp.buf.format()
	end,
})

-- Initialize stylua
local stylua = require("stylua-nvim")

-- Auto-format Lua files on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.lua",
	callback = function()
		stylua.format_file()
	end,
})

-- Project workspaces
local project = require("project_nvim")

project.setup({
	-- Set the directory where the project is located
	manual_mode = true, -- Use manual project detection
	detection_methods = { "lsp", "pattern" },

	-- what makes a project a project
	patterns = { ".git", "Makefile", "package.json", "Cargo.toml", "pyproject.toml", "requirements.txt" },
})

local nvtree = require("nvim-tree")
local nvtree_api = require("nvim-tree.api")

-- projecvt view #api => https://github.com/nvim-tree/nvim-tree.lua/blob/master/doc/nvim-tree-lua.txt
nvtree.setup({
	-- Add any additional configuration options here
	view = {
		width = 30,
		side = "left",
	},
	filters = {
		dotfiles = false,
		custom = { ".git" },
	},
	on_attach = function(bufnr)
		-- delete button deletes current file
		vim.keymap.set("n", "<leader>d", nvtree_api.fs.remove, { buffer = bufnr, desc = "Delete file" })

		-- Custom keybinding for the right arrow key
		vim.keymap.set("n", "<Right>", function()
			local node = nvtree_api.tree.get_node_under_cursor()
			if node then
				nvtree_api.node.open.edit()
			end
		end, { buffer = bufnr, desc = "Handle right arrow key in nvim-tree" })
	end,
})

-- Function to open nvim-tree
local function open_nvim_tree()
	nvtree_api.tree.open()
end

-- Automatically open nvim-tree when Neovim starts
vim.api.nvim_create_autocmd("VimEnter", {
	callback = open_nvim_tree,
})

-- Autocmd to set modifiable to true in NvimTree buffer
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "NvimTree_*",
	callback = function()
		vim.bo.modifiable = true
	end,
})

-- open tree with F2
vim.api.nvim_set_keymap("n", "<F2>", ":NvimTreeFocus<CR>", { noremap = true, silent = true })

-- matching pairs
require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	rainbow = {
		enable = true,
		extended_mode = true, -- Highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = nil, -- Do not enable for files with more than n lines, int
		colors = {
			"#68a0b0", -- Blue
			"#b4be82", -- Green
			"#dc8c34", -- Orange
			"#ff6c6b", -- Red
			"#c678dd", -- Purple
			"#e5c07b", -- Yellow
		},
	},
})

vim.cmd([[syntax on]])
