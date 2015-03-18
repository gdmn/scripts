#! /bin/bash

help() {
	echo 'Uruchamia mp3gain na folderze i podfolderach'
	echo 'Jeśli brak argumentów, skrypt jest uruchamiany w bieżącym katalogu.'
}

DONEMARKER="mp3gain_marker"

if [[ ($2 != "") && ($1 = "-d") ]]; then
	pushd "$2" > /dev/null
	echo `pwd`
	if [ ! -e $DONEMARKER ]; then
		mp3gain -t -c -p -a *mp3 *MP3
		touch $DONEMARKER
	else
		echo "marker found \"$DONEMARKER\""
	fi
	popd > /dev/null
	exit 0
elif [[ $1 != "" ]]; then
	DIR="$1"
else
	#DIR="`dirname $0`"
	DIR="`pwd`"
fi

help

#xargs -0 -I %
pushd "`dirname $0`" > /dev/null
SCRIPTLOCATION="`pwd`"
popd > /dev/null

pushd "$DIR" > /dev/null
DIR="`pwd`"
popd > /dev/null

echo $DIR
#. "${SCRIPTLOCATION}/.sync_rc"
find "${DIR}/" -type d -print0 | xargs -0 -I % $0 -d %
