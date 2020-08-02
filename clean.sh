#!/bin/sh

SCRIPT_DIR=$(cd $(dirname $0); pwd)
eflg=0

for file in `\ls $SCRIPT_DIR | grep -vE '(setup|clean)\.sh$'`; do
  if [ $file = "ssh" ]; then
		file="${file}/config"
	fi

	src_path=$SCRIPT_DIR/$file
	dst_path=$HOME/.$file

	if [ -L "$dst_path" ]; then
    rm $dst_path
	fi
done

exit $eflg
