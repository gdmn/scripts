#! /usr/bin/env bash

help() {
cat <<EOF
Watch given dir for created files using inotify-tools.

Usage:
	`basename $0` directory commands and parameters

The script executes [commands and parameters] [created file]
for every created file and DELETES the file.
EOF
}

fail() {
	echo $*
	echo "Run `basename $0` --help for help."
	exit 1
}

if [[ "$1" == '-h' || "$1" == '--help' ]]; then
	help
	exit 0
fi

if [[ "$1" == "" ]]; then
	fail "This script needs at least two parameters."
fi

pushd "$1" >/dev/null || fail "Cannot cd into the directory $1"
DIR="`pwd`/"
popd >/dev/null
shift

if [ ! -d "$DIR" ]; then
	fail "Directory $DIR does not exist."
fi

if [[ "$1" == "" ]]; then
	fail "This script needs at least two parameters."
fi

inotifywait -m -e close_write -r "$DIR" | \
	while read l; do \
		l=${l/*CLOSE /}; \
		[ -f "${DIR}${l}" ] && \
			$* "${DIR}${l}" && rm -f "${DIR}${l}" || \
			echo "Given command returned non-zero for ${DIR}${l}."
	done
