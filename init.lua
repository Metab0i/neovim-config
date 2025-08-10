-- Todo:
--  Make cursor blink in visual mode
--  Make a diagnostic pop-up when hovering over something for 5 seconds or invoking a : or something similar..


-- Colorscheme
vim.cmd("colorscheme lunaperche")

-- Line numbering
vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 1
-- Cursor configs
vim.o.cursorline = true
vim.o.cursorlineopt = "number"
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#0246f1", bold = true })
vim.o.guicursor = "i:ver50,n-v-c:block,r-cr:hor25,o:hor50"

vim.o.shiftwidth = 2
vim.o.softtabstop = 2

-- Miscelaneous
vim.o.foldmethod = "indent"
vim.o.foldlevel = 99
vim.o.foldcolumn = "1"
vim.opt.fillchars:append {
  foldopen = "▾",
  foldclose = "▸",
  fold = " ",
  foldsep= " "
}



-- Status Line configs
-- Create an event-ish system that has 2 events
--  1. on attached - shows LSP info 
--  2. default - doesn't show LSP info, only file extension
--    How to do this, look at syntax of how function members of a table are defined in lua
local lsp_client
local lspc_name = "No LSP"

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    lsp_client = vim.lsp.get_client_by_id(ev.data.client_id)

    if lsp_client ~= nil and lsp_client.name ~= nil then
      lspc_name = lsp_client.name
    end

    vim.o.statusline = "%m %f %= %y:" .. lspc_name .. " | %p%%"

  end
})




-- Diagnostic and errors floats
-- vim.diagnostic.open_float() whilst hovering over a section






-- Lazy.nvim

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

-- Plugins List & Lazy.nvim Set-up
require("lazy").setup({
  spec = {
    -- add your plugins here
    {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/vim-vsnip",
	"hrsh7th/cmp-vsnip",
	"neovim/nvim-lspconfig"
      }
    },

    {
      "folke/neodev.nvim",
      opts = {}
    },
  },

  -- Other settings here

  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})



-- nvim-cmp
local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)

      -- For `mini.snippets` users:
      -- local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
      -- insert({ body = args.body }) -- Insert at cursor
      -- cmp.resubscribe({ "TextChangedI", "TextChangedP" })
      -- require("cmp.config").set_onetime({ sources = {} })
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})



-- LSP server Set-up
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lsp-configs
vim.lsp.enable('clangd')
vim.lsp.enable('lua_ls') -- https://luals.github.io/#neovim-install
vim.lsp.enable('ts_ls')

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require("neodev").setup({})
local lspconfig = require('lspconfig')

lspconfig.clangd.setup({
  cmd = {'clangd', '--background-index', '--clang-tidy', '--log=verbose'},
  init_options = {
    fallbackFlags = { '-std=c++17' },
  },
  capabilities = capabilities,
})

lspconfig.eslint.setup({
  capabilities = capabilities,
})

lspconfig.ts_ls.setup({
  capabilities = capabilities,
})

lspconfig.lua_ls.setup({
  capabilities = capabilities,
})
