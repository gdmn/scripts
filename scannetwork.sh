#! /usr/bin/env bash

#ips=`ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | sed 's/.*inet addr://' | sed 's/ .*//' | sed 's/[0-9]*$//'`
#if [ "$ips" == "" ]; then
#	ips=`ifconfig | grep 'inet ' | grep -v '127.0.0.1' | sed 's/.*inet //' | sed 's/ .*//' | sed 's/[0-9]*$//'`
#fi
ips=`ip -family inet -oneline address | grep -v '127.0.0' | grep -v 'inet 169.254' | sed 's/.*inet //' | sed 's/\/.*//'| sed 's/[0-9]*$//'`
ips_nmap=`ip -family inet -oneline address | grep -v '127.0.0' | grep -v 'inet 169.254' | sed 's/.*inet //' | sed 's/ .*//'`

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
			# ( nc -w 1 ${ip}${x} 22 >/dev/null 2>&1 && echo "${ip}${x}:22 up" ) &
		let x++
	done
done

#nmap -sn "$ips_nmap"

