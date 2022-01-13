#! /usr/bin/env bash

IP=0.0.0.0

filter_hosts_hosts() {
	while read line; do
		if [[ "$line" =~ "127.0.0.1 "* ]] ; then
			echo "$IP ${line//* /}"
		elif [[ "$line" =~ "0.0.0.0 "* ]] ; then
			echo "$IP ${line//* /}"
		fi
	done
}

filter_dnsmasq_hosts() {
	while read line; do
		if [[ "$line" =~ "address=/"* ]] ; then
			 line="${line//*=\//}"
			 line="${line//\/*/}"
			 echo "$IP ${line}"
		fi
	done
}

filter_hosts() {
	while read line; do
		if [[ "$line" =~ "127.0.0.1 "* ]] ; then
			echo "address=/${line//* /}/$IP"
		fi
		if [[ "$line" =~ "0.0.0.0 "* ]] ; then
			echo "address=/${line//* /}/$IP"
		fi
	done
}

filter_dnsmasq() {
	while read line; do
		if [[ "$line" =~ "address=/"* ]] ; then
			line="${line//*=\//}"
            line="${line//\/*/}"
            echo "address=/${line//* /}/$IP"
		fi
	done
}

filter_nocomments() {
	while read line; do
		case "$line" in
			*'#'* )
				;;
			*'local'* )
				;;
			*) echo "$line"
				;;
		esac
	done
}

fetch_hosts() {
	for u in 'http://someonewhocares.org/hosts/hosts' ; do
		curl --silent "$u" | filter_nocomments | filter_hosts_hosts
	done

	for u in 'http://pgl.yoyo.org/adservers/serverlist.php?hostformat=dnsmasq&showintro=0&mimetype=plaintext' ; do
		curl --silent "$u" | filter_nocomments | filter_dnsmasq_hosts
	done
    
    for u in 'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts' ; do
		curl --silent "$u" | filter_nocomments | filter_hosts_hosts
	done
}

fetch() {
	for u in 'http://someonewhocares.org/hosts/hosts' ; do
		curl --silent "$u" | filter_nocomments | filter_hosts
	done

	for u in 'http://pgl.yoyo.org/adservers/serverlist.php?hostformat=dnsmasq&showintro=0&mimetype=plaintext' ; do
		curl --silent "$u" | filter_nocomments | filter_dnsmasq
	done

    for u in 'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts' ; do
		curl --silent "$u" | filter_nocomments | filter_hosts
	done
}

if [[ "hosts" == "$1" ]]; then
	fetch_hosts | sort | uniq
else
	fetch | sort | uniq
fi

