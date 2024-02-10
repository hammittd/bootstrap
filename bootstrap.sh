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

if confirm_step "Would you like to configure git?"; then
  git_config_file="$HOME/.gitconfig"
  backup_date=$(date +%Y%m%d%H%M%S)
  if [ -f "$git_config_file" ]; then
    echo "Existing git configuration found. Creating a backup..."
    backup_file="${git_config_file}.backup.${backup_date}"
    mv "$git_config_file" "$backup_file"
    echo "Backup created at $backup_file"
  fi

  read -rp "Enter your git username: " git_username
  read -rp "Enter your git email: " git_email
  if [[ -n "$git_username" && "$git_email" ]]; then
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
  fi
