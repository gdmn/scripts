#! /usr/bin/env bash

# by dmn, http://devsite.pl

display() {
	local device=$1
	
	l1=`ip route show | grep $device | head -n 1`
	l2=`ip route show | grep $device | tail -n 1`

	mask=${l2/ *}
	mask=${mask// }
	gateway=${l1/*via }
	gateway=${gateway/ dev*}
	gateway=${gateway// }
	ip=${l2/*src }
	ip=${ip// }
	dev=${l1/*dev }
	dev=${dev// }

	echo "$dev $ip $mask $gateway"
}

interfaces() {
	# tap0 -- state UNKNOWN
	ip link show | grep BROADCAST | \
		grep -v NO-CARRIER | grep -v 'state DOWN' | \
		grep -v tap | grep -v tun | grep -v 'NOARP' | \
		grep ',UP' | \
		while read l; do
			l=${l/: <*}
			l=${l/*: }
			echo "$l"
		done
}

interfaces_list=`interfaces`
if [[ "" == "$interfaces_list" ]]; then
	echo 'no lan interfaces' >&2
	exit 1
else
	for i in $interfaces_list ; do
		display $i
	done
fi

