#! /usr/bin/env bash

PASSWORD='dmn'

# -viewonly
# -scale 0.8 -scale_cursor 1

vncsrv_main() {
	k=`mktemp`
	echo "$PASSWORD">$k
	x11vnc -passwdfile rm:$k -many $*
}

vncsrv_main $*

