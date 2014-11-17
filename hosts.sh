#!/bin/sh

# Author: Aaron Toponce
# Date: Apr 08, 2013
# License: None. Released to the public domain

FILE="/tmp/hosts.tmp"

curl -so $FILE -G -d hostformat=hosts -d showintro=0 -d mimetype=plaintext 'http://pgl.yoyo.org/adservers/serverlist.php'
curl -s 'http://hosts-file.net/ad_servers.txt' >> $FILE
curl -s 'http://winhelp2002.mvps.org/hosts.txt' >> $FILE
awk '(NF){sub(/\#.*/,"")}; (NF){sub(/\r$/,""); $1=$1; print}' $FILE | sort -u > /tmp/hosts
sed -i '$d' /tmp/hosts

cat << EOF > hosts.tmp
127.0.0.1   localhost
127.0.1.1   $(hostname -f) $(hostname -s)

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# The following lines are to block advertising
$(cat /tmp/hosts)
EOF
