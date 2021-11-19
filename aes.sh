#! /usr/bin/env bash

########################################################################
# HELP

usage() {
	echo -e "Usage examples:\n"
	echo -e "encrypt: \tPASSWORD=abc `basename $0` -e somefile anotherfile directory/"
	echo -e "decrypt: \tPASSWORD=abc `basename $0` -d encrypted.tar.zstd.aes"
	echo -e "list:    \tPASSWORD=abc `basename $0` -l encrypted.tar.zstd.aes"
	echo ""
	echo "Arguments:"
	echo -e "\t-e  \t--encrypt     \tencrypt given file(s) to current directory or file specified with \"-o\" argument"
	echo -e "\t-x  \t--sfx         \tcreate self extracting encrypted archive"
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
if [[ "" == "`which zstd`" ]]; then
	echo 'install zstd (zstandard compression)!'
	exit 3
fi

PASSWORD="${PASSWORD}"
GENERATEINFO=
OUTPUTFILE="`pwd`/encrypted_`date +%Y%m%d_%H%M%S`.tar.zstd.aes"
INFOFILE="${OUTPUTFILE}.info"
PASSWORDARGUMENTS=
CRYPTARGUMENTS="enc -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt"
COMPRESS="zstd -T0 --long --stdout"
DECOMPRESS="zstd -d --stdout"

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

	local tarStream=
	if [[ $# -eq 1 ]] && [[ $1 == *.tar ]]; then
		tarStream="cat "$1""
		echo "Detected only one argument which looks like a tar archive. Not calling tar command on it."
	else
		tarStream="tar --checkpoint=1000 --checkpoint-action=dot -cf - $*"
	fi

	$tarStream | \
		$COMPRESS | \
		R="${PASSWORD}" \
				openssl ${CRYPTARGUMENTS} ${PASSWORDARGUMENTS} | \
				dd of=${OUTPUTFILE}
}

encrypt_sfx() {
	cd .
	if [[ "1" == "${GENERATEINFO}" ]]; then
		echo "Result: ${OUTPUTFILE} with ${INFOFILE}" | tee -a ${INFOFILE}
	else
		echo "Result: ${OUTPUTFILE}"
	fi

cat > ${OUTPUTFILE} <<SCRIPT_TOP
#!/bin/bash

echo -n "Extracting... "
sta=\$((\`grep -an "^EOS$" \$0 | cut -d: -f1\` + 1))
tail -n+\${sta} \$0 | openssl ${CRYPTARGUMENTS} -d | zstd -d --stdout | tar -x --checkpoint=1000 --checkpoint-action=dot
exit 0
EOS
SCRIPT_TOP

	local tarStream=
	if [[ $# -eq 1 ]] && [[ $1 == *.tar ]]; then
		tarStream="cat "$1""
		echo "Detected only one argument which looks like a tar archive. Not calling tar command on it."
	else
		tarStream="tar --checkpoint=1000 --checkpoint-action=dot -cf - $*"
	fi

	$tarStream | \
		$COMPRESS | \
		R="${PASSWORD}" \
				openssl ${CRYPTARGUMENTS} ${PASSWORDARGUMENTS} | \
				dd oflag=append conv=notrunc of=${OUTPUTFILE}

	mv "${OUTPUTFILE}" "${OUTPUTFILE}.sh"
	chmod +x "${OUTPUTFILE}.sh"
}

########################################################################
# DECRYPT

decrypt() {
	while [[ "$1" ]]; do
		echo "Decrypting $1"
		cat "$1" | \
			R="${PASSWORD}" \
				openssl ${CRYPTARGUMENTS} -d ${PASSWORDARGUMENTS} | \
				$DECOMPRESS | \
				tar --checkpoint=1000 --checkpoint-action=dot -x
		shift
	done
}

########################################################################
# LIST

list() {
	while [[ "$1" ]]; do
		echo "Listing $1"
		cat "$1" | \
			R="${PASSWORD}" \
				openssl ${CRYPTARGUMENTS} -d ${PASSWORDARGUMENTS} | \
				$DECOMPRESS | \
				tar -t
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
		-x | --sfx)
			shift
			CMD='encrypt_sfx'
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
