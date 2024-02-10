#!/usr/bin/env bash

confirm_step() {
  while true; do
    read -rp "$1 (Y/n) " yn
      case ${yn:-Y} in
        [Yy]* ) break;; # Treat empty input as 'yes' and break from the loop
        [Nn]* ) echo "Skipping step."; return 1;; # If no, return 1 to indicate to skip the step
        * ) echo "Please answer yes (Y) or no (n).";;
      esac
  done
}

if confirm_step "Would you like to check for available software updates with softwareupdate --install --recommended?"; then
  echo 'Updating software with softwareupdate --install --recommended'
  softwareupdate --install --recommended
fi

if ! command -v brew &> /dev/null
then
  /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo 'homebrew already installed. Running brew bundle --file ./.Brewfile'
fi

brew bundle --file ./.Brewfile

if confirm_step "Would you like to install fzf"; then
  if [ ! -d ~/.fzf.zsh ]; then
    /usr/local/opt/fzf/install --all
  fi
fi

GIT_USER=$(git config user.name)
if [ -z "$GIT_USER" ]; then
  git config --global user.name "derek"
  git config --global user.email "hammittd@icloud.com"
fi
