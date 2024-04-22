# The Structured Yet Unstructured Guide

## Tmux
`Ctrl+B` is the prefix key which can be combined with other keys to perform actions:
- `?` - see of all of the actions
- `%` - split pane vertically
- `"` - split pane horizontally
- `w` - select window
- `s` - select session
- `D` - select client

Use `Ctrl+B`+`:` to enter commands:
- `:new` - Create a new session

## Neovim
- `gq_` - Reformat text to fit

### Folds
- `zM` - Close all folds
- `zR` - Open all folds

### Spelling
- `set spell`/`nospell` - Enable/disable spelling for a buffer
- `[s`/`]s` - Go to previous/next misspelled word
- `z=` Find suggestions for the misspelled word under the cursor

### Substitution
- `\r`- Used to add a newline in the second part of a substitution

### Miscellaneous
- `redir @">|command` - Redirects command output to the unnamed register
- `helptags ALL` - Generate help tags files for all plugins

## Git
- `git submodule update --recursive --remote` - Pull latest changes for all submodules
