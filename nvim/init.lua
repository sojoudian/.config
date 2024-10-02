-- Packer for managing plugins
require 'packer'.startup(function(use)
  use 'wbthomason/packer.nvim'         -- Packer itself

  -- LSP and Autocompletion
  use 'neovim/nvim-lspconfig'          -- LSP configurations
  use 'hrsh7th/nvim-cmp'               -- Completion framework
  use 'hrsh7th/cmp-nvim-lsp'           -- LSP source for nvim-cmp
  use 'L3MON4D3/LuaSnip'               -- Snippet engine
  use 'saadparwaiz1/cmp_luasnip'       -- Snippet completions

  -- LSP Installers
  use 'williamboman/mason.nvim'        -- Manage LSP servers
  use 'williamboman/mason-lspconfig.nvim'

  -- Treesitter for syntax highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- Linters and Formatters
  use 'jose-elias-alvarez/null-ls.nvim' -- Linters and formatters
  use 'jayp0521/mason-null-ls.nvim'     -- Integrates with mason

  -- Auto-pairs for automatic closing brackets
  use 'windwp/nvim-autopairs'

  -- File explorer
  use 'kyazdani42/nvim-tree.lua'

  -- Telescope for fuzzy finding
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  -- Git integration
  use 'tpope/vim-fugitive'
  use 'lewis6991/gitsigns.nvim'

  -- Statusline
  use 'nvim-lualine/lualine.nvim'

  -- Terminal integration
  use 'akinsho/toggleterm.nvim'
end)

-- Mason setup for managing LSPs, linters, and formatters
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "gopls", "rust_analyzer", "pyright", "html", "cssls", "ts_ls",   -- Replaced tsserver with ts_ls
    "bashls", "ansiblels", "terraformls"
  }
})

-- LSP Configurations
local lspconfig = require("lspconfig")

local on_attach = function(_, bufnr)
  local opts = { noremap = true, silent = true }
  local buf_set_keymap = function(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
end

-- Enable LSP servers
local servers = { "gopls", "rust_analyzer", "pyright", "html", "cssls", "ts_ls", "bashls", "ansiblels", "terraformls" }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

-- Completion Setup
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require('luasnip').expand_or_jumpable() then
        require('luasnip').expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif require('luasnip').jumpable(-1) then
        require('luasnip').jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<C-y>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item
    ['<C-e>'] = cmp.mapping.close(),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }
})

-- Treesitter Configuration
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "go", "rust", "python", "html", "css", "javascript", "bash", "terraform", "yaml" },
  highlight = {
    enable = true,
  },
}

-- Null-ls setup for formatting and linting
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier.with({
      filetypes = { "html", "css", "javascript" },
    }),
    null_ls.builtins.formatting.gofmt,
    null_ls.builtins.formatting.rustfmt,
    null_ls.builtins.formatting.black,
    null_ls.builtins.diagnostics.shellcheck,
  },
})

-- Autopairs Setup
require('nvim-autopairs').setup{}

-- Nvim Tree Configuration
require'nvim-tree'.setup {}

-- Lualine Configuration
require'lualine'.setup {
  options = {
    theme = 'gruvbox',
    section_separators = '',
    component_separators = ''
  }
}

-- Telescope Configuration
require('telescope').setup {
  defaults = {
    file_ignore_patterns = {"node_modules"}
  }
}

-- Terminal toggle setup
require("toggleterm").setup {
  open_mapping = [[<c-\>]],
  direction = 'float',
}

-- Additional Keybindings
vim.api.nvim_set_keymap('n', '<C-p>', ':Telescope find_files<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>tt', ':ToggleTerm<CR>', { noremap = true })
