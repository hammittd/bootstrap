#!/usr/bin/env bash
brew bundle --file ./.Brewfile

cat <<-EOF > ~/.zshrc
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
EOF
ln -s /usr/local/opt/emacs-mac/Emacs.app /Applications/Emacs.app

DOOMDIR=~/.config/emacs
if [ ! -d "$DOOMDIR" ]; then
	git clone --depth 1 https://github.com/doomemacs/doomemacs "$DOOMDIR"
    "$DOOMDIR"/bin/doom install
else
  "$DOOMDIR"/bin/doom upgrade
fi

if [ -d ~/.emacs.d ]; then
  rm -rf ~/.emacs.d
fi
