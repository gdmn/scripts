#! /usr/bin/env bash

NETWORK='wlan0'
MAC='c0:65:99:76:2b:68'

#hash sudo 2>/dev/null      || { echo >&2 "I require sudo but it's not installed.  Aborting."; exit 1; }

command -v sudo       >/dev/null 2>&1 || { echo >&2 "Required sudo not installed."; exit 1; }
command -v curlftpfs  >/dev/null 2>&1 || { echo >&2 "Required curlftpfs not installed."; exit 1; }
command -v arp-scan   >/dev/null 2>&1 || { echo >&2 "Required arp-scan not installed."; exit 1; }

echo "Searching for Galaxy on ${NETWORK}..."
ip=`sudo arp-scan --interface=$NETWORK --localnet | grep $MAC | sed 's/\s.*//'`

if [ "" != "$ip" ]; then
	echo "Found on $ip"
	d=/mnt/ram/galaxy
	mkdir -p "$d"
	curlftpfs "ftp://ftp:314@${ip}:2121" "$d" && \
		echo "Mounted in $d" || \
		echo "Failed"
else
	echo "Galaxy on $NETWORK network not found"
fi

