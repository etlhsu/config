# Config
The tweaks that make my workflow awesome 😛

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

## Where is .zshrc?
I use .zshenv for common zsh configurations so that .zshrc can be reserved for system-specific things.
Here are some options that are .zshrc specific:
```shell
# Adds my minimal command prompt to your terminal
precmd() {
  minprompt
}
```

## Editor Setup
Neovim is my preferred editor due to its flexibility and ability for me to spend endless hours
ricing my configuration. To add a custom configuration file (other than the standard
`~/.config/nvim/init.lua`), create a `~/.config/nvim/after/plugin/init.lua` which will be
automatically sourced.

Some themes that I like:
- Retrobox - The best overall theme with reasonable colors
- Habamax - Provies the most calming editing experience
