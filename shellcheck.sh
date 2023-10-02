#! /usr/bin/env bash

process() {
    dir="$( dirname "$(readlink -f "$1")")"
    base="$( basename "$(readlink -f "$1")")"
    echo "$dir/$base"
    podman run -it --rm -v "$dir:/mnt" koalaman/shellcheck:stable "$base"
}

while [[ "" != "$1" ]]; do
    process "$1"
    shift
done
