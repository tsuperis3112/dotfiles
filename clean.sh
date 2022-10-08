#!/bin/bash

readonly ROOT_DIR=$(cd $(dirname $0); pwd)
readonly TARGET_DIR=$ROOT_DIR/files
readonly BACKUP_DIR=$ROOT_DIR/backups

source $ROOT_DIR/utils/io.sh

for file in `\ls $TARGET_DIR`; do
    src_path=$TARGET_DIR/$file
    backup_path=$BACKUP_DIR/$file
    dst_path=$HOME/.$file

    # rmove links
    if [ -L "$dst_path" ]; then
        rm $dst_path
    fi

    # recover backup
    if [ -e $backup_path ]; then
        if [ -e $dst_path ]; then
            warn "recovering backup is failed. $dst_path is exist."
        else
            mv "$backup_path" "$dst_path"
        fi
    fi
done
