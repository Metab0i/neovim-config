-- Todo:
-- Git stuff
--  https://github.com/lewis6991/gitsigns.nvim?tab=readme-ov-file
--  Set-up display of total additions, deletions
--  Set-up a reliable diff view
--  Means of resolving merges
-- Debugger stuff
--  Look into it


-- Line numbering
vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 1

-- Cursor configs
vim.o.cursorline = true
vim.o.cursorlineopt = "number"
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FFFFFF", bold = true })
vim.opt.guicursor = {
  "n-c-v:block",
  "i-ci-ve:ver25",
  "r-cr:hor20",
  "v:block-blinkon500"
}

-- Spacing
vim.o.shiftwidth = 2
vim.o.softtabstop = 2

-- Fold 
vim.o.foldmethod = "indent"
vim.o.foldlevel = 99
vim.o.foldcolumn = "1"
vim.opt.fillchars:append {
  foldopen = "▾",
  foldclose = "▸",
  fold = " ",
  foldsep= " "
}

-- Key-bindings
vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
vim.keymap.set({'n'}, '<C-space>', vim.diagnostic.open_float, { desc = "Open Diagnostics at cursor" })


-- Status Line configs
function setStatusLine ()
  -- diagnostics info
  local diagnostics = vim.diagnostic.get(0)
  local count = { ERR = 0, WARN = 0 }

  for _, d in ipairs(diagnostics) do
    if d.severity == vim.diagnostic.severity.ERROR then
      count.ERR = count.ERR + 1
    elseif d.severity == vim.diagnostic.severity.WARN then
      count.WARN = count.WARN + 1
    end
  end

  -- lsp info
  local lsp_client = vim.lsp.get_clients({ bufnr = 0 })[1]
  local lspc_name = "No LSP"

  if lsp_client ~= nil and lsp_client.name ~= nil then
    lspc_name = lsp_client.name
  end

  vim.o.statusline = "%m %F | E:"..count.ERR.." W:"..count.WARN.." %= %y:"..lspc_name.." | %p%%"
end

setStatusLine()

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(_ev)
    setStatusLine()
  end
})

vim.api.nvim_create_autocmd('DiagnosticChanged', {
  callback = function(_ev)
    setStatusLine()
  end
})



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
    {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/vim-vsnip",
	"hrsh7th/cmp-vsnip",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"neovim/nvim-lspconfig",

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
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  view = {
    entries = 'custom',
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources(
  {
    { name = 'nvim_lsp', priority = 1000 },
    { name = 'vsnip', priority = 900 },
  }, 
  {
    { name = 'buffer', priority = 750 },
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

  sources = cmp.config.sources(
  {
    { name = 'path' }
  },
  {
    { name = 'cmdline' }
  }),

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
