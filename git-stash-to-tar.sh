#! /usr/bin/env bash

set -e

if [ ! -d .git ] ; then 
    echo '.git directory not found'
    exit 1
fi

dest="stashed-$(date +%Y%m%d_%H%M%S).tar.zst"
if [ $# -gt 0 ]; then
    dest="stashed-$(date +%Y%m%d_%H%M%S)-$@.tar.zst"
fi

echo "Destination: $dest"

(git diff --staged --name-only; git ls-files . --exclude-standard --modified --others) \
    | grep -v "stashed-.*\.tar\.zst" \
    | tar -cv -T - | zstd -19 --long -o "$dest"

echo "Undo changes: git reset HEAD && git checkout ."

echo "Unstash: tar -xvf \"$dest\""

