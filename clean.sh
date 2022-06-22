#!/bin/sh

TARGET_DIR=$(cd $(dirname $0); pwd)/files

for file in `\ls $TARGET_DIR | grep -vE '(setup|clean)\.sh$'`; do
	src_path=$TARGET_DIR/$file
	dst_path=$HOME/.$file

	if [ -L "$dst_path" ]; then
		rm $dst_path
	fi
done
