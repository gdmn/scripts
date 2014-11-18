#! /usr/bin/env bash

## https://www.digitalocean.com/community/tutorials/how-to-use-duplicity-with-gpg-to-securely-automate-backups-on-ubuntu
## http://www.debian-administration.org/article/209/Unattended_Encrypted_Incremental_Network_Backups_Part_1
## https://help.ubuntu.com/community/DuplicityBackupHowto

EXCLUDE_FILELIST=/tmp/duplicity-excuded-list
ID_RSA=/root/.ssh/id_rsa
CONFIG=/root/backup-duplicity.conf

check_config() { #{{{
	if [[ -e $CONFIG && "$1" != "-h" && "$1" != "--help" ]]; then
		. $CONFIG
	else
cat << EOF
Configuration file $CONFIG example content:
export PASSPHRASE='gpgpassword'
export ENCRYPT_KEY='AA42A7AA'
run() {
	DESTINATION=file:///tmp/\`/usr/bin/hostname\`
	backup /etc \${DESTINATION}/etc
	backup /root \${DESTINATION}/root
	backup /home \${DESTINATION}/home --exclude **/var
}
End of example content.

GPG howto:
GENERATE KEYS:
	gpg --gen-key; gpg --list-keys

EXPORT:
	gpg --export-secret-key AA42A7AA | base64 -w 0 > secret.asc
	gpg --export AA42A7AA | base64 -w 0 > public.asc

IMPORT:
	cat secret.asc|base64 -d|gpg --import
	cat public.asc|base64 -d|gpg --import
	gpg --edit AA42A7AA
	type: "trust"
	type: "5"
EOF
		exit 1
	fi
}
check_config $1 #}}}

check_commands() { #{{{
	command -v duplicity >/dev/null 2>&1 || { echo >&2 "duplicity not installed"; exit 6; }
	command -v gpg >/dev/null 2>&1 || { echo >&2 "gpg not installed"; exit 6; }
}
check_commands #}}}

check_root() { #{{{
	if [ `id -u` != 0 ]; then
		echo "You are not root!"
		exit -1
	fi
}
check_root #}}}

check_key() { #{{{
	key=`gpg --list-keys|grep -v gpg|grep pub|grep $ENCRYPT_KEY|sed 's/.*\///' | sed 's/\ .*//g'`
	if [[ "$key" != "" && "$key" == "$ENCRYPT_KEY" ]]; then
		echo "Using key: $key"
	else
		echo "Key not found! use gpg --gen-key"
		exit 2
	fi
}
check_key #}}}

check_id_rsa() { #{{{
	if [[ "$1" == ssh:* || "$1" == sftp:* || "$1" == scp:* ]]; then
		if [ ! -e $ID_RSA ]; then
			echo "Not found: $ID_RSA" >&2
			exit 3
		fi
	fi
} #}}}

backup() {
	local SOURCE="$1"
	shift
	local DESTINATION="$1"
	shift
	if [[ "$SOURCE" == "" || "$DESTINATION" == "" ]]; then
		echo "Backup needs source and destination"
		exit 4
	fi
	check_id_rsa "$DESTINATION"

	echo "Running backup from: $SOURCE to: $DESTINATION"
	duplicity --encrypt-key $ENCRYPT_KEY \
		--full-if-older-than 4W \
		--verbosity i \
		--exclude-device-files \
		--exclude-globbing-filelist $EXCLUDE_FILELIST \
		$* $SOURCE $DESTINATION
	duplicity remove-all-but-n-full 1 --force $DESTINATION
	duplicity cleanup --force --extra-clean $DESTINATION
	#duplicity list-current-files $DESTINATION
	echo "Finished backup from: $SOURCE to: $DESTINATION"
}

setup_excluded() { #{{{
#{{{ unused
cat >/dev/null<<EOF
EOF
#}}}
cat >$EXCLUDE_FILELIST <<EOF
**/*.bak
**/*~
**/bak
**/backup
**/old
**/temp
**/Temp
**/Steam
**/SteamApps
**/.thumbnails
**/.dropbox
**/Desktop
**/Downloads
**/Cache
**/.cache
**/cache
**/caches
**/log
**/logs
**/locale
**/man
**/Trash
**/.m2
**/.ivy2
**/libreoffice
**/Thumbnails
**/.Idea*/system
**/.netbeans/*/var
**/.netbeans/*/modules
**/.cpan
**/.debris
**/.dropbox-dist
**/.gradle
**/*_encfs
**/*.vdi
**/*VirtualBox*
**/target
**/build
**/classes
**/output
**/*.class
**/*.iso
**/*.avi
**/*.mp4
**/*.mpv
**/*.flv
**/lost+found
EOF
}
setup_excluded #}}}

START=$(date +%s)

declare -F run &>/dev/null && run || echo "run() not found, declare it in $CONFIG"
export PASSPHRASE=''
unset PASSPHRASE
rm -f $EXCLUDE_FILELIST

FINISH=$(date +%s)
echo "total time: $(( ($FINISH-$START) / 60 )) minutes, $(( ($FINISH-$START) % 60 )) seconds"

