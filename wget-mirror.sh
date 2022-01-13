#! /usr/bin/env bash

usage() {
	echo -e "Usage:\n"
	echo -e "`basename $0` [directory] url"
}

if [ $# -eq 2 ]; then
	wget --mirror -p --convert-links -P "$1" "$2"
elif [ $# -eq 1 ]; then
	wget --mirror -p --convert-links -P ./ "$1"
else
	usage
	exit 1
fi

