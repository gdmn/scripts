#! /bin/sh

COOKIE_FILE=/var/tmp/youtube-dl-cookies.txt
mplayer -vo gl -fs -cookies -cookies-file ${COOKIE_FILE} $(youtube-dl -g --cookies ${COOKIE_FILE} $*)

# $ cat yt.desktop 
# [Desktop Entry]
# Version=1.0
# Name=YT in mplayer
# Exec=/home/dmn/Dropbox/Projects/scripts/yt.sh %U
# Terminal=false
# Icon=smplayer
# Type=Application
# Categories=GTK;Network;WebBrowser;
# MimeType=text/html;x-scheme-handler/http;x-scheme-handler/https;

