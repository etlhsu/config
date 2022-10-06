# Config
The tweaks that make my workflow awesome 😛

## Usage
This repo is meant to be created as the user folder so that dotfiles are properly registered. Be sure
to pickup submodules when cloning:
```shell
git clone --recurse-submodules https://github.com/ethanhsuhsu/config.git ~
```

## Where is .zshrc?
I use .zshenv for common zsh configurations so that .zshrc can be reserved for system-specific things.
Here are some options that are .zshrc specific
```shell
# Adds my minimal command prompt to your terminal
precmd() {
  minprompt
}

# Runs neofetch when the terminal opens
neofetch
```

## Setup Notes
* Make sure to set the rtp path in [.vimrc](.vimrc) to where it is installed
