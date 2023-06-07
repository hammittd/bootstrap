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

ln -s /usr/local/opt/emacs-mac/Emacs.app /Applications/Emacs.app

/usr/local/opt/fzf/install

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
