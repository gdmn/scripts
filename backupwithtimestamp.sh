#! /usr/bin/env bash

########################################################################
# HELP

usage() {
	echo -e "Usage examples:\n"
	echo -e "compress: `basename $0` archive_prefix somefile anotherfile directory/"
}

########################################################################
# INIT

if [[ "" == "`which zstd`" ]]; then
	echo 'install zstd (zstandard compression)!'
	exit 3
fi

########################################################################
# COMPRESS

mkarchive() {
	cd .

    # checkpoint is not supported on freebsd
	#tar --checkpoint=1000 --checkpoint-action=dot
	tar -cf - "$@" | \
		zstd -T0 --long -o "${OUTPUTFILE}"
}

OUTPUTFILE="`pwd`/${1}_`date +%Y%m%d_%H%M%S`.tar.zstd"

########################################################################
# MAIN


if [ $# -lt 2 ] ; then
	usage
	exit 1
fi

shift

mkarchive "$@"

echo -e "To decompress, run: zstd -dc $OUTPUTFILE | tar -x -C outputdirectory/"
