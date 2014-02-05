#! /usr/bin/env bash

# https://wiki.archlinux.org/index.php/Full_System_Backup_with_rsync
CMD="rsync --one-file-system -aRXv --delete-during --delete-excluded"
DEST=

if [ -e /.backup-dest.conf ]; then
	. /.backup-dest.conf
else
    echo "Configuration file /.backup-dest.conf not found" >&2
fi

ignorethisfornow() { # {{{
if [ $# -lt 1 ]; then 
    echo "No destination defined. Usage: $0 destination" >&2
elif [ $# -gt 1 ]; then
    echo "Too many arguments. Usage: $0 destination" >&2
    exit 1
elif [[ "$1" == *:* ]]; then
	echo ssh!
   DEST="$1"
else
   mkdir -p "$1"
   if [ ! -d "$1" ]; then
     echo "Invalid path: $1" >&2
     exit 1
   fi
   if [ ! -w "$1" ]; then
     echo "Directory not writable: $1" >&2
     exit 1
   fi
   DEST="$1"
fi
} # }}}

case "$DEST" in
  "/mnt") ;;
  "/mnt/"*) ;;
  "/media") ;;
  "/media/"*) ;;
  *:*) ;;
  *) echo "Destination not allowed." >&2 
     exit 1 
     ;;
esac

echo "Destination: $DEST"

if [ ! -e /.id_rsa ]; then
	echo "Not found: /.id_rsa" >&2
	exit 1
fi

echo "`date '+%A, %d %B %Y, %T'`" > /.backup-timestamp

START=$(date +%s)
$CMD \
-e "/usr/bin/ssh -p22 -i /.id_rsa" \
/ /home/* "$DEST" \
'--exclude=*/.hg/*' \
'--exclude=*/.git/*' \
'--exclude=*/.svn/*' \
'--exclude=*/locale/*' \
'--exclude=*/man/*' \
'--exclude=*/backup/*' \
'--exclude=*/Steam/*' \
'--exclude=*/.m2/*' \
'--exclude=*/.ivy2/*' \
'--exclude=*/.netbeans/*' \
'--exclude=*_encfs' \
'--exclude=*VirtualBox*' \
'--exclude=*.vdi' \
'--exclude=*/Thumbnails/*' \
'--exclude=/opt/jdk*' \
'--exclude=/opt/java*' \
'--exclude=*.bak' \
'--exclude=/dev/*' \
'--exclude=/proc/*' \
'--exclude=/sys/*' \
'--exclude=/tmp/*' \
'--exclude=/run/*' \
'--exclude=/mnt/*' \
'--exclude=/media/*' \
'--exclude=/lost+found' \
'--exclude=/run/*' \
'--exclude=/var/lib/pacman/sync/*' \
'--exclude=/var/backups/*' \
'--exclude=/var/cache/*' \
'--exclude=/var/lib/indiecity/*' \
'--exclude=/var/swap' \
'--exclude=/var/run/*' \
'--exclude=/var/lock/*' \
'--exclude=/var/log/journal/*' \
'--exclude=/var/log/journal/*' \
'--exclude=/var/tmp/*' \
'--exclude=/home/*/.thumbnails/*' \
'--exclude=/home/*/.mozilla/firefox/*.default/Cache/*' \
'--exclude=/home/*/.cache/*'
FINISH=$(date +%s)
echo "total time: $(( ($FINISH-$START) / 60 )) minutes, $(( ($FINISH-$START) % 60 )) seconds" | \
tee -a /.backup-timestamp
#| tee $1/"Backup from $(date '+%A, %d %B %Y, %T')"

