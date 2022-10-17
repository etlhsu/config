set wmnu wop=pum "Enable the wild menu and uses popup
set wig=*.o,*~,*.pyc,*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store " Ignore compiled files in wild
set so=20 " Set 7 lines to the cursor - when moving vertically using j/k
set hls is " Highlight search results and search incrementally
set magic scs " For regular expressions turn magic on and enable smartcase searching
set nu cc=100 wrap sm " Enable line numbers, line limit, line wrapping and matching braces
set et sta ai si ts=4 shiftwidth=4 " Use 4 spaces instead of tabs and auto/smart indents
set backspace=indent,eol,start ttm=5 nocp " Make escape and backspace work, disable vi compat
set sb " Open windows from below
set ar awa | let g:auto_save = 1 | let g:auto_save_silent = 1 | "Enable auto-read, write and save
set undofile udir=~/.vim/undo/ " Stores undos
set ls=2 sc " Always show status line and show command being typed in
set nobk nowb noswf lz " Disable backups and enable lazy redraw (for perf)
let g:netrw_browse_split = 4 "Sticky window opens selected file in previous split
let g:netrw_winsize = 16 | let g:netrw_banner = 0 " Set netrw window size and hide the banner
let g:netrw_list_hide = '^\./$,^\.\./$,.DS_Store' | let g:netrw_hide = 1 " Hide annoying files
syntax on | set t_Co=256 | colorscheme darcula " Enable synatx, use 256 colors and darcula theme
set path+=** " Enables recursive searching

set hidden
autocmd BufReadPost *.kt setlocal filetype=kotlin

let g:LanguageClient_serverCommands = {
    \ 'kotlin': ["/Users/ethanhsu/Bundle/kotlin-language-server/server/build/install/server/bin/kotlin-language-server"],
    \ }
