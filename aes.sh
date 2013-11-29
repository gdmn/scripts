#! /usr/bin/env bash

########################################################################
# HELP

usage() {
	echo -e "Usage examples:\n"
	echo -e "encrypt: \tPASSWORD=abc `basename $0` -e somefile anotherfile directory/"
	echo -e "decrypt: \tPASSWORD=abc `basename $0` -d encrypted.tar.aes"
	echo -e "list:    \tPASSWORD=abc `basename $0` -l encrypted.tar.aes"
	echo ""
	echo "Arguments:"
	echo -e "\t-e  \t--encrypt     \tencrypt given file(s) to current directory or file specified with \"-o\" argument"
	echo -e "\t-d  \t--decrypt     \tdecrypt given file(s) to current directory"
	echo -e "\t-l  \t--list        \tlist content of the file"
	echo -e "\t-r  \t--random      \tgenerate random password for encrypt"
	echo -e "\t    \t              \timplies \"-s\""
	echo -e "\t-s  \t--statusfile  \tgenerate information file with password during encrypt"
	echo -e "\t-o  \t--output      \tuse given file as output for encryption"
	echo -e "\nNotes:\n- if \${PASSWORD} environment variable is not set and \"-r\" is not given, password is read from stdin"

}

########################################################################
# INIT

if [[ "" == "`which openssl`" ]]; then
	echo 'install openssl!'
	exit 3
fi
if [[ "" == "`which pv`" ]]; then
	echo 'install pv (pipeviewer)!'
	exit 3
fi

PASSWORD="${PASSWORD}"
GENERATEINFO=
#OUTPUTFILE=
OUTPUTFILE="`pwd`/encrypted_`date +%Y%m%d_%H%M%S`.tar.aes"
INFOFILE="${OUTPUTFILE}.info"
PASSWORDARGUMENTS=
CRYPTARGUMENTS="aes-256-cbc -salt"

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
		rm -f ${INFOFILE}
	fi
	cleanup
	exit $?
}

########################################################################
# ENCRYPT

encrypt() {
	cd .
	if [[ "1" == "${GENERATEINFO}" ]]; then
		echo "Result: ${OUTPUTFILE} with ${INFOFILE}" | tee -a ${INFOFILE}
	else
		echo "Result: ${OUTPUTFILE}"
	fi

	SIZE=$( du -scb $* | tail -1 | awk '{print $1}' )
	tar -cf - $* | \
		pv -s $SIZE | \
		gzip | \
		R="${PASSWORD}" \
				openssl ${CRYPTARGUMENTS} ${PASSWORDARGUMENTS} | \
		dd of=${OUTPUTFILE}
}

########################################################################
# DECRYPT

decrypt() {
	while [[ "$1" ]]; do
		echo "Decrypting of $1"
		pv "$1" | \
			R="${PASSWORD}" \
				openssl ${CRYPTARGUMENTS} -d ${PASSWORDARGUMENTS} | \
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
				openssl ${CRYPTARGUMENTS} -d ${PASSWORDARGUMENTS} | \
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
			GENERATEINFO='1'
			date | tee -a ${INFOFILE}
			echo "Using random password: ${PASSWORD}" | tee -a ${INFOFILE}
		;;
		-s | --statusfile)
			GENERATEINFO='1'
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

PASSWORDARGUMENTS="-pass env:R"
if [[ "" == "${PASSWORD}" ]]; then
	PASSWORDARGUMENTS=
fi

if [[ $CMD ]]; then
	echo "Running: $CMD $*"
	if [[ "${PASSWORD}" == "" ]]; then
		echo "Note, that you can assign \${PASSWORD} environment variable"
	fi
	$CMD $*
	RESULT=$?
	echo "Result of ${CMD}: ${RESULT}"
	exit $RESULT
else
	usage
fi
