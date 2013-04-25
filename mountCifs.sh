#! /bin/bash

IP='192.168.100.200'
POINT='/home/user/smb'
PWDFILE="${POINT}/.mountCifs"

. "${HOME}/.config/mountCifs.conf" 2>/dev/null

if [ "$#" != "1" ]; then
	N=`basename "$0"`
	echo "Usage: $N [-a] share"
	echo ""
	echo "Mount Samba Share"
	echo ""
	echo "Configuration: ${HOME}/.config/mountCifs.conf"
	echo "IP=$IP"
	echo "POINT=$POINT"
	echo "PWDFILE=$PWDFILE"
	exit 1
fi

mkdir -p "${POINT}/${1}"

sudo mount.cifs -o "credentials=${PWDFILE},iocharset=utf8,rw,noauto,uid=pi,gid=users,user,suid" "//${IP}/${1}" "${POINT}/${1}" && \
	echo "Mounted in ${POINT}/${1}"

