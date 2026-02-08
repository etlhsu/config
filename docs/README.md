# Ethan's Config
## Installation
This repo is meant to be created as the user folder so that dotfiles are properly registered. Be sure
to pickup submodules when cloning:
```shell
cd ~ # Be in your user folder
git init # Create an empty git repo
git remote add origin https://github.com/etlhsu/config.git # Add remote repo
git pull origin main -f # Pull from remote repo
source ~/.zshenv # Run environment setup
init # Download packages
```

## Set Up Starship Prompt
After running `init`, add this line to your `~/.zshrc` to use the starship prompt:
```shell
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
```

## Where is .zshrc?
I use .zshenv for common zsh configurations so that .zshrc can be reserved for system-specific things.

## Editor Setup
Neovim is my preferred editor. To add a custom configuration file (other than the standard
`~/.config/nvim/init.lua`), create a `~/.config/nvim/after/plugin/init.lua` which will be
automatically sourced.
