#! /usr/bin/env bash

up() {
	CopyCmd Cloud put -r "$1" /backup
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

