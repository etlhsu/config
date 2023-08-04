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
zsh # Refresh terminal
init # Download packages
```

## Where is .zshrc?
I use .zshenv for common zsh configurations so that .zshrc can be reserved for system-specific things.
Here are some options that are .zshrc specific:
```shell
# Adds my minimal command prompt to your terminal
precmd() {
  minprompt
  echo -ne '\e[6 q' # Prints the beam character before typing
}
