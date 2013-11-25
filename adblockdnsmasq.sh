#! /usr/bin/env bash

filter_hosts_hosts() {
	while read line; do
		if [[ "$line" =~ "127.0.0.1 "* ]] ; then
			echo "${line}"
		fi
	done
}

filter_dnsmasq_hosts() {
	while read line; do
		if [[ "$line" =~ "address=/"* ]] ; then
			 line="${line//*=\//}"
			 line="${line//\/*/}"
			 echo "127.0.0.1 ${line}"
		fi
	done
}

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

fetch_hosts() {
	for u in 'http://someonewhocares.org/hosts/hosts' ; do
		curl --silent "$u" | filter_hosts_hosts
	done

	for u in 'http://pgl.yoyo.org/adservers/serverlist.php?hostformat=dnsmasq&showintro=0&mimetype=plaintext' ; do
		curl --silent "$u" | filter_dnsmasq_hosts
	done
}

fetch() {
	for u in 'http://someonewhocares.org/hosts/hosts' ; do
		curl --silent "$u" | filter_hosts
	done

	for u in 'http://pgl.yoyo.org/adservers/serverlist.php?hostformat=dnsmasq&showintro=0&mimetype=plaintext' ; do
		curl --silent "$u" | filter_dnsmasq
	done
}

if [[ "hosts" == "$1" ]]; then
	fetch_hosts | sort | uniq
else
	fetch | sort | uniq
fi

