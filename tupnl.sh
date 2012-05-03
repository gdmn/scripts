#! /bin/bash

sudo netstat -tupnl | \
	awk '{print($7);}' | \
	grep . | \
	grep -v Address | \
	uniq