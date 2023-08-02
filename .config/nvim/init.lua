vim.opt.wildignore = { '*.git/*', '*/.hg/*', '*.DS_Store' } -- Ignore compiled files in wild
vim.opt.scrolloff = 20; vim.opt.number = true; vim.opt.colorcolumn = '100'
vim.opt.wrap = true; vim.opt.tabstop = 2; vim.opt.shiftwidth = 2; vim.opt.smartindent = true; vim.opt.expandtab = true
vim.opt.splitbelow = true
vim.opt.autowriteall = true; vim.opt.undofile = true; vim.opt.swapfile = false; vim.opt.backup = false; vim.opt.writebackup = false
vim.g.mapleader = ' '
vim.g.netrw_browse_split = 4; vim.g.netrw_winsize = 20; vim.g.netrw_banner = 0; vim.g.netrw_hide = 1; vim.g.netrw_list_hide = '^./$,^../$,.DS_Store'

vim.keymap.set({'n','v','s','o','i','c'}, '<C-k>', '<C-w>')
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>'); vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>')
vim.keymap.set({'n', 'v', 'o'}, '<C-f>', ':<C-f>'); vim.keymap.set('i', '<C-f>', '<ESC>:<C-f>')

vim.cmd.colorscheme('slate')
vim.cmd([[ highlight Normal ctermfg=LightGrey | ab uenv #!/usr/bin/env ]])
vim.api.nvim_create_autocmd( {'FocusGained', 'BufEnter'}, {
    pattern = '*', callback = function() if vim.fn.getcmdwintype() == "" then vim.cmd([[checktime]]) end end
  })
vim.api.nvim_create_autocmd( {'Insertleavepre', 'Textchanged'}, {
  pattern = '*', callback = function() if vim.fn.getcmdwintype() == "" then vim.cmd([[silent! write]]) end end
  })
vim.api.nvim_create_user_command('Ter', function() vim.cmd([[ bot new | res 15 | set wfh | startinsert | ter ]]) end, {})
vim.api.nvim_create_user_command('Soi', function() vim.cmd([[source ~/.config/nvim/init.lua]]) end, {})
vim.api.nvim_create_user_command('Note', function() vim.cmd([[tabnew | e ~/personal/note.md]]) end, {})

-- Loading plugins
local hasTelescopeBuiltin,builtin = pcall(require,'telescope.builtin')
local hasTreesitterConfigs,treesitterConfigs = pcall(require,'nvim-treesitter.configs')
local hasLspZero,lspZero = pcall(require,'lsp-zero')
local hasLspConfig,lspconfig = pcall(require,'lspconfig')
local hasCmp,cmp = pcall(require,'cmp')

if hasTelescopeBuiltin then
  vim.keymap.set('n', '<C-p>', builtin.find_files)
  vim.keymap.set('n', '<leader>ff', function() builtin.find_files({find_command = {'rg', '--files', '--no-ignore-vcs',}}) end)
  vim.keymap.set('n', '<leader>fg', builtin.live_grep)
  vim.keymap.set('n', '<leader>fb', builtin.buffers)
  vim.keymap.set('n', '<leader>fh', builtin.help_tags)
  vim.keymap.set('n', '<leader>fo', builtin.oldfiles)
end

if hasTreesitterConfigs then treesitterConfigs.setup {
    ensure_installed = { 'astro', 'bash', 'css', 'cpp', 'html', 'java', 'json', 'kotlin', 'lua', 'tsx', 'typescript', 'vimdoc' },
    highlight = { enable = true }, }
end

if hasLspZero and hasLspConfig and hasCmp then
  local lsp = lspZero.preset({})
  lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({buffer = bufnr})  -- see :help lsp-zero-keybindings for keymaps
  end)
  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  lsp.setup_servers({'astro','bashls','kotlin_language_server','lua_ls'})
  -- (Optional) Configure lua language server for neovim
  lspconfig.lua_ls.setup(lsp.nvim_lua_ls({ root_dir = lspconfig.util.root_pattern('.luarc.json', vim.env.HOME .. '/.nvim/config'), }))
  lsp.setup_nvim_cmp({
      mapping = {
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<C-space>"] = cmp.mapping.complete(),
      }
    })
  lsp.setup()
end
