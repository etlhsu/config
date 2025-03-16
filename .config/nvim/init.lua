-- Starting Options
vim.cmd.colorscheme('retrobox')
vim.g.mapleader = ' '
vim.g.netrw_banner = 0
vim.g.netrw_hide = 1
vim.g.netrw_list_hide = '^\\./$,^\\.\\./$,.DS_Store';
vim.g.netrw_winsize = 20
vim.opt.autowriteall = true
vim.opt.backup = false
vim.opt.colorcolumn = '100'
vim.opt.textwidth = 100
vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'noinsert' }
vim.opt.expandtab = true
vim.opt.foldmethod = 'marker'
vim.opt.gdefault = true
vim.opt.number = true
vim.opt.scrolloff = 20
vim.opt.shada = "'300,h" -- Allow for 300 oldfiles and prevent highlighting the saved search
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.splitbelow = true
vim.opt.swapfile = false
vim.opt.tabstop = 2
vim.opt.undofile = true
vim.opt.wildignore = { '*.git/*', '*/.hg/*', '*.DS_Store' }
vim.opt.wrap = true
vim.opt.writebackup = false
vim.opt.hidden = false

-- Abbreviations (triggered by entering a sequence and <space> in insert mode)
vim.cmd([[
  func! Eatchar()
     let c = nr2char(getchar(0))
     return (c =~ '\s') ? '' : c
  endfunc
  command! -nargs=+ Eia ia<space><args><C-R>=Eatchar()<CR>
  Eia uenv #!/usr/bin/env
  Eia ktci import kotlinx.coroutines.
  Eia ktcf import kotlinx.coroutines.flow.
  Eia moci import org.mockito.kotlin.
  Eia comi import androidx.compose.
]])
-- Navigate netrw like ranger
vim.cmd([[ au filetype netrw map <buffer> h -^| map <buffer> l <CR>| map <buffer> . gh| ]])
vim.cmd([[ au filetype netrw map <buffer> L <CR><C-R>=vim.g.netrw_preview| ]])

local function EditBuf(cmd)
  if vim.fn.getcmdwintype() == "" and vim.api.nvim_win_get_config(0).relative == "" then vim.cmd(cmd) end
end
-- Automatically read a file when re-entered
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' },
  { pattern = '*', callback = function() EditBuf([[checktime]]) end })
-- Automatically write a file upon a change in insert mode or normal mode
vim.api.nvim_create_autocmd({ 'InsertLeavePre', 'TextChanged' },
  { pattern = '*', callback = function() EditBuf([[silent! write]]) end })
-- Configure new terminals with no line numbers and begin them in insert mode
vim.api.nvim_create_autocmd({ 'TermOpen' },
  { pattern = '*', callback = function() vim.cmd([[setlocal nonumber signcolumn=no" | startinsert]]) end })
-- }}}

-- Keymaps
-- Begin escaping terminal insert mode using Ctrl-W
vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>')
-- Go to import section in Java/Kotlin
vim.keymap.set('n', '<leader>gi', '?^import.*\\n.*\\n<CR>:noh<CR>')
vim.keymap.set('n', '<leader>gr', function()
  -- Replace current word
  vim.api.nvim_feedkeys(':%s/' .. vim.fn.expand('<cword>') .. '/', 'n', {})
end)
-- Replace current WORD
vim.keymap.set('n', '<leader>gR', function()
  vim.api.nvim_feedkeys(':%s/' .. vim.fn.expand('<cWORD>') .. '/', 'n', {})
end)
-- Go to file (searches oldfiles)
vim.keymap.set({ 'n', 'v', 'o' }, '<leader>gf', function()
  local symbol = vim.fn.expand('<cword>')
  for k, file in pairs(vim.v.oldfiles) do
    if file:find(symbol) ~= nil then
      -- open file
      vim.cmd('e ' .. file)
      return
    end
  end
  print("No associated file found for: " .. symbol)
end)
-- Command spinning using Ctrl+e
vim.keymap.set('n', '<C-e>', function()
  vim.fn.system { vim.env.HOME .. '/.config/bin/spin', 'refresh' }
  print("Spining...")
end)
-- }}}

-- Commands

-- Reload init.lua quickly
vim.api.nvim_create_user_command('Soi', function() vim.cmd([[source ~/.config/nvim/init.lua]]) end, {})

-- Create a file in the directory of the current file
vim.api.nvim_create_user_command('E', function(opts)
  local file = opts.args
  if file[0] ~= '/' then
    file = vim.fn.expand('%:h') .. '/' .. file
  end
  vim.cmd('edit ' .. file)
end, {
  complete = function(input)
    local dir = ''
    local dir_path = vim.fn.expand('%:h')
    local start_dir, end_dir = input:find('.+/')
    if start_dir ~= nil then dir = input:sub(start_dir, end_dir) end
    local start_input = ''
    if dir ~= '' then
      dir_path = dir_path .. '/' .. dir
      if #input ~= #dir then
        start_input = input:sub(#dir + 1, #input)
      end
    else
    end
    local handle = io.popen('cd ' .. dir_path .. ' && ls -p')
    local results = handle:read("*a")
    handle:close()
    local completes = {}
    for result in string.gmatch(results, "[^%s]+") do
      if input ~= ' ' and result:find('^' .. start_input) ~= nil then
        completes[#completes + 1] = dir .. result
      end
    end
    return completes
  end,
  nargs = 1
})

-- Rename/move the current file to a new location
vim.api.nvim_create_user_command('Mv', function(opts)
  local file = opts.args
  local oldfile = vim.fn.expand('%')
  if string.match(file, '/') == nil then
    file = vim.fn.expand('%:h') .. '/' .. file
  end
  local old_buf = vim.api.nvim_get_current_buf()
  local old_bufname = vim.fn.bufname(old_buf)
  vim.cmd('saveas ' .. file)
  os.remove(oldfile)
  vim.api.nvim_buf_delete(vim.fn.bufnr(old_bufname), {})
end, { complete = 'file', nargs = 1 })

-- Apply a kit in the current directory
vim.api.nvim_create_user_command('Kit', function(opts)
  if vim.api.nvim_get_option_value('filetype', {}) ~= 'netrw' then
    print("Kits can only be made inside netrw explorers")
    return
  end
  local kit = vim.env.HOME .. '/personal/kits/' .. opts.args
  local path = vim.fn.fnamemodify(vim.b.netrw_curdir, ':p')
  os.execute('cp -R ' .. kit .. '/* ' .. path)
  vim.cmd [[ e ]]
end, {
  complete = function(input)
    local handle = io.popen('ls $HOME/personal/kits')
    local results = handle:read("*a")
    handle:close()
    local completes = {}
    for result in string.gmatch(results, "[^%s]+") do
      if input ~= ' ' and result:find('^' .. input) ~= nil then
        completes[#completes + 1] = result
      end
    end
    return completes
  end,
  nargs = 1
})

-- Generate help tags for installed plugins
vim.api.nvim_create_user_command('Helptags', function()
  local doc_paths = vim.fn.expand('/Users/ethanhsu/.config/nvim/pack/plugins/start/*/doc/')
  doc_paths = doc_paths:gsub('\n', ' ')
  print(doc_paths)
  for doc_path in string.gmatch(doc_paths, "[^%s]+") do
    vim.cmd('helptags ' .. doc_path)
  end
end, {}
)
-- }}}

-- Telescope
local hasTelescope, telescope = pcall(require, 'telescope')
local filter = vim.tbl_filter
Path = require("plenary.path")
local function get_open_filelist(grep_open_files, cwd)
  if not grep_open_files then
    return nil
  end

  local bufnrs = filter(function(b)
    return 1 == vim.fn.buflisted(b)
  end, vim.api.nvim_list_bufs())
  if not next(bufnrs) then
    return
  end

  local filelist = {}
  for _, bufnr in ipairs(bufnrs) do
    local file = vim.api.nvim_buf_get_name(bufnr)

    local ft = vim.api.nvim_get_option_value("ft", { buf = bufnr })
    local bt = vim.api.nvim_get_option_value("bt", { buf = bufnr })
    if ft == "netrw" or bt ~= "" then
    else
      table.insert(filelist, Path:new(file):make_relative(cwd))
    end
  end
  return filelist
end

if hasTelescope then
  telescope.setup({
    defaults = {
      sorting_strategy = 'ascending',
      layout_strategy = 'center',
    }
  })

  local builtin = require('telescope.builtin')
  local utils = require('telescope.utils')

  vim.keymap.set('n', '<C-p>', builtin.find_files)
  vim.keymap.set('n', '<leader>ff',
    function() builtin.find_files({ find_command = { 'rg', '--files', '--no-ignore-vcs', } }) end)
  vim.keymap.set('n', '<leader>fs',
    function() builtin.live_grep({ additional_args = { '--no-ignore-vcs' } }) end)

  vim.keymap.set('n', '<leader>bf', builtin.buffers)
  vim.keymap.set('n', '<leader>bs', function()
    local results = {}
    for k, v in pairs(get_open_filelist(true, vim.loop.cwd())) do
      if vim.fn.isdirectory(v) == 0 then
        table.insert(results, v)
      end
    end
    builtin.live_grep({ search_dirs = results })
  end)

  vim.keymap.set('n', '<leader>df', function()
    builtin.find_files({ search_dirs = { vim.fn.expand('%:h') } })
  end)
  vim.keymap.set('n', '<leader>ds', function()
    builtin.live_grep({ search_dirs = { vim.fn.expand('%:h') } })
  end)

  vim.keymap.set('n', '<leader>hs', builtin.help_tags)

  vim.keymap.set('n', '<leader>of', builtin.oldfiles)
  vim.keymap.set('n', '<leader>os', function()
    local results = {}
    for _, v in pairs(vim.v.oldfiles) do
      if vim.fn.isdirectory(v) == 0 then
        table.insert(results, v)
      end
    end
    builtin.live_grep({ search_dirs = results })
  end)

  vim.keymap.set('n', '<leader>te', builtin.resume)

  local function get_git_files(rev)
    local handle = io.popen("cd " .. vim.loop.cwd() .. "&& git rev-parse --show-toplevel")
    local root = handle:read("*a")
    root = root:sub(1, -2) .. "/"
    handle:close()

    local files = {}
    for _, file in pairs(utils.get_os_command_output({ "git", "diff", rev, "--name-only", }, root)) do
      table.insert(files, root .. file)
    end
    for _, file in pairs(utils.get_os_command_output({ "git", "ls-files", "--others", "--exclude-standard", }, root)) do
      table.insert(files, root .. file)
    end

    for _, v in pairs(files) do
      print(v)
    end
    return files
  end

  vim.keymap.set('n', '<leader>vf', function()
    builtin.find_files({ search_dirs = get_git_files("HEAD~1") })
  end
  )
  vim.keymap.set('n', '<leader>vaf', function()
    builtin.find_files({ search_dirs = get_git_files("HEAD~3") })
  end
  )
  vim.keymap.set('n', '<leader>vs', function()
    builtin.live_grep({ search_dirs = get_git_files("HEAD~1") })
  end
  )
  vim.keymap.set('n', '<leader>vas', function()
    builtin.live_grep({ search_dirs = get_git_files("HEAD~3") })
  end
  )
end
-- }}}

-- Treesitter and LSP
local hasTreesitterConfigs, treesitterConfigs = pcall(require, 'nvim-treesitter.configs')

if hasTreesitterConfigs then
  treesitterConfigs.setup {
    ensure_installed = { 'astro', 'bash', 'c', 'css', 'go', 'html', 'java', 'kotlin', 'lua', 'markdown',
      'markdown_inline', 'proto', 'query', 'tsx', 'typescript', 'vim', 'vimdoc' },
    highlight = { enable = true }, }
end

local hasLspZero, lspZero = pcall(require, 'lsp-zero')
local hasLspConfig, lspconfig = pcall(require, 'lspconfig')
local hasCmp, cmp = pcall(require, 'cmp')

if hasLspZero and hasLspConfig and hasCmp then
  local lsp = lspZero.preset({})
  lsp.on_attach(function(_, bufnr)
    lsp.default_keymaps({ buffer = bufnr })
  end)
  lsp.setup_servers({ 'astro', 'bashls', 'kotlin_language_server', 'lua_ls' })
  lspconfig.lua_ls.setup(lsp.nvim_lua_ls({
    root_dir = lspconfig.util.root_pattern('.luarc.json', vim.env.HOME .. '/.nvim/config'), }))
  lsp.setup_nvim_cmp({
    mapping = {
      ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ["<C-y>"] = cmp.mapping.confirm({ select = true }),
      ["<C-space>"] = cmp.mapping.complete(),
    },
  })
  lsp.setup()
  vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename)
  vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
  vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action)
end

vim.keymap.set('n', '<leader>K', function()
  vim.diagnostic.open_float()
end)
-- }}}
