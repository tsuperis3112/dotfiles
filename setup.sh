#!/bin/bash

cd "$(dirname $0)"
readonly ROOT_DIR="$(pwd)"

readonly DOTFILES_DIR=homefiles
readonly UTILITY_DIR=utils
readonly BACKUP_DIR=backups

readonly CACHEFILE=.skip_cache

# --------------------------------------------------
# Install submodules
# --------------------------------------------------

git submodule update --init --recursive

# --------------------------------------------------
# Functions
# --------------------------------------------------

function has_line() {
    if grep -q -s -x "$hashkey" "$CACHEFILE"; then
        return 0
    else
        return 1
    fi
}

function once_exec() {
    local hashkey="$(export_hashkey "$1"):script"
    if ! has_line "$hashkey"; then
        echo "$1"
        bash "$1"
        echo "${hashkey}" >> "$CACHEFILE"
    fi
}

function export_hashkey() {
    readonly rel_path=$1

    if [ -f "$rel_path" ]; then
        local hashkey=$(date -r "$rel_path" +%Y%m%d%H%M%S)
    else
        local hashkey=$(git submodule foreach -q "[ \$name = \"$rel_path\" ] && (echo \`git rev-parse HEAD\`) || true")
        if [ -z "$hashkey" ]; then
            local hashkey=$(cd "$rel_path"; git log -n 1 --pretty=format:%H)
        fi
    fi

    echo "${rel_path}:${hashkey}"
}

# create symbolic links
function add_link() {
    echo "$1 ===> $2"
    ln -s "$1" "$2"
}

# --------------------------------------------------
# Pre Script
# --------------------------------------------------

echo "run pre-scripts"

for file in ./hooks/pre-*.sh; do
    if [ -f "$file" ]; then
        once_exec "$file"
    fi
done

# --------------------------------------------------
# Setup Files
# --------------------------------------------------

echo "setup dotfiles"

for item in $(ls $DOTFILES_DIR); do
    rel_src_path=$DOTFILES_DIR/$item
    abs_src_path=$ROOT_DIR/$rel_src_path
    abs_dst_path=$HOME/.$item

    hashkey=$(export_hashkey "$rel_src_path")

    echo -e "\t$rel_src_path"

    if [ ! -e "$abs_dst_path" ]; then
        add_link "$abs_src_path" "$abs_dst_path"
    elif [ ! -L "$abs_dst_path" ]; then
        if ! has_line "$hashkey"; then
            echo -e -n "\t$abs_dst_path is already exist. Do you want to override? [y/N] "

            read OVERRIDE
            case $OVERRIDE in
                [yY]* )
                    mv "$abs_dst_path" "$BACKUP_DIR/$item"
                    add_link $abs_src_path $abs_dst_path
                    ;;
                * )
                    echo "\tcancel copy $abs_src_path"
                    echo "$hashkey" >> "$CACHEFILE"
                    ;;
            esac
        else
            echo -e "\tSKIP: $abs_src_path"
        fi
    elif [ "$abs_src_path" != "`\readlink $abs_dst_path`" ]; then
        echo -n "\t$abs_dst_path is already exist."
    fi
done

# --------------------------------------------------
# Apply Config
# --------------------------------------------------

source "$HOME/.bashrc"

# --------------------------------------------------
# Post Script
# --------------------------------------------------

echo "run post-scripts"

for file in ./hooks/post-*.sh; do
    if [ -f "$file" ]; then
        once_exec "$file"
    fi
done

