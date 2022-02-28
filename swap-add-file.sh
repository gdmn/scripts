#! /usr/bin/env bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPT_NAME="$( basename -- "${BASH_SOURCE[0]}" )"
cmd='help'
mem=1000

show_help() {
cat <<EOF
Create swapfile.

Usage:
    $SCRIPT_NAME [-h] [-m 1000] [-s] [-i]

Arguments
    -h - help
    -m 1000 - set swap file size to 1000 MB
    -i - install systemd unit run on boot
    -d - disable and remove systemd unit, remove swap file
    -s - create swapfile and enable it

Notes
    Swap file is created only once, so if it is required to change it's size,
    remove '/swapfile' before executing this script.
EOF
}

run_swapon() {
    sudo true || exit 1
    sudo swapon --show | grep '/swapfile' && echo 'already mounted!' && exit 0
    [ ! -e /swapfile ] && echo 'Creating file...' && \
      sudo dd if=/dev/zero of=/swapfile bs=1M count=$1
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    sudo swapon --show
}

install_systemd() {
sudo true || exit 1
cat <<EOF | sudo tee "/etc/systemd/system/${SCRIPT_NAME}.service" >/dev/null
[Unit]
Description=Run ${SCRIPT_NAME} on boot

[Service]
Type=simple
ExecStart=/usr/bin/bash "$SCRIPT_DIR/$SCRIPT_NAME" -m $1 -s

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now "${SCRIPT_NAME}"
sudo systemctl status "${SCRIPT_NAME}"
}

uninstall() {
    sudo systemctl disable "${SCRIPT_NAME}"
    sudo rm -f "/etc/systemd/system/${SCRIPT_NAME}.service"
    sudo swapoff /swapfile
    sudo rm -f /swapfile
sudo swapon --show
}

sudo true || exit 1
while getopts hsidm: opt; do
    case $opt in
        h) show_help; exit 0 ;;
        s) cmd='swapon' ;;
        i) cmd='install' ;;
        d) cmd='uninstall' ;;
        m) mem=$OPTARG ;;
        *) echo -e 'Error in command line parsing!\n' >&2
           show_help
           exit 1
    esac
done
shift "$(( OPTIND - 1 ))"

if [[ "$cmd" == 'help' ]]; then
    show_help; exit 0
fi

if [[ "$cmd" == 'swapon' ]]; then
    run_swapon $mem
elif [[ "$cmd" == 'uninstall' ]]; then
    uninstall
elif [[ "$cmd" == 'install' ]]; then
    install_systemd $mem
fi

