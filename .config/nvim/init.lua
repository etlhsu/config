vim.opt.wildignore = { '*.git/*', '*/.hg/*', '*.DS_Store' }; vim.opt.completeopt = { 'menu', 'menuone', 'noselect',
  'noinsert' }
vim.opt.scrolloff = 20; vim.opt.number = true; vim.opt.colorcolumn = '100'
vim.opt.wrap = true; vim.opt.tabstop = 2; vim.opt.shiftwidth = 2; vim.opt.smartindent = true; vim.opt.expandtab = true
vim.opt.splitbelow = true
vim.opt.autowriteall = true; vim.opt.undofile = true; vim.opt.swapfile = false; vim.opt.backup = false; vim.opt.writebackup = false
vim.opt.gdefault = true;
vim.opt.runtimepath:append(',~/.config/nvim/pack/plugins/start/*/*')
vim.opt.shada = "!,'250,f1,<50,s10,h" -- Allowing for 250 oldfiles
vim.g.mapleader = ' '
vim.g.netrw_winsize = 20; vim.g.netrw_banner = 0; vim.g.netrw_hide = 1; vim.g.netrw_list_hide =
'^./$,^../$,.DS_Store';
vim.keymap.set({ 'n', 'v', 's', 'o', 'i', 'c' }, '<C-k>', '<C-w>')
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>'); vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>')
vim.keymap.set({ 'n', 'v', 'o' }, '<C-f>', ':<C-f>'); vim.keymap.set('i', '<C-f>', '<ESC>:<C-f>')
vim.keymap.set({ 'n', 'v', 'o' }, '<leader>gi', '?^import.*\\n.*\\n<CR>:noh<CR>')
vim.keymap.set({ 'n', 'v', 'o' }, '<leader>gp', '`[\' . strpart(getregtype(), 0, 1) . \'`]')
vim.keymap.set({ 'n', 'v', 'o' }, '<leader>gr', function()
  vim.api.nvim_feedkeys(':%s/' .. vim.fn.expand('<cword>') .. '/', 'n', {})
end)
vim.keymap.set({ 'n', 'v', 'o' }, '<leader>gR', function()
  vim.api.nvim_feedkeys(':%s/' .. vim.fn.expand('<cWORD>') .. '/', 'n', {})
end)
vim.keymap.set({ 'n', 'v', 'o' }, '<C-e>', function()
  vim.fn.system { vim.env.HOME .. '/.config/bin/spin', 'refresh' }
  print("Spining...")
end)
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
vim.cmd([[ au filetype netrw map <buffer> h -^| map <buffer> l <CR>| map <buffer> . gh| ]]) -- Navigate netrw like ranger
vim.cmd([[ au filetype netrw map <buffer> L <CR><C-R>=vim.g.netrw_preview| ]])              -- Navigate netrw like ranger
local function EditBuf(cmd)
  if vim.fn.getcmdwintype() == "" and vim.api.nvim_win_get_config(0).relative == "" then vim.cmd(cmd) end
end
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' },
  { pattern = '*', callback = function() EditBuf([[checktime]]) end })
vim.api.nvim_create_autocmd({ 'InsertLeavePre', 'TextChanged' },
  { pattern = '*', callback = function() EditBuf([[silent! write]]) end })
vim.api.nvim_create_user_command('Ter',
  function() vim.cmd([[bot new | res 15 | set wfh | set nonu | startinsert | ter ]]) end, {})
vim.api.nvim_create_user_command('Soi', function() vim.cmd([[source ~/.config/nvim/init.lua]]) end, {})
vim.api.nvim_create_user_command('Note', function() vim.cmd([[tabnew | e ~/personal/note.md]]) end, {})
vim.api.nvim_create_user_command('Vex', function()
  vim.g.netrw_chgwin = vim.fn.bufwinnr(vim.fn.bufnr()) + 1
  vim.cmd([[Vexplore]])
end, {})
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

vim.api.nvim_create_user_command('Kit', function(opts)
  if vim.api.nvim_get_option_value('filetype', {}) ~= 'netrw' then
    print("Kits can only be made inside netrw explorers")
    return
  end
  local kit = vim.env.HOME .. '/personal/kits/' .. opts.args
  path = vim.fn.fnamemodify(vim.b.netrw_curdir, ':p')
  os.execute('cp -R ' .. kit .. '/* ' .. path)
  vim.cmd [[ e ]]
end, {
  complete = function(input)
    local handle = io.popen('ls $HOME/personal/kits')
    local results = handle:read("*a")
    handle:close()
    local completes = {}
    for result in string.gmatch(results, "[^%s]+") do
      if input ~= ' ' and result:find('^' .. input) ~= null then
        completes[#completes + 1] = result
      end
    end
    return completes
  end,
  nargs = 1
})

Impored=false
ImportTable = {}
vim.keymap.set({ 'n', 'v', 'o' }, '<leader>i', function()
  if Imported == false then
    handle=io.popen("cat $shada")
    local results = handle:read("*a")
    for line in handle:lines() do
      --table.insert(ImportTable, 
    end
    handle:close()
  end

end)

-- Loading plugins
local hasTelescope, telescope = pcall(require, 'telescope')
local hasTreesitterConfigs, treesitterConfigs = pcall(require, 'nvim-treesitter.configs')
local hasLspZero, lspZero = pcall(require, 'lsp-zero')
local hasLspConfig, lspconfig = pcall(require, 'lspconfig')
local hasCmp, cmp = pcall(require, 'cmp')
local hasColorizer, colorizer = pcall(require, 'colorizer')
local hasCatppuccin, catppuccin = pcall(require, 'catppuccin')


if hasColorizer then
  colorizer.setup {
      filetypes = { "*" },
    user_default_options = {
      RGB = true, -- #RGB hex codes
      RRGGBB = true, -- #RRGGBB hex codes
      names = false, -- "Name" codes like Blue or blue,
      tailwind = true,
    }
  }
end

if hasCatppuccin then
catppuccin.setup({
   custom_highlights = function(colors)
        return {
        LineNr = { fg = colors.overlay0 },
        MatchParen = { bg = colors.mauve },
        StatusLine = { fg = colors.mauve, bg = colors.surface1 },
        StatusLineNC = { fg = colors.mauve, bg = colors.surface0 },
        WinSeparator = { fg = colors.surface1 },
      }
      end,
    integrations = {
      treesitter = true,
      telescope = true,
    }
  })

  if((os.getenv('COLORTERM') or ''):match('truecolor') ~= nil and vim.g.colors_name ~= 'catppuccin-mocha') then
    vim.o.termguicolors = true
    vim.cmd.colorscheme('catppuccin-mocha')
  else
    vim.cmd.colorscheme('slate')
  end
end

filter = vim.tbl_filter
Path = require("plenary.path")
get_open_filelist = function(grep_open_files, cwd)
  if not grep_open_files then
    return nil
  end

  local bufnrs = filter(function(b)
    if 1 ~= vim.fn.buflisted(b) then
      return false
    end
    return true
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
      layout_config = {
        vertical = {
          width = function(_, max_columns)
            local percentage = 0.5
            local max = 150
            return math.min(math.floor(percentage * max_columns), max)
          end,
          height = function(_, _, max_lines)
            local percentage = 0.5
            local min = 75
            return math.max(math.floor(percentage * max_lines), min)
          end
        }
      }
    }
  })
  local builtin = require('telescope.builtin')
  local utils = require('telescope.utils')
  vim.keymap.set('n', '<C-p>', builtin.find_files)
  vim.keymap.set('n', '<leader>te', builtin.resume)
  vim.keymap.set('n', '<leader>ff',
    function() builtin.find_files({ find_command = { 'rg', '--files', '--no-ignore-vcs', } }) end)
  vim.keymap.set('n', '<leader>fs', builtin.live_grep)

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
  vim.keymap.set('n', '<leader>os', function ()
    local results = {}
    for k, v in pairs(vim.v.oldfiles) do
      if vim.fn.isdirectory(v) == 0 then
        table.insert(results, v)
      end
    end
    builtin.live_grep({ search_dirs = results })
  end)

  function get_git_files(rev)
    local handle = io.popen("cd " .. vim.loop.cwd() .. "&& git rev-parse --show-toplevel")
    local root = handle:read("*a")
    root = root:sub(1, -2) .. "/"
    handle:close()

    local files = {}
    for index, file in pairs(utils.get_os_command_output({"git", "diff", rev, "--name-only", }, root)) do
      table.insert(files, root .. file)
    end
    for index, file in pairs(utils.get_os_command_output({"git", "ls-files", "--others", "--exclude-standard", }, root)) do
      table.insert(files, root .. file)
    end

    print("File start")
    for k, v in pairs(files) do
      print(v)
    end
    print("File end")
    return files
  end

  vim.keymap.set('n', '<leader>vf', function()
    builtin.find_files({search_dirs=get_git_files("HEAD~1")})
  end
  )
  vim.keymap.set('n', '<leader>vaf', function()
    builtin.find_files({search_dirs=get_git_files("HEAD~3")})
  end
  )
  vim.keymap.set('n', '<leader>vs', function()
    builtin.live_grep({search_dirs=get_git_files("HEAD~1")})
  end
  )
  vim.keymap.set('n', '<leader>vas', function()
    builtin.live_grep({search_dirs=get_git_files("HEAD~3")})
  end
  )

end

if hasTreesitterConfigs then
  treesitterConfigs.setup {
    ensure_installed = { 'astro', 'bash', 'css', 'html', 'java', 'kotlin', 'lua', 'tsx', 'typescript', 'vimdoc' },
    highlight = { enable = true }, }
end

if hasLspZero and hasLspConfig and hasCmp then
  local lsp = lspZero.preset({})
  lsp.on_attach(function(client, bufnr)
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
