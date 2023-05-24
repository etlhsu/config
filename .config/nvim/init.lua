vim.opt.wildignore = { '*.git/*', '*/.hg/*', '*.DS_Store' } -- Ignore compiled files in wild
vim.opt.scrolloff = 20
vim.opt.number = true
vim.opt.colorcolumn = '100'
vim.opt.wrap = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.splitbelow = true
vim.opt.autowriteall = true
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.g.mapleader = ' '
vim.api.nvim_create_autocmd(
  {'InsertLeavePre', 'TextChanged'},
  { pattern = '*', command = 'silent! write'}
)

vim.g.netrw_browse_split = 4 -- Sticky window opens selected file in previous split
vim.g.netrw_winsize = 30
vim.g.netrw_banner = 0 -- Hide banner
vim.g.netrw_hide = 1
vim.g.netrw_list_hide = '^./$,^../$,.DS_Store' -- Hide annoying files

vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>')
vim.api.nvim_create_user_command('Ter', function()
		vim.cmd [[ below new | res 15 | startinsert | ter ]]
	end,
{})

vim.cmd.colorscheme('slate')
vim.cmd [[ 
  highlight Normal ctermfg=LightGrey 
	ab uenv #!/usr/bin/env
]]

function ShowTip(tipName)
	local tipPattern = vim.env.HOME .. '/.config/tip/.*.md'
	local buffers = vim.api.nvim_list_bufs()
	local tipBuffer = nil
	for _, buffer in ipairs(buffers) do
		local bufferName = vim.api.nvim_buf_get_name(buffer)
		if vim.api.nvim_buf_is_loaded(buffer) and string.gmatch(bufferName, tipPattern)() == nil then
			tipBuffer = buffer
		end
	end

	local regularTipLocation = vim.env.HOME .. '/.config/tip/' .. tipName .. '.md'
	local hiddenTipLocation = vim.env.HOME .. '/.config/tip/.' .. tipName .. '.md'
	local tipLocation = regularTipLocation
	if vim.fn.filereadable(hiddenTipLocation) then tipLocation = hiddenTipLocation end

	if not tipBuffer == nil then
		vim.api.nvim_set_current_buf(tipBuffer)
    vim.cmd('e ' .. tipLocation)
	else
    vim.cmd('below new ' .. tipLocation)
		vim.cmd('set nonumber | highlight EndOfBuffer ctermfg=bg guifg=bg')
	end
end

vim.api.nvim_create_user_command('Tip', function(opts) ShowTip(opts.args) end, {nargs = 1})
vim.api.nvim_create_user_command('T', function(opts) ShowTip(opts.args) end, {nargs = 1})

PrintLineCount = -1
PrintLineHeader = 'Ethan: '
function PrintLine(motion, content)
	local header = PrintLineHeader
  if PrintLineCount > -1 then
  	header = '(' .. PrintLineCount .. ') ' .. PrintLineHeader
		PrintLineCount  = PrintLineCount + 1
  end

	local filetype = vim.bo.filetype
	local message = ''
	if  filetype == 'kotlin' then
		message =  'println("' .. header .. content .. ': ${' .. content .. '}")'
	elseif filetype == 'java' then
		message = 'System.out.println("' .. header .. content .. ': " + (' .. content .. '));'
  end
	local escapeCode = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
	vim.api.nvim_feedkeys(motion .. message .. escapeCode, 'n', false)
end

vim.api.nvim_create_user_command('Pl', function(opts) PrintLine('o',opts.args) end, {nargs = '+'})
vim.api.nvim_create_user_command('Pla', function(opts) PrintLine('a',opts.args) end, {nargs = '+'})
vim.api.nvim_create_user_command('Plx', function(opts)
	local content = ''
	for index, arg in ipairs(opts.fargs) do
		if index > 1 then content = content .. arg end
	end
	PrintLine(opts.fargs[1], content)
end, {nargs = '+'})
vim.api.nvim_create_user_command('Plc', function(opts) 
	PrintLineCounter = opts.args
end, {nargs = 1})
vim.api.nvim_create_user_command('Plh', function(opts) 
	PrintLineHeader = opts.args 
end, {nargs = 1})

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'
  -- My plugins here
	use { 'nvim-telescope/telescope.nvim', tag = '0.1.1', requires = { {'nvim-lua/plenary.nvim'} } }
	use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

	use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
	use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
  use 'L3MON4D3/LuaSnip' -- Snippets plugin

	use 'udalov/kotlin-vim'
  use {
    'nvim-treesitter/nvim-treesitter',
      run = function()
        local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
        ts_update()
    end,
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.astro.setup {}
lspconfig.bashls.setup {
	filetypes = { 'sh', 'zsh' }
}
lspconfig.kotlin_language_server.setup {
	single_file_support = true,
}
lspconfig.lua_ls.setup {
	root_dir = lspconfig.util.root_pattern('.luarc.json', '.luarc.jsonc', '.luacheckrc',
    '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', vim.env.HOME .. '/.nvim/config'),
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file('', true),
				checkThirdParty = false, -- Prevent Luassert popup https://github.com/neovim/nvim-lspconfig/issues/1700
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

-- Add additional capabilities supported by nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    -- on_attach = my_custom_on_attach,
    capabilities = capabilities,
  }
end

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
    ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
    -- C-b (back) C-f (forward) for snippet placeholder navigation.
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}


require('nvim-treesitter.configs').setup {
  -- A list of parser names, or "all"
  ensure_installed = { 'astro', 'bash', 'css', 'cpp', 'html', 'java', 'json', 'kotlin', 'lua',
    'tsx', 'typescript', 'vimdoc'
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = false,

  highlight = {
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

vim.api.nvim_create_autocmd({'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter'}, {
  group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
  callback = function()
    vim.opt.foldmethod     = 'expr'
    vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
  end
})

vim.opt.foldenable = false
