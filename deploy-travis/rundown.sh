#!/bin/bash

### ### ### ### ### ### ### ### ### ### ###
# Functions
### ### ### ### ### ### ### ### ### ### ###

echo "Remove stacks ..."
set -euox

docker stack rm elk || true; echo; sleep 1;
docker stack rm rabbitmq || true; echo; sleep 1;
docker stack rm lb || true; echo; sleep 1;
docker stack rm webgrab || true; echo; sleep 1;
docker stack rm synker || true; echo; sleep 1;

echo "Remove networks ..."
docker network rm ntw_front
docker network rm ingress_net_backend

echo "Clean up ..."
docker system prune --force
docker volume prune --force

exit 0