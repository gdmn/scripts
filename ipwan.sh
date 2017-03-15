#! /usr/bin/env bash

ip=$(curl -s 192.168.1.1| grep IP|grep -E '.*[0-9]{1,3}(\.[0-9]{1,3}){2}.*' | sed 's/<[^>]*>//g' | sed 's/.*://g' | sed 's/.* //g')
echo "Router WAN IP: $ip"

