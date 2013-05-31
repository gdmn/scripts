#! /usr/bin/env bash

BTSYNCCONF="${HOME}/opt/btsync/btsync.conf"
BTSYNC="${HOME}/opt/btsync/btsync"

dirs() {
	grep \"dir\" "${BTSYNCCONF}" | \
		while read k; do
			#echo "1: $k"
			k=${k#*:}
			k=${k%%,*}
			k=${k//\"/}
			echo $k
		done
}

dirs | \
	while read d; do
		mkdir -p "$d"
		echo "Shared folder: $d"
	done

$BTSYNC --config $BTSYNCCONF

