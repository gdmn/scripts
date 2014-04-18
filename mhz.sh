#! /usr/bin/env bash

grep "cpu MHz" /proc/cpuinfo | \
	( s=0; c=0; \
	while read l; do \
		l="${l//*: /}"; l="${l//.*/}"; \
		c=$(( c+1 )); s=$(( s+l )); \
	done; \
	echo "$(( s/c ))" )

