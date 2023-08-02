set wmnu wop=pum wig=*.o,*~,*.pyc,*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store/*,*/.gradle/* " Enable wild menu
set backspace=indent,eol,start nocp " Make escape, backspace work, disable vi compat
set cc=100 hls is magic scs so=20 sb mouse=a " Better searching, line boundary, mouse, windows from below
set nu wrap sm ls=2 sc et sta ai si ts=2 shiftwidth=2 " Line, statusline, tab UI improvements
set ar awa | au FocusGained,BufEnter * if getcmdwintype() == '' | checktime | endif " Auto-read
au TextChanged * if getcmdwintype() == '' | silent! write | endif " Auto-write
au filetype netrw map <buffer> h -^| map <buffer> l <CR>| map <buffer> . gh| " Navigate netrw like ranger
set undofile udir=~/.vim/undo/ nobk nowb noswf lz tf " Store undos without backups and lazy redraw
set path+=** shm+=c shm+=l shm-=S completeopt=menuone,popup " Better pop-ups
set t_Co=256 | syntax on | colorscheme slate | hi Normal ctermfg=LightGrey | " Theming stuff
set ttm=1 | let &t_SI = "\e[6 q" | let &t_EI = "\e[2 q" | silent "!echo -ne "\e[2 q"" | " Correct cursor
set hidden | au BufReadPost *.kt setlocal filetype=kotlin " Support Kotlin
set rtp+=/opt/homebrew/opt/fzf | map <C-p> :Files<CR> | " Enable FZF
let $FZF_DEFAULT_OPTS="--bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down"
let g:netrw_browse_split = 4 | let g:netrw_winsize = 16 | let g:netrw_banner = 0 " Set netrw options
let g:netrw_list_hide = '^\./$,^\.\./$,.DS_Store' | let g:netrw_hide = 1 " Hide annoying files
if filereadable("~/.vim/rc.vim") | source ~/.vim/rc.vim | endif " Load config-specific file
command! Ter execute "bo ter" | execute "res 15" | command! Vres execute "vert res"| " Simple remaps
let mapleader = ' ' | noremap <leader>fo :browse oldfiles<CR>| " Easily browse oldfiles
map <C-f> :<C-f>| imap <C-f> <ESC>:<C-f> | map <C-k> <C-w>| imap <C-k> <C-w>| tmap <C-k> <C-w>| " Remaps
map <leader>fo :History<CR>| map <leader>gwo :GFiles<CR>| map <leader>fa :Rg<CR>| map <leader>fb :Buffers<CR>| map <leader>fh :Helptags<CR>
command! Soi source ~/.vimrc
ab uenv #!/usr/bin/env
