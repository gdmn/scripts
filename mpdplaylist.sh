#! /usr/bin/env bash

## by dmn, http://devsite.pl

# DI.FM:
# wget -q -O - http://listen.di.fm/public3 | sed 's/},{/\n/g' | perl -n -e '/"key":"([^"]*)".*"playlist":"([^"]*)"/; print "$1\n"; open(F, ">di_$1.m3u"); $s = $2; $s =~ s/\\\//\//g;print F "$s"; close(F);'
# based on: http://mpd.wikia.com/wiki/Hack:di.fm-playlists

curl='curl --location --connect-timeout 4 --silent'
verbose=false
cmd='mpc add'
shopt -s nocasematch

debug() {
	if [ "$verbose" = true ]; then
		echo -e "$*" >&2
	fi
}

found() {
	debug " # $cmd $*"
	$cmd $*
}

parse() {
	parse_playlist () {
		grep '/' | sed 's/$//g' | while read k; do
			debug " > read $k"
			if [[ $k == HTTP* ]] ; then
				parse "$k"
			else
				k=${k/*=/}
				spaceless=${k// /}
				if [ "$k" == "$spaceless" ]; then
					parse "$k"
				fi
			fi
		done
	}

	parse_head() {
		local head="$2"
		echo "$head" | grep -i 'content-type:' | grep -i 'text/html' >/dev/null 2>&1
		local html=$?
		echo "$head" | grep -i 'content-length:' >/dev/null 2>&1 # streams do not have content length
		local contentlength=$?
		echo "$head" | grep -i 'content-disposition:' >/dev/null 2>&1 # playlist sometimes are attachments
		local attachment=$?

		debug "html? $html, contentlength? $contentlength, attachment? $attachment"

		if [[ $html -eq 0 ]]; then
			debug html
			$curl "$1" | sed 's/</\n</g' | grep '<a' | grep href | grep 'm3u\|pls' | \
				while read h; do
					debug " _ $h"
					h=${h##*href=\"}
					h=${h%%\"*}
					debug " _ $h"
					echo "$h" | parse_playlist
				done
		elif [[ $contentlength -eq 0 || $attachment -eq 0 ]]; then
			debug playlist
			$curl "$1" | parse_playlist
		else
			debug stream
			found "$1"
		fi
	}

	strip_redirects() {
		local head="$1"
		local begins=`echo "$head" | grep HTTP/1 | wc -l`
		if [ "$begins" -gt 1 ]; then
			debug "stripping redirects, found $begins"
			local result=''
			local count=0
			while [[ `echo "$result" | head -n 1` != *HTTP/1.?\ * ]]; do
				count=$(( $count + 1 ))
				result=`echo "$head" | tail -n $count`
			done
			echo "$result"
		else
			echo "$head"
		fi
	}

	buggy_head() {
		local temp=`mktemp`
		$curl -v "$1" 2>$temp | dd count=0 2>/dev/null
		local head=`cat $temp`
		head=`strip_redirects "$head"`
		rm -f $temp

		local head1=`echo "$head" | grep HTTP/1 | tail -n 1` # because of redirections
		if [[ $head1 == ?\ HTTP/1.?\ 200\ * ]] ; then
			debug 'i do not know yet'
			parse_head "$1" "$head"
			#$curl "$1" | parse_playlist
		else
			debug probably stream
			found "$1"
		fi
	}

	debug " > $1"
	if [ -f "$1" ]; then
		debug file
		cat "$1" | parse_playlist
	else
		head=`$curl --head "$1"`
		returned="$?"
		debug " # $curl --head $1 --> $returned"
		head=`strip_redirects "$head"`
		if [[ $returned -eq 52 || $returned -eq 56 ]]; then
			# sometimes icecast returns CURLE_GOT_NOTHING (52)
			# sometimes servers do not accept head requests... :/
			buggy_head "$1"
		elif [ $returned -eq 0 ]; then
			head1=`echo "$head" | grep HTTP/1 | tail -n 1` # because of redirections
			if [[ $head1 == HTTP/1.?\ 400\ * ]] ; then
				buggy_head "$1"
			elif [[ $head1 == HTTP/1.?\ 200\ * ]] ; then
				debug 'HTTP 200'
				parse_head "$1" "$head"
			else
				debug stream
				found "$1"
			fi
		else
			debug curl?
		fi
	fi
}

while [[ $# > 0 ]]; do
	arg="$1"
	case "$arg" in
		-h|--help)
			cat <<EOF
`basename $0` by dmn - parse playlists url
arguments:
	-h|--help - help
	-v|--verbose - debug output
	-c|--command X - set command to X
	U1 U2 U3... - try to parse these urls or files
examples:
	`basename $0` http://somafm.com/groovesalad.pls - add groovesalad to current playlist
	MPD_HOST=192.168.1.10 `basename $0` http://somafm.com/groovesalad.pls - use different host
	`basename $0` -c echo http://somafm.com/groovesalad.pls - show stream list
	`basename $0` -c echo http://www.16bit.fm/ - parse hrefs
	`basename $0` -c echo https://www.c9.fr/comment-nous-ecouter/ | mpv -playlist - - start playing found streams
	`basename $0` -c echo http://www.181.fm/index.php?p=mp3links
	`basename $0` -c echo http://www.house-radio.com/
	`basename $0` -c echo http://www.prw.pl/rds/info/pos%C5%82uchaj-radia
	`basename $0` -c echo http://www.listenlive.eu/poland.html
	`basename $0` http://yp.shoutcast.com/sbin/tunein-station.pls?id=327746
	`basename $0` http://dir.xiph.org/listen/493689/listen.m3u
	`basename $0` http://dir.xiph.org/listen/236666/listen.m3u
EOF
		;;
		-v|--verbose)
			verbose=true
		;;
		-c|--command)
			cmd="$2"
			debug "command set to $cmd"
			shift
		;;
		*)
			parse "$1"
		;;
	esac
	shift
done

