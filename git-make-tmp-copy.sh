#! /usr/bin/env bash

set -e

if [ ! -d .git ] ; then 
    echo '.git directory not found'
    exit 1
fi

dest="../`date +%Y%m%d_%H%M%S`"
echo "destination directory: $dest"

mkdir -p "$dest"
cp -r .git "$dest"

cd "$dest" && \
git reset --hard

echo -e "\ndo not forget to\n\tcd $dest"
