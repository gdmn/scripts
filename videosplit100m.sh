#! /usr/bin/env bash

## by dmn, http://devsite.pl

helpme() {
	echo "Usage:"
	echo "$0 file1 file2 file3...."
	echo ""
	echo "Example:"
	echo "find . -size +100M -iname '*mp4' -print0 | xargs -0 -I % $0 \"%\""
	echo "find . -size -100M -iname '*mp4' -print0 | xargs -0 -I % cp \"%\" ."
}

if [[ "" == "`which MP4Box`" ]]; then
	echo 'Install gpac package!'
	exit 3
fi

processfile() {
	SIZE=`stat --printf="%s" "$1"`
	CMD=''

	CREATED=`date -r "$1" +%F`

	if [[ $SIZE -gt 150000000 ]]; then
		echo "#### File $1 is greater than 150MB"
		CMD="-split-size 100000"
	elif [[ $SIZE -gt 100000000 ]]; then
		echo "### File $1 is greater than 100MB"
		CMD="-split-size 77000"
	else
		echo "## File $1 is less than 100MB";
	fi

	if [[ "" != "$CMD" ]]; then
		MP4Box -split-size 100000 "$1"
	fi

}

if [[ $1 == "" ]]; then
	helpme
	exit 1
fi

while [[ "" != "$1" ]]; do
	if [ -f "$1" ]; then
		processfile "$1"
	else
		echo "$1 - not found!"
	fi
	shift
done
