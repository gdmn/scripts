#! /usr/bin/env bash

command -v enconv > /dev/null || \
	echo 'Install packet "enca"'

command -v enconv > /dev/null || \
	exit 1

DIR="`pwd`"

if [[ $1 != "" ]]; then
	DIR="$1"
fi

pushd "$DIR" > /dev/null
DIR="`pwd`"
popd > /dev/null

echo $DIR

find "${DIR}/" -type f \( -iname '*.srt' -o -iname '*.txt' \) -print0 | \
	xargs -0 -I % bash -c \
	"cp -fv '%' '%-windows1250.bak' && enconv -x UTF-8 -V '%'"

echo '  find . -iname "*1250.bak" -print0 | xargs -0 -I % rm -f "%"'

