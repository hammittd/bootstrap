#!/usr/bin/env bash
brew bundle --file ./.Brewfile

cat <<-EOF > ~/.zshrc
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
EOF
ln -s /usr/local/opt/emacs-mac/Emacs.app /Applications/Emacs.app
