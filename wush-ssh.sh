#! /usr/bin/env bash

f="${XDG_CONFIG_HOME:-$HOME/.config}/notifications-wush"

usage() {
cat << EOF
Usage:
$0 host

EOF
if [ -e "$f" ]; then
    echo "Currently available hosts:"
    cat $f | sed -r 's/ .+//' | sort | uniq
fi
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

if [ ! -e "$f" ]; then
    echo "$f not found"
    exit 1
fi

key="$(cat $f | grep "$@" | tail -n 1 | sed -r 's/.+ //')"
echo "key: $key"
len=${#key}
echo "length: $len"
if [ $len -ne 91 ]; then
    echo "not found"
    exit 1
fi
wush ssh "--auth-key=$key"
