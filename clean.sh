#!/bin/bash

readonly ROOT_DIR=$(cd $(dirname $0); pwd)
readonly TARGET_DIR=$ROOT_DIR/files
readonly BACKUP_DIR=$ROOT_DIR/backups

readonly SKIP_CACHE=$ROOT_DIR/.skip_cache

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
        if [ ! -e $dst_path ]; then
            mv "$backup_path" "$dst_path"
        else
            echo -n "$dst_path is already exist. Do you want to override it? [yN] "
            read OVERRIDE

            case $OVERRIDE in
                [yY])
                    warn "override $dst_path"
                    mv "$backup_path" "$dst_path"
                    ;;
            esac
        fi
    fi

    rm -f "$SKIP_CACHE"
done
