#! /usr/bin/env bash

koduj() {
	FLAC="$1"
	MP3="`echo $FLAC | sed 's/\.\w*$/\.mp3/'`"
	[ -r "$FLAC" ] || { echo can not read file \"$FLAC\" >&1 ; exit 1 ; } ;
	#ffmpeg -i "$1" -acodec libmp3lame -ab 192k -aq 2 "$MP3"
	ffmpeg -i "$1" -acodec libmp3lame -q:a 2 "$MP3"
}

while [[ "" != "$1" ]]; do
	koduj "$1"
	shift
done

