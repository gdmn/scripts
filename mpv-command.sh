#! /usr/bin/env bash

set -e

SOCKET=${MPVC_SOCKET:-/tmp/mpvsocket}

command() {
    # JSON preamble.
    local tosend='{ "command": ['
    # adding in the parameters.
    for arg in "$@"; do
        tosend="$tosend \"$arg\","
    done
    # closing it up.
    tosend=${tosend%?}' ] }'
    # send it along and ignore output.
    # to print output just remove the redirection to /dev/null
    echo $tosend | socat - $SOCKET
}

command "$@"
exit 0

mpv-command.sh quit
mpv-command.sh cycle pause
mpv-command.sh set pause yes
mpv-command.sh set pause no
mpv-command.sh playlist_next
mpv-command.sh playlist_prev

