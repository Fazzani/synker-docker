#!/bin/bash

### ### ### ### ### ### ### ### ### ### ###
# Functions
### ### ### ### ### ### ### ### ### ### ###

echo "Install stacks ..."
set -euox
export $(cat .env)

docker stack deploy -c elk-stack.yml elk
docker stack deploy -c traefik-consul-stack.yml lb
docker stack deploy -c mariadb-stack.yml mariadb
docker stack deploy -c rabbitmq.yml rabbit

exit 0