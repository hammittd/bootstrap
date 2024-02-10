#!/usr/bin/env bash

set -e

GIT_CONFIG_FILE="$HOME/.gitconfig"
GIT_IGNORE_GLOBAL="$HOME/.gitignore_global"
ALLOWED_SIGNERS_FILE=~/.ssh/allowed_signers
RUBY_VERSION="3.1.4"
RBENV_INIT_LINE="rbenv()"
ZSHRC="$HOME/.zshrc"

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
  backup_date=$(date +%Y%m%d%H%M%S)

  read -rp "Enter your git username: " git_username
  read -rp "Enter your git email: " git_email

  if [[ -z "$git_username" || -z "$git_email" ]]; then
    echo "Git username and email are required. Exiting script."
    exit 1
  fi

  if [ -f "$GIT_CONFIG_FILE" ]; then
    echo "Existing git configuration found. Creating a backup..."
    backup_file="${GIT_CONFIG_FILE}.backup.${backup_date}"
    mv "$GIT_CONFIG_FILE" "$backup_file"
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
  echo "git config --global core.excludesfile $GIT_IGNORE_GLOBAL"
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
    git config --global core.excludesfile "$GIT_IGNORE_GLOBAL"
    echo "# Operating System specific ignores" >> "$GIT_IGNORE_GLOBAL"
    echo ".DS_Store" >> "$GIT_IGNORE_GLOBAL"
    echo "*.swp" >> "$GIT_IGNORE_GLOBAL"
    echo "*.swo" >> "$GIT_IGNORE_GLOBAL"
    echo "# Editor and IDE specific ignores" >> "$GIT_IGNORE_GLOBAL"
    echo ".vscode/" >> "$GIT_IGNORE_GLOBAL"
    echo ".idea/" >> "$GIT_IGNORE_GLOBAL"
    echo "*.sublime-workspace" >> "$GIT_IGNORE_GLOBAL"
    echo "# Language and Framework specific ignores" >> "$GIT_IGNORE_GLOBAL"
    echo "__pycache__/" >> "$GIT_IGNORE_GLOBAL"
    echo "*.py[cod]" >> "$GIT_IGNORE_GLOBAL"
    echo "node_modules/" >> "$GIT_IGNORE_GLOBAL"
    echo "*.class" >> "$GIT_IGNORE_GLOBAL"
    echo "# Build and Dependency folders" >> "$GIT_IGNORE_GLOBAL"
    echo "/build/" >> "$GIT_IGNORE_GLOBAL"
    echo "/dist/" >> "$GIT_IGNORE_GLOBAL"
    echo "target/" >> "$GIT_IGNORE_GLOBAL"
    echo "# Temporary files" >> "$GIT_IGNORE_GLOBAL"
    echo "*.log" >> "$GIT_IGNORE_GLOBAL"
    echo "*.tmp" >> "$GIT_IGNORE_GLOBAL"
    echo "# Environment files" >> "$GIT_IGNORE_GLOBAL"
    echo ".env" >> "$GIT_IGNORE_GLOBAL"
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
      
      touch "$ALLOWED_SIGNERS_FILE"
      echo "$git_email $ssh_key_id" >> "$ALLOWED_SIGNERS_FILE"
      git config --global gpg.ssh.allowedSignersFile "$ALLOWED_SIGNERS_FILE"
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

echo ""
if confirm_step "Add eval \"\$(rbenv init - zsh)\" to $ZSHRC?"; then
  if ! grep -qF -- "$RBENV_INIT_LINE" "$ZSHRC"; then
    echo eval "$(rbenv init - zsh)" >> "$ZSHRC"
  else
    echo "\$(rbenv init -zsh) already added to $ZSHRC."
  fi
fi

echo ""
if confirm_step "Install ruby v$RUBY_VERSION and bundler?"; then
  rbenv install "$RUBY_VERSION"
  rbenv global $RUBY_VERSION
  gem install bundler
fi

echo ""
if confirm_step "Start postgresql service?"; then
  brew services start postgresql
fi