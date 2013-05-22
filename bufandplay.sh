#! /bin/bash

BUFDIR="/mnt/ram"

if [ "$#" == "0" ]; then
	N=`basename "$0"`
	echo "Usage: $N [-a] file1 file2 ... fileN"
	echo ""
	echo "Copy files to $BUFDIR and append them to MOC playlist"
	echo ""
	echo "Parameters:"
	echo "  -a - do not clear playlist (autoplay is also off)"
	echo ""
	exit 1
fi

mocp -S

FIRST=
CLEANED=

if [[ "-a" == "$1" ]]; then
	CLEANED='yes'
	shift
else
	mocp -c
fi


while (( "$#" )); do
	#[[ ! -z $i ]] && continue
	NAME=`basename "$1"`
	#echo "adding $NAME"
	cp -f -v "$1" "${BUFDIR}/"
	mocp -a "${BUFDIR}/${NAME}"
	shift
	[[ "$FIRST" ]] && continue || \
		( [[ ! "$CLEANED" ]] && mocp -p )
	FIRST="no"
done

