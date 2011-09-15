#! /bin/bash

## by dmn, http://devsite.pl

TEXT=""
PX="1280"
QUALITY="70"

helpme() {
	echo "$0 [-t text] [-s sizeinpixels] file1 file2 file3...."
}

processfile() {
	CREATED=`date -r "$1" +%F`
	#NEWNAME=`echo $1 | sed "s/\./_${QUALITY}_${PX}\./"`
	NEWNAME=`echo $1 | sed -r "s/\.([^\.]+)$/_${QUALITY}_${PX}.jpg/"`
	echo "Creating $NEWNAME"
	if [[ "" != $TEXT ]]; then
		#TEXT="$TEXT [$CREATED]"
		# -strip --> usunięcie EXIF
		convert "$1" -resize "${PX}x${PX}" -quality "${QUALITY}%" -font 'Droid Sans' -pointsize 18 -draw "gravity SouthEast
fill black text 12,12 '$TEXT'
fill white text 10,10 '$TEXT'" "${NEWNAME}"
	else
		convert "$1" -resize "${PX}x${PX}" -quality "${QUALITY}%" "${NEWNAME}"
	fi
}

if [[ $1 == "" ]]; then
	helpme
	exit 1
fi

if [[ "-t" == $1 ]]; then
	shift
	TEXT="$1"
	shift
fi

if [[ "-s" == $1 ]]; then
	shift
	PX="$1"
	shift
fi

while [[ "" != $1 ]]; do
	if [ -f "$1" ]; then
		processfile "$1"
	else
		echo "$1 - not found!"
	fi
	shift
done
