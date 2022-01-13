#! /usr/bin/env bash

#ip=$(curl -s 192.168.1.1| grep IP|grep -E '.*[0-9]{1,3}(\.[0-9]{1,3}){2}.*' | sed 's/<[^>]*>//g' | sed 's/.*://g' | sed 's/.* //g')
#echo "Router WAN IP: $ip"

# root@LEDE-ROUTER:~# cat ip-wan.sh 
# . /lib/functions/network.sh; network_get_ipaddr ip wan; echo $ip
ssh root@192.168.3.1 /root/ip-wan.sh
