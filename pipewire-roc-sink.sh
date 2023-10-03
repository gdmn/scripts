#! /usr/bin/env bash

help() {
    cat <<EOF
$0 [what] [addr]

    what:
        roc -> route trough roc sink
        hw -> route trough default alsa output
        reset -> hw + remove target settings + restart wireplumber

        -h, --help -> this help
        --roc-help -> more help

    addr:
        in case of "roc" or empty [what], addr is resolvable name or ip
EOF
}

moar_help() {
    cat <<EOF
roc tutorial: https://gavv.net/articles/roc-tutorial-0.2/

server: ~/.config/pipewire/pipewire.conf.d/roc-source.conf

context.modules = [
  {   name = libpipewire-module-roc-source
      args = {
          local.ip = 0.0.0.0
          resampler.profile = medium
          fec.code = rs8m
          sess.latency.msec = 150
          local.source.port = 10001
          local.repair.port = 10002
          source.name = "Roc Source"
          source.props = {
             node.name = "roc-source"
          }
      }
  }
]

example client if $0 is not used: ~/.config/pipewire/pipewire.conf.d/roc-sink.conf

context.modules = [
  {   name = libpipewire-module-roc-sink
      args = {
          fec.code = rs8m
          #remote.ip = 192.168.1.2
          remote.ip = soundserver.lan
          remote.source.port = 10001
          remote.repair.port = 10002
          sink.name = "Roc Sink"
          sink.props = {
             node.name = "roc-sink"
          }
      }
  }
]
EOF
}

remote_sink='roc-sink'
remote_ip=
hw_sink="$(pactl list short sinks | grep alsa | tail -n 1 | sed -r 's/.*(alsa[^[:space:]]*).*/\1/')"

route_to() {
    local s="$1"
    echo "Routing applications to $s"
    #pactl list short sink-inputs | sed -r 's/([0-9]+).*/\1/' | while read appId; do pactl move-sink-input $appId "$s"; done
    paste -d '' - - < <(pactl list sink-inputs | grep -e "Sink Input" -e "application\.name") | sed -r 's/.*#([0-9]+).*name.*"(.+)".*/\1 \2/' | while read appId appName; do
        echo "Routing $appName (id $appId) to $s"
        pactl move-sink-input $appId "$s"
    done
}

print_default() {
    echo "Default sink is $(pactl get-default-sink)"
}

set_default_sink() {
    pactl set-default-sink "$1"
}

check_remote() {
    local addr="$1"
    echo "Checking connectivity to $addr"
    if ! ping -c 1 -w 1 "$addr" &>/dev/null; then
        echo "Failed!"
        exit 1
    fi
}

unload_module-roc-sink() {
    if [ $(pactl list short modules | grep -c module-roc-sink) -gt 0 ]; then
        echo "Found already loaded module-roc-sink, unloading..."
        pactl unload-module module-roc-sink
    fi
}

load_module-roc-sink() {
    local s="$1"
    local addr="$2"
    if ! pactl get-sink-volume $s &>/dev/null; then
        unload_module-roc-sink
        echo "Creating sink $s with remote $addr"
        pactl load-module module-roc-sink fec_code=rs8m remote_source_port=10001 remote_repair_port=10002 sink_name=RocSink-$addr sink_properties=node.name=$s remote_ip=$addr
    else
        echo "Sink $s already created"
    fi
}

do_roc() {
    print_default
    check_remote "$remote_ip"
    load_module-roc-sink "$remote_sink" "$remote_ip"
    sleep 1
    route_to "$remote_sink"
}

do_hw() {
    print_default
    set_default_sink "$hw_sink"
    route_to "$hw_sink"
    unload_module-roc-sink
    print_default
}

do_reset() {
    systemctl --user stop pipewire
    sed -i '/:target/d' $HOME/.local/state/wireplumber/restore-stream
    systemctl --user start wireplumber
}

if [ $# -eq 1 ]; then
    if [ "$1" == "hw" ] || [ "$1" == "unload" ] || [ "$1" == "default" ]; then
        do_hw
    elif [ "$1" == "reset" ]; then
        do_hw
        do_reset
    elif [ "$1" == "--roc-help" ]; then
        moar_help; exit 0
    elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        help; exit 0
    else
        remote_ip="$1"
        do_roc
    fi
elif [ $# -eq 2 ]; then
    if [ "$1" == "roc" ]; then
        remote_ip="$2"
        do_roc
    else
        help; exit 1
    fi
else
    help; exit 1
fi
