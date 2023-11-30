#!/bin/bash

ROOT="$(cd $(dirname $0)/..; pwd)"
SRCDIR="$ROOT/files/themes"
TARGET="$HOME/.oh-my-zsh/custom/themes"

for src in "$SRCDIR"/*".zsh-theme"; do
    if [ ! -f "$src" ]; then
        continue
    fi
    f=${src##"${SRCDIR}/"}

    dst="${TARGET}/$f"
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -f "$dst" ]; then
        continue
    fi

    ln -s "$src" "$dst"
done
