#! /usr/bin/env bash

#https://hub.docker.com/_/maven?tab=description

#docker run -v ~/.m2:/var/maven/.m2 -ti --rm -u "$(id -u):$(id -g)" -e MAVEN_CONFIG=/var/maven/.m2 -v "$PWD":/var/maven/project -w /var/maven/project maven:3.6.3-jdk-11 mvn -Duser.home=/var/maven $*

mvnver="3"
jdkver="jdk-11"
m2dir="$HOME/.m2-${jdkver}"
mkdir -p "$m2dir"
docker run -v $m2dir:/var/maven/.m2 -ti --rm -u "$(id -u):$(id -g)" -e MAVEN_CONFIG=/var/maven/.m2 -v "$PWD":/var/maven/project -w /var/maven/project maven:${mvnver}-${jdkver} mvn -Duser.home=/var/maven -Dstyle.color=always $*

