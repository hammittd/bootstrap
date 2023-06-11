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
fi

[ "$SHOULD_UPGRADE" = true ] && "$DOOMDIR"/bin/doom upgrade

if [ -d ~/.emacs.d ]; then
  rm -rf ~/.emacs.d
fi

BELL_SETTING="unsetopt BEEP"
ZSHRC="$HOME/.zshrc"

[ -z $(grep "$BELL_SETTING" "$ZSHRC") ] && echo "$BELL_SETTING" >> "$ZSHRC"

# Set initial key repeat to 10 (150ms)
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
# Setting key repeat to 1 (15ms)
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

# Privacy: don’t send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true
# Set Safari’s home page to `about:blank` for faster loading
defaults write com.apple.Safari HomePage -string "about:blank"
# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
