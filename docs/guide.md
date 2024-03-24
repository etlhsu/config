# The Structured Yet Unstructured Guide

## Tmux
`Ctrl+B` is the prefix key which can be combined with other keys to perform actions
- `%` - split pane vertically
- `"` - split pane horizontally

## Neovim

### Folds
- `zM` - Close all folds
- `zR` - Open all folds

### Spelling
- `set spell/nospell` - Enable/disable spelling for a buffer
- `[s/]s` - Go to previous/next misspelled word
- `z=` Find suggestions for the misspelled word under the cursor

### Substitution
- `\r`- Used to add a newline in the second part of a substitution

### Miscellaneous
- `redir @">|command` - Redirects command output to the unnamed register
- `helptags ALL` - Generate help tags files for all plugins

## Git
- `git submodule update --recursive --remote` - Pull latest changes for all submodules
