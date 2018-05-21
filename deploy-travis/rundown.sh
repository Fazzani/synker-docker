#!/bin/bash

### ### ### ### ### ### ### ### ### ### ###
# Script to purge swarm stacks
### ### ### ### ### ### ### ### ### ### ###

script=$(basename "$0")

function log {
   echo -e "[$(date +"%d-%m-%Y %H:%M:%S") $HOSTNAME $USER $script] $1" 
}

log "Remove stacks ..."
set -euox

docker stack rm elk || true; echo; sleep 1;
docker stack rm rabbitmq || true; echo; sleep 1;
docker stack rm lb || true; echo; sleep 1;
docker stack rm webgrab || true; echo; sleep 1;
docker stack rm synker || true; echo; sleep 1;
docker stack rm others || true; echo; sleep 1;

log "Remove networks ..."
docker network rm ntw_front
docker network rm ingress_net_backend

log "Clean up ..."
docker system prune --force
docker volume prune --force

exit 0