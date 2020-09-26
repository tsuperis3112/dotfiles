#!/bin/sh

SCRIPT_DIR=$(cd $(dirname $0); pwd)
eflg=0

if type "git" > /dev/null 2>&1; then
  git submodule update --init --recursive
fi

for file in `\ls $SCRIPT_DIR | grep -vE '(setup|clean)\.sh$'`; do
  if [ $file = "ssh" ]; then
		file="${file}/config"
	fi

	src_path=$SCRIPT_DIR/$file
	dst_path=$HOME/.$file

	if [ ! -e "$dst_path" ]; then
		ln -s $src_path $dst_path
	elif [ ! -L "$dst_path" ] || [ "$src_path" != `\readlink $dst_path` ]; then
		echo "Error: $file is exist" >&2
		eflg=1
	fi
done

. $HOME/.bashrc

exit $eflg
