#! /bin/bash

########################################################################
# HELP

usage() {
	echo "Usage:"
	echo ""
	echo "- encrypt"
	echo -e "\tPASSWORD=abc `basename $0` -e somefile anotherfile directory/"
	echo ""
	echo "- decrypt"
	echo -e "\tPASSWORD=abc `basename $0` -d encrypted.tar.aes"
	echo ""
	echo "- list"
	echo -e "\tPASSWORD=abc `basename $0` -l encrypted.tar.aes"
}

########################################################################
# INIT

if [ ! -x `which openssl` ]; then
	echo 'install openssl!'
	exit 3
fi
if [ ! -x `which pv` ]; then
	echo 'install pv (pipeviewer)!'
	exit 3
fi

PASSWORD="${PASSWORD}"
#OUTPUTFILE=
OUTPUTFILE="`pwd`/encrypted_`date +%N`.tar.aes"

########################################################################
# CLEANUP

trap control_c SIGINT

cleanup() {
	PASSWORD=
	return $?
}

control_c() {
	echo -en "\n*** Ouch! Exiting ***\n"

	if [ -f ${OUTPUTFILE} ]; then
		echo "removing ${OUTPUTFILE}"
		rm -f ${OUTPUTFILE}
	fi
	cleanup
	exit $?
}

########################################################################
# ENCRYPT

encrypt() {
	cd .
	echo "Result: ${OUTPUTFILE}"

	#echo "tar -zcvf - $*"
	#tar -cf - . | pv -s $(du -sb . | awk '{print $1}') | gzip > out.tgz
	SIZE=$( du -scb $* | tail -1 | awk '{print $1}' )
	#SIZE=$(( ${SIZE}*1024/1000 ))
	tar -cf - $* | \
		pv -s $SIZE | \
		gzip | \
		R="${PASSWORD}" \
			openssl aes-256-cbc -salt -pass 'env:R' | \
		dd of=${OUTPUTFILE}
}

########################################################################
# DECRYPT

decrypt() {
	while [[ "$1" ]]; do
		echo "Decrypting of $1"
		pv "$1" | \
			R="${PASSWORD}" \
				openssl aes-256-cbc -d -salt -pass 'env:R'  | \
			tar -zx
		shift
	done
}

########################################################################
# LIST

list() {
	while [[ "$1" ]]; do
		echo "Listing of $1"
		cat "$1" | \
			R="${PASSWORD}" \
				openssl aes-256-cbc -d -salt -pass 'env:R'  | \
			tar -zt
		shift
	done
}

########################################################################
# ARGUMENTS

CMD=

while [[ "$1" ]]; do
	case $1 in
		-r | --random)
			PASSWORD="`openssl rand -base64 32`"
			echo "Using random password: ${PASSWORD}"
		;;
		-o )
			shift
			if [[ ("$1" == "") ]]; then
				usage
				exit 1
			fi
			OUTPUTFILE="$1"
		;;
		-d | --decrypt)
			shift
			CMD='decrypt'
			if [[ ("$1" == "") ]]; then
				usage
				exit 1
			fi
			break
		;;
		-e | --encrypt)
			shift
			CMD='encrypt'
			if [[ ("$1" == "") ]]; then
				usage
				exit 1
			fi
			break
		;;
		-l | --list)
			shift
			CMD='list'
			if [[ ("$1" == "") ]]; then
				usage
				exit 1
			fi
			break
		;;
		-h | --help )
			usage
			exit
		;;
		* )
			echo '?'
			usage
			exit 0
		;;
	esac
	shift
done

if [[ "${PASSWORD}" == "" ]]; then
	echo "Assign \${PASSWORD} environment variable!"
	exit 2
fi

if [[ $CMD ]]; then
	echo "Running: $CMD $*"
	$CMD $*
	RESULT=$?
	echo "Result of ${CMD}: ${RESULT}"
	exit $RESULT
else
	usage
fi
