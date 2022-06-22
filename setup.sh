#!/bin/sh

TARGET_DIR=$(cd $(dirname $0); pwd)/files
eflg=0

if type "git" > /dev/null 2>&1; then
  git submodule init
  git submodule update --recursive --recommend-shallow --depth 1 
fi

for file in `\ls $TARGET_DIR`; do
	src_path=$TARGET_DIR/$file
	dst_path=$HOME/.$file

	if [ ! -e "$dst_path" ]; then
    echo "$src_path ===> $dst_path"
		ln -s $src_path $dst_path
	elif [ ! -L "$dst_path" ] || [ "$src_path" != `\readlink $dst_path` ]; then
		echo "Error: $dst_path is already exist" >&2
		eflg=1
	fi
done

. $HOME/.bashrc

exit $eflg
