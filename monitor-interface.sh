#! /usr/bin/env bash

show_help() {
cat <<EOF
Monitors given interface and brings other interfaces up if monitored interface is down.
Also brings other interfaces down if monitored interface is up.

Usage:
    $(basename $0) interface

Example
    $(basename $0) eth0 - turns off wifi when cable is connected.

Systemd configuration:
$ cat /etc/systemd/system/monitor-interface\@.service
[Unit]
Description=Monitor %i interface and turn off other interfaces
Wants=network.target
After=network-online.target

[Service]
Type=simple
ExecStart=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/$(basename $0) %i
Restart=on-failure
RestartSec=10
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
}

if [ $# -ne 1 ]; then
    show_help
    exit -1
else
    eth0="$1"
fi

if [ `id -u` != 0 ]; then
    echo "You are not root!"
    exit -1
fi

if ! ip link show $eth0 >/dev/null ; then
    exit -2
fi

configure_other() {
    e="$1"
    if ip -brief address show dev $e 2>&1 | grep UP >/dev/null ; then
        echo "$e UP"
        ip -brief address show | grep UP | grep -v $e | grep -v wg | grep -v lo | \
            while read k; do i="${k// */}"; echo "setting link down: $i" ; ip link set "$i" down; done
    else
        echo "$e DOWN"
        ip -brief address show | grep DOWN | grep -v $e | grep -v wg | grep -v lo | \
            while read k; do i="${k// */}"; echo "setting link up: $i" ; ip link set "$i" up; done
    fi
}

# check what route is used:
# ip -4 route get 1.1.1.1
#

echo "Monitoring $eth0"

sleep 1
configure_other "$eth0"

ip monitor dev $eth0 | \
    while read k; do \
        if echo "$k" | grep 'table local proto kernel scope host src' >/dev/null 2>&1; then \
            (sleep 1 && configure_other "$eth0") & \
        fi; \
    done

