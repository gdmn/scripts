#! /bin/bash

PASSWORD='dmn'

vncsrv_main() {
	k=`mktemp`
	echo "$PASSWORD">$k
	x11vnc -passwdfile rm:$k -many $*
}

if [[ "$1" != "" ]]; then
	DISPLAY="$1"
else
	DISPLAY=':0'
fi

if [[ "$2" != "" ]]; then
	RES="$2"
else
	RES=''
fi
MAX=`xrandr 2>/dev/null | grep maximum | sed 's/.*,//g' | sed 's/.*maximum //g' | sed 's/\W//g'`

#trap 'xrandr -display :0 -s 1920x1200'
if [[ "$RES" != "" ]]; then
	xrandr -display $DISPLAY -s $RES
fi

vncsrv_main -display $DISPLAY

if [[ "$RES" != "" ]]; then
	xrandr -display $DISPLAY -s $MAX
fi
