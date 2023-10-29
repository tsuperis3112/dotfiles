#!/bin/sh

cd "$(dirname $0)"

TARGET=../homefiles/oh-my-zsh/custom/plugins/zsh-syntax-highlighting

if [ ! -d "$TARGET" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "${TARGET}"
fi

