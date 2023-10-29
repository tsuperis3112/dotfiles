#!/bin/sh

cd "$(dirname $0)"

TARGET=../homefiles/oh-my-zsh/custom/plugins/zsh-autosuggestions

if [ ! -d "$TARGET" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${TARGET}"
fi

