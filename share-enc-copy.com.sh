#! /usr/bin/env bash

if [[ "" == "$1" ]]; then
	echo "Usage:"
	echo "$0 file_to_upload file_to_upload directory_to_upload"
	exit 1
fi

genpasswd() {
	#date|md5sum|tr -dc 0-9|head -c8
	 </dev/urandom tr -dc 'a-z' | head -c 8
}

TEMP=`tempfile -p qs -s .7z`
PASSWD=`genpasswd`

up() {
	# /qs/ mustnot be excluded from sync!
	CopyCmd Cloud put "$1" /qs
	local p="/qs/`basename $1`"
	CopyCmd Cloud link -regex "$p"
	echo "Password: $PASSWD"
}

compress() {
	local d=`dirname "$TEMP"`
	local f=`basename "$TEMP"`
	7z a "-p${PASSWD}" -mhe=on -mx=3 \
		"-o$d" "$f" $* || \
		rm -f "$TEMP"
}

compress $*
if [ -e "$TEMP" ]; then
	up "$TEMP"
	rm -f "$TEMP"
fi

