#! /bin/bash

PASSWD='dmn'
PC=

if [[ $1 != "" ]]; then
	PC="$1"
fi
if [[ $PC == "" ]]; then
	echo "$0 address"
	exit 1
fi

k=`mktemp`
echo "${PASSWD}" | \
	/usr/bin/vncpasswd -f \
	> $k
vncviewer -passwd $k "${PC}"
