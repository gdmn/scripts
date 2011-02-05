#! /bin/bash

## by dmn, http://devsite.pl


DESTINATION="/home/dmn/Obrazy/foto"

helpme() {
	echo "$0 mv|cp file1 file2 file3...."
}

processfile() {
	CREATED=`date -r "$2" +%F`
	mkdir -p "${DESTINATION}/${CREATED}"
	echo "$1 $2 ${DESTINATION}/${CREATED}/"
	$1 "$2" "${DESTINATION}/${CREATED}/"
}

if [[ $1 == "mv" ]]; then
	echo "Moving to ${DESTINATION}"
elif [[ $1 == "cp" ]]; then
	echo "Coping to ${DESTINATION}"
else
	helpme
	exit 1
fi

OPERATION="$1"
shift

while [[ "" != $1 ]]; do
	if [ -f "$1" ]; then
		processfile $OPERATION "$1"
	else
		echo "$1 - not found!"
	fi
	shift
done
