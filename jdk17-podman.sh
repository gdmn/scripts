#! /usr/bin/env bash

mvnver="3"
jdkver="openjdk-17"
m2dir="$HOME/.m2-${jdkver}"
mkdir -p "$m2dir"
link="docker.io/maven:${mvnver}-${jdkver}"
#podman run -v $m2dir:/var/maven/.m2 -ti --rm -e MAVEN_CONFIG=/var/maven/.m2 -v "$PWD":/var/maven/project -w /var/maven/project $link mvn -Duser.home=/var/maven -Dstyle.color=always $*
podman run -v $m2dir:/var/maven/.m2 -ti --rm -e MAVEN_CONFIG=/var/maven/.m2 -v "$PWD":/var/maven/project -w /var/maven/project $link "$@"

