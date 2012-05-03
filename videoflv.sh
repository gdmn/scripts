#! /bin/bash

## by dmn, http://devsite.pl

helpme() {
	echo "Usage:"
	echo "$0 file1 file2 file3...."
	echo ""
	echo "sleep 1h && find . -iname '*mp4' -print0 | xargs -0 -I % /home/dmn/Dropbox/Projects/scripts/videoflv.sh "%""
	echo "Example:"
	echo "find . -size +100M -iname '*mp4' -print0 | xargs -0 -I % $0 \"%\""
	echo "find . -iname '*flv' -print0 | xargs -0 -I % cp \"%\" ."
}

if [[ "" == "`which ffmpeg`" ]]; then
	echo 'Install ffmpeg package!'
	exit 3
fi

processfile() {
	SIZE=`stat --printf="%s" "$1"`
	FILEIN="$1"
	FILEOUT=`basename "$1"`
	FILEOUT="${FILEOUT}.flv"

	if [[ -f "$FILEOUT" ]]; then
		echo "File \"$FILEOUT\" already exists!"
	else
		#touch "$FILEOUT"
		ffmpeg -i "$FILEIN" -vf 'scale=-1:min(480\,ih)' -acodec libmp3lame -r 25 -ar 22050 -ac 2 -ab 48k -b:v 1200k -f flv "$FILEOUT"
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
