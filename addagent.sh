#!/bin/bash

set -e

function usage {
  echo >&2 "Usage: $0 [ -n nodeName ]"
  exit 1
}

while getopts ":n:" FLAG; do
  case $FLAG in    
 n) NAME=${OPTARG};;
 [?]) usage;;
  esac
done

if [[ -z $NAME ]]; then
  usage
fi

Infra_IP=$(docker-machine inspect --format '{{.Driver.IPAddress}}' infra)
LOCAL_IP=$(docker-machine inspect --format '{{.Driver.IPAddress}}' $NAME)
docker $(docker-machine config $NAME) run \
  -ti \
  -d \
  --restart=always \
  --name shipyard-swarm-agent \
  swarm:latest \
  join --addr $LOCAL_IP:2375 etcd://$Infra_IP:4001