#! /usr/bin/env bash

echo 'Notify when maven process finishes'

mvn='org.codehaus.plexus.classworlds.launcher.Launcher'
notify='notify-send'
args='-t 10000 -i applications-engineering-symbolic'

laststate=0
while sleep 2; do
	currentstate=$(ps a | grep $mvn | grep -v grep | wc -l)
	if [ $currentstate -lt $laststate ]; then
		$notify $args "Maven process has just finished. Currently running: ${currentstate}."
	fi
	laststate=$currentstate
	if [ $currentstate -eq 0 ]; then
		sleep 8
	fi
done

