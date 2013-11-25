#! /usr/bin/env bash

filter_hosts() {
	while read line; do
		if [[ "$line" =~ "127.0.0.1 "* ]] ; then
			echo "address=/${line//* /}/127.0.0.1"
		fi
	done
}

filter_dnsmasq() {
	while read line; do
		if [[ "$line" =~ "address=/"* ]] ; then
			echo "${line//* /}"
		fi
	done
}

fetch() {
	for u in 'http://someonewhocares.org/hosts/hosts' ; do
		curl --silent "$u" | filter_hosts
		#echo "$u" | filter_hosts
	done

	for u in 'http://pgl.yoyo.org/adservers/serverlist.php?hostformat=dnsmasq&showintro=0&mimetype=plaintext' ; do
		curl --silent "$u" | filter_dnsmasq
	done
}

fetch | sort | uniq

