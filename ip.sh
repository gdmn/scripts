#! /bin/bash

## by dmn, http://devsite.pl


#w3m -dump_source http://showip.net/simple_ip.php?from_widget=1
# echo `wget -q -O - "http://showip.net/simple_ip.php?from_widget=1"`
#wget -q -O - "http://showip.net/simple_ip.php?from_widget=1"
wget -q -O - "http://static.devsite.pl/ip.php"
echo
#curl http://www.whatismyip.org
