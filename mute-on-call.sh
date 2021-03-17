#! /usr/bin/env bash

args="-o ControlMaster=auto -o ControlPath=~/.ssh/ssh-mux-%r@%h:%p -o ControlPersist=yes"
MUTE='for (( i=0; i < $( pacmd list-sinks | grep index | wc -l ) ; i++ )); do pacmd set-sink-mute $i 1; done'
UNMUTE='for (( i=0; i < $( pacmd list-sinks | grep index | wc -l ) ; i++ )); do pacmd set-sink-mute $i 0; done'

if (( $# != 1 )); then
    echo "Illegal number of parameters"
    exit 1
fi

host="$1"

echo "checking connection to $host..."
ssh $host $args -O check 2>/dev/null

if [ $? -ne 0 ]; then
  ssh $host $args -t true || \
  exit 2
fi

echo 'monitoring pacmd list-source-outputs...'

check() {
	pacmd list-source-outputs | grep 'state: RUNNING' >/dev/null && \
	  pacmd list-source-outputs | grep 'flags: START_CORKED' >/dev/null
	echo $?
}

while sleep 5; do
	if [ $(check) -eq 0 ]; then
		echo "mute $host"
		ssh $host $args -t "$MUTE" >/dev/null 2>&1
		while sleep 5; do
			if [ $(check) -ne 0 ]; then
				echo "unmute $host"
				ssh $host $args -t $UNMUTE >/dev/null 2>&1
				break
			fi
		done
	fi
done

