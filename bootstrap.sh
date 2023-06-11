#!/usr/bin/env bash
if [ "$1" == "upgrade" ]; then
  SHOULD_UPGRADE=true
else
  SHOULD_UPGRADE=false
fi

if [ "$SHOULD_UPGRADE" = true ]; then
  softwareupdate --install --recommended
else
  echo 'Not running softwareupdate --install --recommended'
fi

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

# ln -s /usr/local/opt/emacs-mac/Emacs.app /Applications/Emacs.app

if [ ! -f ~/.fzf.zsh ]; then
  /usr/local/opt/fzf/install
fi

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
