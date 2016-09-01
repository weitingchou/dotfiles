#!/usr/bin/env bash

set -e

OSTYPE=`uname`
case "$OSTYPE" in
  Darwin)
    bash -c "$(curl -fsSL https://raw.github.com/weitingchou/dotfiles/master/scripts/install_macos.sh)"
    ;;
  Linux)
    # Currently it only supports Ubuntu distribution
    bash -c "$(curl -fsSL https://raw.github.com/weitingchou/dotfiles/master/scripts/install_ubuntu.sh)"
    ;;
  *)
    printf "\r\033[2K  [\033[0;31mFAIL\033[0m] Unknown OS type: $OSTYPE, we only support ubuntu and macos\n"
    exit
    ;;
esac

