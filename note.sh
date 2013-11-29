#! /usr/bin/env bash

pushd $HOME > /dev/null || exit -1
	echo -ne "`date`\n$*\n---------\n" >> notes.txt
popd > /dev/null

