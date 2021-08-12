#! /usr/bin/env bash
# https://github.com/nodejs/docker-node/blob/main/README.md#run-a-single-nodejs-script
#

docker run -it --rm -v "$PWD":/usr/src/app -w /usr/src/app node:12-alpine sh -c "cd /usr/src/app/ && $*"

