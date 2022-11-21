set wmnu wop=pum "Enable the wild menu and uses popup
set wig=*.o,*~,*.pyc,*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store " Ignore compiled files in wild
set so=20 " Set 7 lines to the cursor - when moving vertically using j/k
set hls is " Highlight search results and search incrementally
set magic scs " For regular expressions turn magic on and enable smartcase searching
set nu cc=100 wrap sm " Enable line numbers, line limit, line wrapping and matching braces
set et sta ai si ts=2 shiftwidth=2 " Use 4 saces instead of tabs and auto/smart indents
set backspace=indent,eol,start ttm=5 nocp " Make escape and backspace work, disable vi compat
set sb " Open windows from below
set ar | au FocusGained,BufEnter * checktime " Enable auto-read
set awa | autocmd TextChanged * silent! write | call system('spin change')  " Enable auto-write
set undofile udir=~/.vim/undo/ " Stores undos
set ls=2 sc " Always show status line and show command being typed in
set nobk nowb noswf lz " Disable backups and enable lazy redraw (for perf)
let g:netrw_browse_split = 4 "Sticky window opens selected file in previous split
let g:netrw_winsize = 16 | let g:netrw_banner = 0 " Set netrw window size and hide the banner
let g:netrw_list_hide = '^\./$,^\.\./$,.DS_Store' | let g:netrw_hide = 1 " Hide annoying files
syntax on | set t_Co=256 | colorscheme slate " Enable synatx, use 256 colors and slate theme
set path+=** " Enables recursive searching
set shm+=c shm+=l shm-=S completeopt=menuone,popup
set mouse=a " Enables mouse mode
set hidden | au BufReadPost *.kt setlocal filetype=kotlin " Support Kotlin
hi Normal ctermfg=LightGrey | " Saving my precious eyeballs
set rtp+=/usr/local/opt/fzf,/usr/share/doc/fzf/examples | map <C-p> :FZF<CR> | " Enable FZF
nnoremap <C-i> <C-w> <C-P> | " Buffer switching using tab key
call system('[[ ! -f ~/.vim/rc.vim ]] && mkdir -p .vim && touch ~/.vim/rc.vim') | source ~/.vim/rc.vim " Load config-specific file
runtime ftplugin/man.vim

map <C-E> :call system('spin refresh')<CR> | " Force spin

function ShowTip(tipname)
  let buffers = getbufinfo()
  let i = 0
  while i < len(buffers)
    let pathregex = expand("$HOME") . '/.config/tip/.*.md'
    let bufname = buffers[i]["name"] 
    let hidden = buffers[i]["hidden"]
    if bufname =~ pathregex && hidden == 0
      let currBufName = bufname
      let currBufNr = buffers[i]["bufnr"]
      break
    endif
    let i += 1
  endwhile
  let editname = expand("$HOME") . '/.config/tip/' . a:tipname . '.md'
  if exists("currBufName")
    call win_gotoid(win_findbuf(currBufNr)[0])
    execute "e " . editname
  else 
    execute "split " . editname
    execute "set nonumber"
    execute "highlight EndOfBuffer ctermfg=bg guifg=bg"
  endif
endfunction

command! -nargs=1 Tip call ShowTip(<q-args>)
command! -nargs=1 T call ShowTip(<q-args>)
