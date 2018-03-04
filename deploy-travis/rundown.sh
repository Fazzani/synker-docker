#!/bin/bash

### ### ### ### ### ### ### ### ### ### ###
# Functions
### ### ### ### ### ### ### ### ### ### ###

echo "Remove stacks ..."
set -euox

docker stack rm elk || true; echo; sleep 1;
docker stack rm rabbitmq || true; echo; sleep 1;
docker stack rm lb || true; echo; sleep 1;
docker stack rm mariadb || true; echo; sleep 1;

echo "Remove network ..."
docker network rm ntw_front

echo "Clean up ..."
docker system prune -f
docker system volume -f

exit 0