#!/usr/bin/env bash

# Install Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Make sure we're using latest Homebrew.
brew update

# Upgrade any already-installed formula.
brew upgrade --all

# Install Homebrew Cask
brew install caskroom/cask/brew-cask

# Install iTerm2
brew cask install iterm2

# Install GNU core utilities (those that come with OS X are outdated).
# Don't forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
# XXX: Already added the path in ~/.path
brew install coreutils
echo '# Use GNU core utilities instead of those come with OS X
#
# The Homebrew coreutils formula installs the tools with g appended to their names -
# e.g. gcat instead of cat, etc. This is a workaround in order to use GNU version of tools
# i.e. without prefix "g".
#
# NOTE: Using gnubin will cause Homebrew warning:
#       "Putting non-prefixed coreutils in your path can cause gmp builds to fail."
#       However, I will leave it there since it have not caused me any problem so far.
#
# Reference
# - http://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities
# - https://github.com/Homebrew/legacy-homebrew/issues/19238
COREUTILS="$(brew --prefix coreutils)/libexec/gnubin"
export PATH="$COREUTILS:$PATH"' > $HOME/.path


# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GUN `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-name

# Install `wget` with IRI support.
brew install wget --with-iri

# Install more recent verions of some OS X tools.
brew install vim --override-system-vi
brew install homebrew/dupes/grep
brew install homebrew/dupes/openssh

# Install zsh
brew install zsh

# Install my favorite tools
brew install git
brew install autojump
brew install the_silver_searcher
brew install tmux
brew install tree
brew install ctags
brew install cscope

# Install packages for later installation use
brew install python       # pyhton 2.7, will also install pip
brew install python3
pip install --upgrade pip # upgrade pip

# Install font tools.
brew tap bramstein/webfonttools
brew install sfnt2woff
brew install sfnt2woff-zopfli
brew install woff2

# Remove outdated versions from the cellar.
brew cleanup

bash -c "$(curl -fsSL https://raw.github.com/weitingchou/dotfiles/master/scripts/install_dotfiles.sh)" "macos"
