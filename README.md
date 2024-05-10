# bootstrap
Script to install tools and do some setup.

[Inspired by this starter file](https://github.com/joeyhoer/starter/blob/master/installers/homebrew/Brewfile)

Check the `.Brewfile` to see what's installed

## Get started
- `xcode-select --install`
- `git clone` this repository

## Installing stuff
Run:
```
/bin/bash -c \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Follow instructions for adding `brew` to path.

To install everything in the `.Brewfile`, run: `brew bundle --file ./.Brewfile`.

To set up shell integrations for fzf, run: `$(brew --prefix)/opt/fzf/install --all`.

To set up global `git` config, `cp ./.gitconfig.backup ~/.gitconfig` and `cp ./.gitignore_global.backup ~/.gitignore_global`.

Run `rbenv init` and follow instructions. Run `rbenv install 3.3.1` and `rbenv global 3.3.1`. Ensure you're using the right version of `ruby` and `gem` (e.g., `gem env home` should print user home directory). Then run `gem install bundler`.

To install `nvm` and `nodejs`: `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash`, follow the instructions to use `nvm`, and run `nvm install --lts` and `nvm use --lts`

To start `postgres` server, `brew services start postgresql`

Run and configure docker with `open -a Docker`

To install Berkeley Mono fonts, `cp ./berkeley-mono-typeface/*.ttf $HOME/Library/Fonts` and `cp ./berkeley-mono-typeface/*.otf $HOME/Library/Fonts`

To enable `zsh-autosuggestions`, `echo "source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc`

To enable `zsh-syntax-highlighting`, `echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc`

To set up VS Code settings, `cp ./vscode-settings.json "$HOME/Library/Application Support/Code/User/settings.json"`

To speed up key repeats, `defaults write NSGlobalDomain KeyRepeat -int 1`

## Afterward
### postgres
- Install Postgres.app, visit: https://postgresapp.com/downloads.html
- `sudo mkdir -p /etc/paths.d && echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp`
  - https://postgresapp.com/documentation/cli-tools.html
### VS Code
- Add `code` to path in VS Code
### Terminal.app
- Update font in terminal profile

### 1password
- Don't forget to turn on the 1password SSH agent
- Don't forget to turn on `1password-cli` [integration](https://developer.1password.com/docs/cli/get-started/?utm_medium=organic&utm_source=oph&utm_campaign=macos)
