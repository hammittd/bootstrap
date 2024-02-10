#!/usr/bin/env bash

set -e

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
  echo "Updating software with softwareupdate --install --recommended"
  softwareupdate --install --recommended
fi

echo ""
if ! command -v brew &> /dev/null
then
  /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if confirm_step "brew installed. Would you like to run brew bundle --file ./.Brewfile?"; then
    brew bundle --file ./.Brewfile
  fi
else
  if confirm_step "homebrew already installed. Would you like to run brew bundle --file ./.Brewfile?"; then
    brew bundle --file ./.Brewfile
  fi
  echo ""
  if confirm_step "Update and upgrade installed packages?"; then
    brew update && brew upgrade
  fi
fi


echo ""
if confirm_step "Would you like to install fzf"; then
  if [ ! -d ~/.fzf.zsh ]; then
    /usr/local/opt/fzf/install --all
  fi
fi

echo ""
if confirm_step "Would you like to configure git?"; then
  git_config_file="$HOME/.gitconfig"
  backup_date=$(date +%Y%m%d%H%M%S)
  gitignore_global="$HOME/.gitignore_global"

  read -rp "Enter your git username: " git_username
  read -rp "Enter your git email: " git_email

  if [[ -z "$git_username" || -z "$git_email" ]]; then
    echo "Git username and email are required. Exiting script."
    exit 1
  fi

  if [ -f "$git_config_file" ]; then
    echo "Existing git configuration found. Creating a backup..."
    backup_file="${git_config_file}.backup.${backup_date}"
    mv "$git_config_file" "$backup_file"
    echo "Backup created at $backup_file"
  fi

  if [[ -n "$git_username" && "$git_email" ]]; then
    echo "git username and email set $git_username $git_email"
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
  fi

  echo ""
  echo "The following git configuration will be applied:"
  echo "git config --global init.defaultBranch main"
  echo "git config --global core.editor "code --wait""
  echo "git config --global alias.co checkout"
  echo "git config --global alias.br branch"
  echo "git config --global alias.ci commit"
  echo "git config --global alias.st status"
  echo "git config --global alias.sw switch"
  echo "git config --global help.autocorrect 1"
  echo "git config --global push.default current"
  echo "git config --global credential.helper osxkeychain"
  echo "git config --global pull.rebase true"
  echo "git config --global core.excludesfile $gitignore_global"
  echo "And add the following files ot the globa gitignore file:"
  echo ".DS_Store"
  echo "*.swp"
  echo "*.swo"
  echo ".vscode/"
  echo ".idea/"
  echo "*.sublime-workspace"
  echo "node_modules/"
  echo "/build/"
  echo "/dist/"
  echo "target/"
  echo "*.log"
  echo "*.tmp"
  echo ".env"

  echo ""
  if confirm_step "Would you like to apply these settings?"; then
    git config --global init.defaultBranch main
    git config --global core.editor "code --wait"
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.sw switch
    git config --global help.autocorrect 1
    git config --global push.default current
    git config --global credential.helper osxkeychain
    git config --global pull.rebase true
    git config --global core.excludesfile "$gitignore_global"
    echo "# Operating System specific ignores" >> "$gitignore_global"
    echo ".DS_Store" >> "$gitignore_global"
    echo "*.swp" >> "$gitignore_global"
    echo "*.swo" >> "$gitignore_global"
    echo "# Editor and IDE specific ignores" >> "$gitignore_global"
    echo ".vscode/" >> "$gitignore_global"
    echo ".idea/" >> "$gitignore_global"
    echo "*.sublime-workspace" >> "$gitignore_global"
    echo "# Language and Framework specific ignores" >> "$gitignore_global"
    echo "__pycache__/" >> "$gitignore_global"
    echo "*.py[cod]" >> "$gitignore_global"
    echo "node_modules/" >> "$gitignore_global"
    echo "*.class" >> "$gitignore_global"
    echo "# Build and Dependency folders" >> "$gitignore_global"
    echo "/build/" >> "$gitignore_global"
    echo "/dist/" >> "$gitignore_global"
    echo "target/" >> "$gitignore_global"
    echo "# Temporary files" >> "$gitignore_global"
    echo "*.log" >> "$gitignore_global"
    echo "*.tmp" >> "$gitignore_global"
    echo "# Environment files" >> "$gitignore_global"
    echo ".env" >> "$gitignore_global"
  fi

  echo ""
  echo "Do you want to sign your Git commits? Choose an option:"
  echo "1) GPG"
  echo "2) SSH"
  echo "3) No signing"
  read -rp "Enter choice (1/2/3): " signing_choice

  case $signing_choice in
    1)
      read -rp "Enter GPG key ID: " gpg_key_id
      if [[ -n "$gpg_key_id" ]]; then
        git config --global user.signingkey "$gpg_key_id"
        git config --global commit.gpgsign true
        echo "Git commits will be signed with GPG."
      else
        echo "GPG key ID not provided. Skipping GPG signing configuration."
      fi
      ;;
    2)
      read -rp "Enter SSH key key ID (if you're using 1Password, copy/paste the public key from the SSH key in 1password): " ssh_key_id
      read -rp "Enter path to ssh program (if you're using 1Password, this is probably /Applications/1Password.app/Contents/MacOS/op-ssh-sign): " ssh_program
      git config --global user.signingkey "$ssh_key_id"
      git config --global gpg.format ssh
      git config --global gpg.ssh.program "$ssh_program"
      git config --global commit.gpgsign true
      allowed_signers_file=~/.ssh/allowed_signers
      touch "$allowed_signers_file"
      echo "$git_email $ssh_key_id" >> "$allowed_signers_file"
      git config --global gpg.ssh.allowedSignersFile "$allowed_signers_file"
      echo "If you'd like others to be able to verify your signature, don't forget to update your SSH key's settings on GitHub, GitLab, etc."
      ;;
    3)
      echo "Git commits will not be signed."
      ;;
    *)
      echo "Invalid choice. Skipping commit signing configuration."
      ;;
  esac
fi
