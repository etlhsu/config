vim.opt.wildignore = { '*.git/*', '*/.hg/*', '*.DS_Store' }; vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'noinsert' }
vim.opt.scrolloff = 20; vim.opt.number = true; vim.opt.colorcolumn = '100'
vim.opt.wrap = true; vim.opt.tabstop = 2; vim.opt.shiftwidth = 2; vim.opt.smartindent = true; vim.opt.expandtab = true
vim.opt.splitbelow = true
vim.opt.autowriteall = true; vim.opt.undofile = true; vim.opt.swapfile = false; vim.opt.backup = false; vim.opt.writebackup = false
vim.g.mapleader = ' '
vim.g.netrw_browse_split = 4; vim.g.netrw_winsize = 20; vim.g.netrw_banner = 0; vim.g.netrw_hide = 1; vim.g.netrw_list_hide =
'^./$,^../$,.DS_Store';
vim.keymap.set({ 'n', 'v', 's', 'o', 'i', 'c' }, '<C-k>', '<C-w>')
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>'); vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>')
vim.keymap.set({ 'n', 'v', 'o' }, '<C-f>', ':<C-f>'); vim.keymap.set('i', '<C-f>', '<ESC>:<C-f>')

vim.cmd.colorscheme('slate')
vim.cmd([[ highlight Normal ctermfg=LightGrey | ab uenv #!/usr/bin/env ]])
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  pattern = '*', callback = function() if vim.fn.getcmdwintype() == "" then vim.cmd([[checktime]]) end end
})
vim.api.nvim_create_autocmd({ 'InsertLeavePre', 'TextChanged' }, {
  pattern = '*', callback = function() if vim.fn.getcmdwintype() == "" then vim.cmd([[silent! write]]) end end
})
vim.api.nvim_create_autocmd({ 'InsertCharPre'}, {
  pattern = '*', callback = function() if vim.fn.pumvisible() == 0 and vim.fn.getcmdwintype() == '' and
    ((vim.v.char >= 'a' and vim.v.char <= 'z') or (vim.v.char >= 'A' and vim.v.char <= 'Z') or vim.v.char == '.') then
        vim.api.nvim_input(vim.api.nvim_replace_termcodes("<C-x><C-o>", true,false,true))
    end end
})
vim.api.nvim_create_user_command('Ter', function() vim.cmd([[ bot new | res 15 | set wfh | startinsert | ter ]]) end, {})
vim.api.nvim_create_user_command('Soi', function() vim.cmd([[source ~/.config/nvim/init.lua]]) end, {})
vim.api.nvim_create_user_command('Note', function() vim.cmd([[tabnew | e ~/personal/note.md]]) end, {})

-- Loading plugins
local hasTelescopeBuiltin, builtin = pcall(require, 'telescope.builtin')
local hasTreesitterConfigs, treesitterConfigs = pcall(require, 'nvim-treesitter.configs')

if hasTelescopeBuiltin then
  vim.keymap.set('n', '<C-p>', builtin.find_files)
  vim.keymap.set('n', '<leader>ff',
    function() builtin.find_files({ find_command = { 'rg', '--files', '--no-ignore-vcs', } }) end)
  vim.keymap.set('n', '<leader>fg', builtin.live_grep)
  vim.keymap.set('n', '<leader>fb', builtin.buffers)
  vim.keymap.set('n', '<leader>fh', builtin.help_tags)
  vim.keymap.set('n', '<leader>fo', builtin.oldfiles)
end

if hasTreesitterConfigs then
  treesitterConfigs.setup {
    ensure_installed = { 'astro', 'bash', 'css', 'cpp', 'html', 'java', 'json', 'kotlin', 'lua', 'tsx', 'typescript',
      'vimdoc' },
    highlight = { enable = true }, }
end

function LspAutocmd(pattern, client_cmd, root_dir_files, settings)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = pattern,
    callback = function()
      local client = vim.lsp.start({
        name = client_cmd,
        cmd = { client_cmd },
        root_dir = vim.fs.dirname(vim.fs.find(root_dir_files, { upward = true })[1]),
        settings = settings,
      })
      vim.lsp.buf_attach_client(0, client)
    end
  })
end

LspAutocmd('lua', 'lua-language-server', { '.config/nvim' }, {
  Lua = {
    runtime = { version = 'LuaJIT', },
    diagnostics = { globals = { 'vim' }, },
    workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
    telemetry = { enable = false, },
  }
})
LspAutocmd('kotlin', 'kotlin-language-server', { 'build.gradle', 'build.gradle.kts' })

local keymaps = { { 'gd', vim.lsp.buf.definition }, { 'gD', vim.lsp.buf.declaration },
  { 'gi', vim.lsp.buf.implementation },
  { 'go', vim.lsp.buf.type_definition }, { 'gr', vim.lsp.buf.references }, { 'gs', vim.lsp.buf.signature_help },
  { '<leader>lr', vim.lsp.buf.rename }, { '<leader>lf', vim.lsp.buf.format }, { '<leader>lc', vim.lsp.buf.code_action },
  { '<leader>gl', vim.diagnostic.open_float }, { '[d', vim.diagnostic.goto_prev }, { ']d', vim.diagnostic.goto_next } }
for _, keymap in pairs(keymaps) do vim.keymap.set('n', keymap[1], function() keymap[2]() end) end
