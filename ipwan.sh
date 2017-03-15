#! /usr/bin/env bash

ip=$(curl -s 192.168.1.1| grep IP|grep -E '.*[0-9]{1,3}(\.[0-9]{1,3}){2}.*' | sed 's/<[^>]*>//g' | sed 's/.*://g' | sed 's/.* //g')
echo "Router WAN IP: $ip"

digresult=$(dig +noall +answer @8.8.8.8 dyn.h64.pl)
echo "dyn.h64.pl is resolving to: $digresult"

