#!/bin/bash

anyenv init

readonly ANYENV_PLUGIN_DIR=$(anyenv root)/plugins
mkdir -p $ANYENV_PLUGIN_DIR

if ! [ -d $ANYENV_PLUGIN_DIR/anyenv-update ]; then
    git clone https://github.com/znz/anyenv-update.git ${ANYENV_PLUGIN_DIR}/anyenv-update
fi

