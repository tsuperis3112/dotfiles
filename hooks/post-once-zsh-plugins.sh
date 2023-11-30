#!/bin/bash

TARGET="$HOME/.oh-my-zsh/custom/plugins"
PLUGINS=(
    zsh-syntax-highlighting
    zsh-completions
    zsh-autosuggestions
)

for plugin in ${PLUGINS[@]}; do
    if [ ! -d "${TARGET}/${plugin}" ]; then
        git clone https://github.com/zsh-users/${plugin} "${TARGET}/${plugin}"
    fi
done
