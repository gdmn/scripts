#! /bin/bash

PASSWORD='dmn'

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

k=`mktemp`
echo "$PASSWORD">$k
x11vnc -display $DISPLAY -passwdfile rm:$k -many

if [[ "$RES" != "" ]]; then
	xrandr -display $DISPLAY -s $MAX
fi
