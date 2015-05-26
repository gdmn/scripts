#! /usr/bin/env bash

IP='192.168.100.200'
POINT='/home/user/smb'
PWDFILE="${POINT}/.mountCifs"
FORCEUID="$USER"
FORCEGID="users"

. "${HOME}/.config/mountCifs.conf" 2>/dev/null

if [ "$#" != "1" ]; then
	N=`basename "$0"`
	echo "Usage: $N share"
	echo ""
	echo "Mount Samba Share"
	echo ""
	echo "Configuration: ${HOME}/.config/mountCifs.conf"
	echo "IP=$IP"
	echo "POINT=$POINT"
	echo "PWDFILE=$PWDFILE"
	echo "FORCEUID=$FORCEUID"
	echo "FORCEGID=$FORCEGID"
	exit 1
fi

mkdir -p "${POINT}/${1}"
chown $FORCEUID "${POINT}"
chown $FORCEUID "${POINT}/${1}"

sudo mount.cifs -o "credentials=${PWDFILE},iocharset=utf8,rw,noauto,uid=${FORCEUID},gid=${FORCEGID},forceuid,forcegid,user,suid" "//${IP}/${1}" "${POINT}/${1}" && \
	echo "Mounted in ${POINT}/${1}"

