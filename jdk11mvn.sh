#! /usr/bin/env bash

#https://hub.docker.com/_/maven?tab=description

#find . -name target -type d -print0 | sudo xargs -0 -I {} /bin/rm -rf "{}"


docker run -v ~/.m2:/var/maven/.m2 -ti --rm -u "$(id -u):$(id -g)" -e MAVEN_CONFIG=/var/maven/.m2 -v "$PWD":/var/maven/project -w /var/maven/project maven:3.6.3-jdk-11 mvn -Duser.home=/var/maven $*

