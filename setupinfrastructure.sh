#!/bin/bash

set -e
function usage {
  echo >&2 "Usage: $0 [ -n nodename ]"
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

#echo "** STOPPING ALL CONTAINERS **"
#docker $(docker-machine config $NAME) stop $(docker $(docker-machine config $NAME) ps -a -q)
#docker $(docker-machine config $NAME) rm $(docker $(docker-machine config $NAME) ps -a -q)

echo "** ETCD DISCOVERY FOR SHIPYARD **"
docker $(docker-machine config $NAME) run \
    -ti \
    -d \
    -p 4001:4001 \
    -p 7001:7001 \
    --restart=always \
    --name shipyard-discovery \
    microbox/etcd -name discovery

#DOCKER SWARM
echo "** SHIPYARD RETHINKDB **"
docker $(docker-machine config $NAME) run \
    -ti \
    -d \
    --restart=always \
    --name shipyard-rethinkdb \
    rethinkdb
    
#DOCKER SWARM
echo "** DOCKER SWARM **"
Infra_IP=$(docker-machine inspect --format '{{.Driver.IPAddress}}' infra)
docker $(docker-machine config $NAME) run \
    -ti \
    -d \
    --restart=always \
    --name shipyard-swarm-manager \
    swarm:latest \
    manage --host tcp://0.0.0.0:3375 etcd://$Infra_IP:4001

#DOCKER SHIPYARD UI
#echo "** SHIPYARD MANAGEMENT **"
#docker $(docker-machine config $NAME) run \
#    -ti \
#    -d \
#    --restart=always \
#    --name shipyard-controller \
#    --link shipyard-rethinkdb:rethinkdb \
#    --link shipyard-swarm-manager:swarm \
#    -p 8080:8080 \
#    shipyard/shipyard:latest \
#    server \
#    -d tcp://swarm:3375
