#! /bin/bash

## by dmn, http://devsite.pl

#w3m -dump_source http://showip.net/simple_ip.php?from_widget=1
# echo `wget -q -O - "http://showip.net/simple_ip.php?from_widget=1"`
#wget -q -O - "http://showip.net/simple_ip.php?from_widget=1"
wget -q -O - "http://static.devsite.pl/ip.php"
#curl http://www.whatismyip.org
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

