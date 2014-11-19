#! /usr/bin/env bash

HUBIC_USER_PATH="${HOME}/.config/hubiC/hubic-user"
HUBIC_PASSWORD_PATH="${HOME}/.config/hubiC/hubic-password"
HUBIC_BASE="${HOME}/hubiC"
exe='/usr/bin/hubic'

if [ ! -f $HUBIC_PASSWORD_PATH ]; then
	echo "Create $HUBIC_PASSWORD_PATH file with password!"
	exit 2
fi

if [ ! -f $HUBIC_USER_PATH ]; then
	echo "Create $HUBIC_USER_PATH file!"
	exit 3
fi

. $HUBIC_USER_PATH
if [ -z $HUBIC_USER ]; then
	echo "Create $HUBIC_USER_PATH file with line 'export HUBIC_USER=username'!"
	exit 4
fi

if [ ! -d $HUBIC_BASE ]; then
	echo "Create $HUBIC_BASE directory!"
	exit 5
fi

if [ ! -x $exe ]; then
	echo "Executable $exe not found!"
	exit 6
fi

dbus() {
	if [ -f /tmp/hubic.dbus ]; then
		echo 'Using saved hubic.dbus'
		. /tmp/hubic.dbus
	elif [ ! -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
		echo "Found running dbus-daemon in environment"
	else
		echo "Trying to find dbus-daemon in other processes"
		ps -ax | grep dbus-daemon | grep ' --session' | grep -v grep | \
			awk '{print($1);}' | while read k; do \
			grep -sz "^DBUS_SESSION_BUS_ADDRESS=" /proc/$k/environ | \
			xargs -0 -I % echo "%";  done | \
			tail -n 1 > /tmp/hubic.dbus
		. /tmp/hubic.dbus
	fi
	if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
		addr=`dbus-daemon --session --fork --print-address`
		echo "Started dbus-daemon $addr"
		echo "export DBUS_SESSION_BUS_ADDRESS=$addr" > /tmp/hubic.dbus
		export DBUS_SESSION_BUS_ADDRESS=$addr
	else
		echo "export DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS" > /tmp/hubic.dbus
	fi
}

login() {
	dbus
	pid=`ps -ef | grep hubiC.exe | grep main-loop | grep -v grep | awk '{print $2}'`
	if [ -z "$pid" ]; then
		echo "Starting using DBUS $DBUS_SESSION_BUS_ADDRESS"
		$exe login "--password_path=$HUBIC_PASSWORD_PATH" "$HUBIC_USER" "$HUBIC_BASE"
		$exe start
	else
		echo 'Process was found. Doing nothing.'
		$exe status
	fi
}

stop() {
	dbus
	$exe stop
	sleep 2
	pid=`ps -ef | grep hubiC.exe | grep main-loop | grep -v grep | awk '{print $2}'`
	if [ ! -z "$pid" ]; then
		echo kill $pid
		kill $pid
	fi
	rm -f /tmp/hubic.dbus
}

cmd() {
	dbus
	echo "Running $1 using $DBUS_SESSION_BUS_ADDRESS"
	$exe $1
}

case "$1" in
	'stop') stop;;
	'down') stop;;
	'status') cmd status;;
	*) login;;
esac

