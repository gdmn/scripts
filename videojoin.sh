#! /usr/bin/env bash

## by dmn, http://devsite.pl

helpme() {
	echo "Usage:"
	echo "$0 file1 file2 file3...."
}

if [[ "" == "`which MP4Box`" ]]; then
	echo 'Install gpac package!'
	exit 3
fi

if [[ $1 == "" ]]; then
	helpme
	exit 1
fi

FILEOUT="$1"
FILEOUT="${FILEOUT}j.mp4"

C=

while [[ "" != "$1" ]]; do
	if [ -f "$1" ]; then
		C="${C} -cat $1"
	else
		echo "$1 - not found!"
	fi
	shift
done

MP4Box $C "${FILEOUT}"
