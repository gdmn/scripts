#! /usr/bin/env bash

ENCRIPTION_PASS=
USER_PASS=
URL=

if [ -e "/etc/wush-serve.conf" ]; then source "/etc/wush-serve.conf"; fi

help_general() {
cat <<EOF
To use this script, you must set the credentials. Please edit them at the top of this file (${BASH_SOURCE[0]}) or in /etc/wush-serve.conf.
- for self-hosted ntfy set \$USER_PASS and \$ENCRIPTION_PASS and \$URL
- for public available ntfy.sh set \$ENCRIPTION_PASS and \$URL

Example configuration:
ENCRIPTION_PASS=changeme
URL='https://ntfy.sh/wushserve123'

Install wush-serve to a host via ssh:
     r=remote; $0 --cat | ssh \$r sh -c "cat > /tmp/install.sh" ; ssh -t \$r bash /tmp/install.sh

Install wush-serve manually:
    save the script to a file and run './wush-serve.sh --install'
EOF
} # help_general

help_configuration() {
cat <<EOF
There are at least 2 ways to subscribe to topics.

1. Run this script on a host where you want to be notified about auth keys:

curl -s --no-buffer $URL/raw | while read l; do if [ -n "\$l" ] ; then echo "\$l" | openssl enc -d -A -a -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -k "$ENCRIPTION_PASS" | tee -a ${XDG_CONFIG_HOME:-$HOME/.config}/notifications-wush; fi; done

2. Configure subscriptions on a host where you want to be notified about auth keys.
Two files must be created and the command must be run:

- '~/.config/ntfy/client-wush.yml':
default-host: $( echo $URL | sed -r 's|[^/]+$||' )
subscribe:
  - topic: $( echo $URL | sed -r 's|.+/||' )
    user: USER
    password: PASSWORD
    if:
        tags: wush
    command: |
        echo "\$message" | openssl enc -d -A -a -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -k "$ENCRIPTION_PASS" | tee -a \${XDG_CONFIG_HOME:-$HOME/.config}/notifications-wush

- '~/.config/systemd/user/subscribe-wush.service':
[Unit]
Description=Subscribe to wush notifications
ConditionFileNotEmpty=%h/.config/ntfy/client-wush.yml

[Service]
Type=exec
Environment="PATH=/bin:/sbin:/usr/bin"
WorkingDirectory=%h

ExecStart=ntfy subscribe --config "%h/.config/ntfy/client-wush.yml" --from-config

[Install]
WantedBy=default.target

- run command: 'systemctl --user daemon-reload; systemctl --user enable --now subscribe-wush'
EOF
} # help_configuration

wush_serve_install() {
    echo "Install mode"
    $sudo true || exit 2
    echo "installing wush-serve.sh"
    cat "${BASH_SOURCE[0]}" \
      | $sudo tee /etc/systemd/system/wush-serve.sh >/dev/null
    $sudo chmod 755 /etc/systemd/system/wush-serve.sh
    echo "installing wush-serve.service"
    cat <<EOF | $sudo tee /etc/systemd/system/wush-serve.service >/dev/null
[Unit]
Description=wush serve

[Service]
User=$(whoami)
Environment="PATH=/bin:/sbin:/usr/bin:/usr/local/bin"
Restart=always
RestartSec=1m
Type=exec
ExecStartPre=sleep 1
ExecStartPre=-rm -vf /tmp/tailscaled.log*
ExecStart=/etc/systemd/system/wush-serve.sh

[Install]
WantedBy=multi-user.target
EOF
    $sudo systemctl daemon-reload
    if ! systemctl is-enabled wush-serve >/dev/null 2>&1; then
        $sudo systemctl enable wush-serve
    fi
    echo "starting wush-serve"
    $sudo systemctl restart wush-serve
} # wush_serve_install

cat_me() {
    if [ -e "/etc/wush-serve.conf" ]; then source "/etc/wush-serve.conf"; fi
    cat <<EOF
#! /usr/bin/env bash

ENCRIPTION_PASS=$ENCRIPTION_PASS
USER_PASS=$USER_PASS
URL=$URL
EOF
    cat "${BASH_SOURCE[0]}" | grep -ve '^URL=$' | grep -ve '^ENCRIPTION_PASS=$' | grep -ve '^USER_PASS=$' |grep -ve '^#!'
} # cat_me

if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    help_general
    echo ''
    help_configuration
    exit 0
fi

if [ "$1" = "cat" ] || [ "$1" = "--cat" ]; then
    cat_me
    exit 0
fi

if [ -z "$ENCRIPTION_PASS" ]; then
    help_general
    exit 1
fi
if [ -z "$USER_PASS" ]; then
    echo "WARNING: using public service"
fi

command -v curl >/dev/null 2>&1 || { echo >&2 "curl?"; exit 1; }
command -v openssl >/dev/null 2>&1 || { echo >&2 "openssl?"; exit 1; }
sudo=""

if ! [ $(id -u) = 0 ]; then
    command -v sudo >/dev/null 2>&1 || { echo >&2 "sudo?"; exit 1; }
    sudo="sudo"
else
    sudo=""
fi

if ! command -v wush >/dev/null 2>&1; then
    curl -fsSL https://wush.dev/install.sh | sh
fi
if ! command -v wush >/dev/null 2>&1; then
    echo "wush NOT found"
    exit 1
fi

MYNAME="$( basename -- "${BASH_SOURCE[0]}" )"

if [ "$MYNAME" = "install.sh" ] || [ "$1" = "install" ] || [ "$1" = "--install" ]; then
    wush_serve_install
    exit 0
fi

if [ "$MYNAME" != "wush-serve.sh" ]; then
    echo "Script must be named wush-serve.sh to start!"
    echo "Use systemctl to start a service."
    exit 0
fi

TITLE="$(hostnamectl status --transient 2>/dev/null || hostname)"
TAGS='computer,wush'
INPUT=
TEMP_DIR="$(mktemp -d)"
mkfifo $TEMP_DIR/auth

notify() {
  local content="$( echo "$@" | openssl enc -A -a -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -k "$ENCRIPTION_PASS" )"
  if [ -n "$USER_PASS" ]; then
    curl \
        -Ss \
        -u "$USER_PASS" \
        -H "Title: $TITLE" \
        -H "Priority: 3" \
        -H "Tags: $TAGS" \
        --data-binary "$content" \
        "$URL"
  else
    curl -d "$content" "$URL"
  fi
} # notify

cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rfv "$TEMP_DIR"
        notify "$TITLE wush closed"
    fi
} # cleanup
cleanup2() {
    sleep 1
    cleanup
} # cleanup2
trap cleanup2 SIGINT
trap cleanup SIGTERM

rm -fv /tmp/tailscaled.log* || true
wush serve | while read l; do
    echo "$l" >> $TEMP_DIR/auth
done &

AUTH="$(cat $TEMP_DIR/auth)"
echo "auth: $AUTH"

notify "$TITLE $AUTH"

wait
cleanup
