#! /usr/bin/env bash

## by dmn, http://devsite.pl

#w3m -dump_source http://showip.net/simple_ip.php?from_widget=1
# echo `wget -q -O - "http://showip.net/simple_ip.php?from_widget=1"`
#wget -q -O - "http://showip.net/simple_ip.php?from_widget=1"

if command -v dig >/dev/null 2>&1; then
    dig +short myip.opendns.com @resolver1.opendns.com
else
    #echo "$(curl --silent 'https://api.ipify.org/')"
    echo "$(curl --silent ifconfig.co||curl --silent zx2c4.com/ip|head -n 1)"
fi
#dig TXT +short o-o.myaddr.l.google.com @ns1.google.com

if command -v docker >/dev/null 2>&1; then
    if [ "$(docker inspect -f '{{.State.Running}}' gluetun 2>/dev/null)" = "true" ]; then 
        echo "gluetun vpn:$(docker exec gluetun cat /tmp/gluetun/ip)"
    fi
fi

exit

==========================================================================================

<?php
	header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
	header("Expires: Sat, 26 Jul 1997 05:00:00 GMT"); // Date in the past
?>
<?php
	// Turn off all error reporting
	error_reporting(0);
	if (!empty($_SERVER[HTTP_CLIENT_IP]))   //check ip from share internet
	{
		$ip=$_SERVER[HTTP_CLIENT_IP];
	}
	elseif (!empty($_SERVER[HTTP_X_FORWARDED_FOR]))   //to check ip is pass from proxy
	{
		$ip=$_SERVER[HTTP_X_FORWARDED_FOR];
	}
	else
	{
		$ip=$_SERVER[REMOTE_ADDR];
	}
	echo "$ip";
?>

