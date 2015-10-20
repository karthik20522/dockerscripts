#!/bin/bash

set -e

function usage {
  echo >&2 "Usage: $0 [ -i ip (127.0.0.1) -k key (/c/temp/dsa-beta.pem) -u user (ubuntu/ec2-user) -n nodeName ]"
  exit 1
}

while getopts ":i:k:u:n:" FLAG; do
  case $FLAG in    
 i) IP=${OPTARG};;
 k) KEY=${OPTARG};;
 u) USER=${OPTARG};;
 n) NAME=${OPTARG};;
 [?]) usage;;
  esac
done

if [[ -z $IP || -z $KEY || -z $USER || -z $NAME ]]; then
  usage
fi

echo "** SETTING-UP $NAME Node **"
docker-machine --debug \
	create -d generic \
	--generic-ssh-user $USER \
	--generic-ssh-key $KEY \
	--generic-ip-address $IP \
	$NAME

docker $(docker-machine config $NAME) run \
    -ti \
    -d \
    --hostname=$NAME \
    --restart=always \
    --name shipyard-proxy \
    -v //var/run/docker.sock:/var/run/docker.sock \
    -e PORT=2375 \
    ehazlett/docker-proxy