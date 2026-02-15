-- Starting Options
vim.opt.autowriteall = true
vim.opt.colorcolumn = '100'
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
vim.opt.gdefault = true
vim.opt.hidden = false
vim.opt.number = true
vim.opt.shiftwidth = 2
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.splitbelow = true
vim.g.mapleader = ' '
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = '^\\./$,^\\.\\./$,.DS_Store';
vim.g.netrw_winsize = 20
vim.cmd.colorscheme('retrobox')

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

-- Automatically read a file when re-entered
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' },
 { pattern = '*', callback = function() vim.cmd.checktime() end })
-- Automatically write a file upon a change in insert mode or normal mode
 vim.api.nvim_create_autocmd({ 'InsertLeavePre', 'TextChanged' },
-- { pattern = '*', callback = function() EditBuf([[silent! write]]) end }) 
 { pattern = '*', callback = function() vim.cmd.w({ bang = true, mods = { silent = true, emsg_silent = true }}) end })

-- Keymaps
-- Begin escaping terminal insert mode using Ctrl-W
vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>')
-- Go to import section in Java/Kotlin
vim.keymap.set('n', '<leader>gi', '?^import.*\\n.*\\n<CR>:noh<CR>')
-- Command spinning using Ctrl+e
vim.keymap.set('n', '<C-e>', function()
  vim.fn.system { vim.env.HOME .. '/.config/bin/spin', 'refresh' }
  print("Spining...")
end)

-- Commands

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
  vim.keymap.set('n', '<leader>vs', function()
    builtin.live_grep({ search_dirs = get_git_files("HEAD~1") })
  end
  )
  vim.keymap.set('n', '<leader>vaf', function()
    builtin.find_files({ search_dirs = get_git_files("HEAD~3") })
  end
  )
  vim.keymap.set('n', '<leader>vas', function()
    builtin.live_grep({ search_dirs = get_git_files("HEAD~3") })
  end
  )
end

-- Treesitter and LSP
local hasTreesitterConfigs, treesitterConfigs = pcall(require, 'nvim-treesitter.configs')

if hasTreesitterConfigs then
  treesitterConfigs.setup {
    ensure_installed = { 'astro', 'bash', 'c', 'css', 'go', 'html', 'java', 'kotlin', 'lua', 'markdown',
      'markdown_inline', 'proto', 'query', 'tsx', 'typescript', 'vim', 'vimdoc' },
    highlight = { enable = true }, }
end
require('mini.snippets').setup({})
require('mini.completion').setup({})
vim.lsp.enable({'astro', 'bashls', 'kotlin_lsp', 'lua_ls'})
vim.keymap.set('n', '<leader>ln', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action)
vim.keymap.set('n', '<leader>lr', vim.lsp.buf.references)
vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation)
vim.keymap.set('n', '<leader>lt', vim.lsp.buf.type_definition)
vim.keymap.set('n', '<leader>lo', vim.lsp.buf.document_symbol)
vim.keymap.set('n', '<leader>lh', vim.lsp.buf.signature_help)
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>K', function() vim.diagnostic.open_float() end)
