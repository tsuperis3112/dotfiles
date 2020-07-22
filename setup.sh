#!/bin/sh

SCRIPT_DIR=$(cd $(dirname $0); pwd)
eflg=0

for file in `\ls $SCRIPT_DIR | grep -v setup.sh`; do
	src_path=$SCRIPT_DIR/$file
	dst_path=$HOME/.$file

        if [ $file = "ssh" ]; then
                ln -s $src_path/config $dst_path/config
	elif [ ! -e "$dst_path" ]; then
		ln -s $src_path $dst_path
	elif [ ! -L "$dst_path" ] || [ "$src_path" != `\readlink $dst_path` ]; then
		echo "Error: $file is exist" >&2
		eflg=1
	fi
done

exit $eflg
