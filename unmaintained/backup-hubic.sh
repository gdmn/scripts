#! /usr/bin/env bash

SWIFT_PATH="${HOME}/.config/hubiC/swift"

export ST_USER='hubic' 

help() { #{{{
cat << EOF
Create $SWIFT_PATH file with lines:
export ST_AUTH=https://hubic2swiftgate_page.com/auth/v1.0/
export ST_KEY=password
How to setup auth server: https://github.com/oderwat/hubic2swiftgate
EOF
} #}}}

check_config() { #{{{
	if [[ -e $SWIFT_PATH && "$1" != "-h" && "$1" != "--help" ]]; then
		. $SWIFT_PATH
	else
		help
		exit 1
	fi
	if [[ -z $ST_AUTH || -z $ST_KEY ]]; then
		help
		exit 2
	fi
}
check_config $1 #}}}

check_commands() { #{{{
	command -v swift >/dev/null 2>&1 || { echo >&2 "python2-swiftclient not installed"; exit 6; }
}
check_commands #}}}

up() {
	local d="backup/`basename "$1"`"
	swift --insecure upload --changed --object-name "$d" default "$1"
		#\ 2>&1 | grep -v InsecureRequest
	#list default --prefix "$d"
}

if [[ "" == "$1" ]]; then
	echo "Usage:"
	echo "$0 file_to_upload file_to_upload directory_to_upload"
	exit 1
fi

while [[ "" != "$1" ]]; do
	up "$1"
	shift
done

