#!/usr/bin/env bash
echo 'Updating software with softwareupdate --install --recommended'
softwareupdate --install --recommended

if ! command -v brew &> /dev/null
then
    /bin/bash -c \
        "$(curl -fsSL \
        https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo 'homebrew already installed. Running brew bundle...'
fi

brew bundle --file ./.Brewfile

cat <<-EOF > ~/.zshrc
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
EOF

if [ ! -d ~/.fzf.zsh ]; then
  /usr/local/opt/fzf/install
fi

GIT_USER=$(git config user.name)
if [ -z "$GIT_USER" ]; then
  git config --global user.name "derek"
  git config --global user.email "hammittd@icloud.com"
fi