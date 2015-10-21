#!/usr/bin/env bash

set -e

# Use colors, but only if connected to a terminal, and that terminal
# supports them.
tput=$(which tput)
if [ -n "$tput"  ]; then
    ncolors=$($tput colors)
fi
if [ -t 1  ] && [ -n "$ncolors"  ] && [ "$ncolors" -ge 8  ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
fi

# Utility functions
info () {
    printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
    printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
    printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
    printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
    echo ''
    exit
}

version_gte () {
    if [[ $1 == $2  ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]}  ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 0
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 1
        fi
    done
    return 0
}

read -p "Please select the platform type you are installing: server/desktop (default: server)"
echo ''
case "$REPLY" in
    "")
        # Default platform type
        PLATFORM_TYPE="server"
        ;;
    server|desktop)
        PLATFORM_TYPE="$REPLY"
        ;;
    *)
        fail "Unknown parameter: $REPLY"
        ;;
esac

# Prevent the cloned repository from having insecure permissions. Failing to do
# so causes compinit() calls to fail with "command not found: compdef" errors
# for users with insecure umasks (e.g., "002", allowing group writability). Note
# that this will be ignored under Cygwin by default, as Windows ACLs take
# precedence over umasks except for filesystems mounted with option "noacl".
umask g-w,o-w

info "${BLUE}Installing Node.js environment...${NORMAL}\n"
env git clone https://github.com/creationix/nvm.git ~/.nvm && cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`
nvm install stable

info "${BLUE}Cloning dotfiles...${NORMAL}\n"
hash git >/dev/null 2>&1 || fails "Error: git clone of dotfiles repo failed"
env git clone --depth=1 https://github.com/weitingchou/dotfiles.git /tmp/dotfiles || fail "Error: git clone of dotfiles repo failed"

info "${BLUE}Checking zsh installation..."
if [ ! $(grep /zsh$ /etc/shells | wc -l) -ge 1  ]; then
    fail "${YELLOW}Zsh is not installed!${NORMAL} Please install zsh first!"
fi
ZSH_VERSION="$(zsh --version | cut -d' ' -f 2)"
version_gte "$ZSH_VERSION" "4.3.9" || fail "zsh version should be v4.3.9 or more (current: $ZSH_VERSION)"
unset ZSH_VERSION

info "${BLUE}Making default shell to zsh...${NORMAL}"
chsh -s $(which zsh)

info "${BLUE}Installing oh-my-zsh...${NORMAL}"
#bash -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# XXX: We don't want to start zsh right after finished the oh-my-zsh installation, since we still have works to do,
#      remove the 'env zsh' at the end of installation script
bash -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh) | sed -e 's/env zsh//g')"

info "${BLUE}Copying custom settings to oh-my-zsh...${NORMAL}"
cp /tmp/dotfiles/init/oh-my-zsh/themes/* $HOME/.oh-my-zsh/themes/
cp /tmp/dotfiles/init/oh-my-zsh/custom/* $HOME/.oh-my-zsh/custom/

info "${BLUE}Fetching vim source...${NORMAL}"
wget ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2 || fail "Error: fetch vim source failed"
tar xjvf vim-7.4.tar.bz2 -C /tmp
rm -f vim-7.4.tar.bz2

info "${BLUE}Fetching vimgdb patch...${NORMAL}"
env git clone --depth=1 https://github.com/weitingchou/vimgdb-for-vim7.4.git /tmp/vimgdb-for-vim7.4 || fail "Error: git clone of vimgdb patch failed"

info "${BLUE}Patching vim...${NORMAL}"
cd /tmp
patch -p0 < vimgdb-for-vim7.4/vim74.patch || fail "Error: patch vim failed"

info "${BLUE}Building patched vim...${NORMAL}"
cd vim74/src
make && make install

info "${BLUE}Copying vimgdb runtime...${NORMAL}"
mkdir $HOME/.vim
cp -rf /tmp/vimgdb-for-vim7.4/vimgdb_runtime/* $HOME/.vim

info "${BLUE}Installing neobundle...${NORMAL}"
curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh > install.sh || fail "Error: fetch neobundle failed"
bash ./install.sh

info "${BLUE}Installing powerline...${NORMAL}"
pip install --user powerline-status

if [[ "$PLATFORM_TYPE" == "desktop" ]]; then
    info "${BLUE}Installing powerline symbols/fonts...${NORMAL}"
    wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
    wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
    mkdir $HOME/.fonts
    mv PowerlineSymbols.otf $HOME/.fonts/
    fc-cache -vf $HOME/.fonts/
    mv 10-powerline-symbols.conf $HOME/.config/fontconfig/conf.d/
fi

info "${BLUE}Copying dotfiles...${NORMAL}"
cd /tmp/dotfiles
rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" \
    --exclude "README.md" --exclude "LICENSE-MIT.txt" -avh --no-perms . $HOME;

success "installation completed without errors"