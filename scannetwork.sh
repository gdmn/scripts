#! /usr/bin/env bash

ips=`ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | sed 's/.*inet addr://' | sed 's/ .*//' | sed 's/[0-9]*$//'`
if [ "$ips" == "" ]; then
	ips=`ifconfig | grep 'inet ' | grep -v '127.0.0.1' | sed 's/.*inet //' | sed 's/ .*//' | sed 's/[0-9]*$//'`
fi
echo "ips: \"${ips}\""

for ip in $ips ; do
	x=1
	echo "scanning ${ip}0/24"
	while [ $x -lt "255" ]; do
		( ping -i 0.2 -W 1 -c 2 ${ip}${x} | \
			grep "bytes from" | \
			awk '{print $4 " up"}' | \
			sort | \
			uniq ) &
		let x++
	done
done

