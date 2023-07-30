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

vim.g.netrw_browse_split = 4 -- Sticky window opens selected file in previous split
vim.g.netrw_winsize = 20
vim.g.netrw_banner = 0 -- Hide banner
vim.g.netrw_hide = 1
vim.g.netrw_list_hide = '^./$,^../$,.DS_Store' -- Hide annoying files

vim.keymap.set({'n','v','s','o','i','c'}, '<C-k>', '<C-w>')
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>')
vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>')
vim.api.nvim_create_autocmd(
  {'InsertLeavePre', 'TextChanged'},
  { pattern = '*', command = 'silent! write'}
)
vim.api.nvim_create_user_command('Ter', function()
		vim.cmd([[ bot new | res 15 | set wfh | startinsert | ter ]])
	end,
{})
vim.api.nvim_create_user_command('Soi', function()
		vim.cmd([[source ~/.config/nvim/init.lua]])
	end,
{})
vim.api.nvim_create_user_command('Note', function()
		vim.cmd([[tabnew | e ~/personal/note.md]])
	end,
{})

vim.cmd.colorscheme('slate')
vim.cmd([[ 
  highlight Normal ctermfg=LightGrey 
	ab uenv #!/usr/bin/env
]])

function ShowDoc(docName)
  local docPath = vim.env.HOME .. '/docs'
	local docPattern = docPath .. '/.*.md'
  
	local buffers = vim.api.nvim_list_bufs()
	local docBuffer = nil
	for _, buffer in ipairs(buffers) do
		local bufferName = vim.api.nvim_buf_get_name(buffer)
		if vim.api.nvim_buf_is_loaded(buffer) and string.gmatch(bufferName, docPattern)() == nil then
			docBuffer = buffer
		end
	end

	local regularDocLocation = docPath .. '/' .. docName .. '.md'
	local hiddenDocLocation = docPath .. '/.' .. docName .. '.md'
	local docLocation = regularDocLocation
	if vim.fn.filereadable(hiddenDocLocation) == false then docLocation = hiddenDocLocation end
  print(docLocation)

	if not docBuffer == nil then
		vim.api.nvim_set_current_buf(docBuffer)
    vim.cmd('e ' .. docLocation)
	else
    vim.cmd('below new ' .. docLocation)
		vim.cmd('set nonumber | highlight EndOfBuffer ctermfg=bg guifg=bg')
	end
end

vim.api.nvim_create_user_command('Doc', function(opts) ShowDoc(opts.args) end, {nargs = 1})
vim.api.nvim_create_user_command('D', function(opts) ShowDoc(opts.args) end, {nargs = 1})

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

require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	use { 'nvim-telescope/telescope.nvim', tag = '0.1.2', requires = { {'nvim-lua/plenary.nvim'} } }
  use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate'})
  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    requires = {
      {'neovim/nvim-lspconfig'}, {'hrsh7th/nvim-cmp'}, {'hrsh7th/cmp-nvim-lsp'}, {'L3MON4D3/LuaSnip'},
    }
  }
	use 'udalov/kotlin-vim'
end)

require('telescope').setup{
  defaults = {
    layout_config = {
      preview_width = 0.42,
    },
  },
}
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files)
vim.keymap.set('n', '<leader>ff', function() builtin.find_files({find_command = {'rg', '--files', '--no-ignore-vcs',}}) end)
vim.keymap.set('n', '<leader>fg', builtin.live_grep)
vim.keymap.set('n', '<leader>fb', builtin.buffers)
vim.keymap.set('n', '<leader>fh', builtin.help_tags)
vim.keymap.set('n', '<leader>fo', builtin.oldfiles)

require('nvim-treesitter.configs').setup {
  -- A list of parser names, or "all"
  ensure_installed = { 'astro', 'bash', 'css', 'cpp', 'html', 'java', 'json', 'kotlin', 'lua',
    'tsx', 'typescript', 'vimdoc'
  },
  highlight = { enable = true },
}

local lsp = require('lsp-zero').preset({})
lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})  -- see :help lsp-zero-keybindings for keymaps
end)
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
lsp.setup_servers({'astro','bashls','kotlin_language_server','lua_ls'})
-- (Optional) Configure lua language server for neovim
local lspconfig = require('lspconfig')
lspconfig.lua_ls.setup(lsp.nvim_lua_ls({
  root_dir = lspconfig.util.root_pattern('.luarc.json', vim.env.HOME .. '/.nvim/config'),
}))
local cmp = require('cmp')
lsp.setup_nvim_cmp({
    mapping = {
      ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ["<C-y>"] = cmp.mapping.confirm({ select = true }),
      ["<C-space>"] = cmp.mapping.complete(),
    }
  })
lsp.setup()
