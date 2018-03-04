#!/bin/bash

### ### ### ### ### ### ### ### ### ### ###
# Deploy script for Synker docker stack
### ### ### ### ### ### ### ### ### ### ###

echo "Installing stacks ..."
REMOTE_USER=$1
MYSQL_PASSWORD=$2
MYSQL_ROOT_PASSWORD=$3

set -euox

cd /home/$REMOTE_USER/synker-docker/

docker network create --driver overlay ntw_front || true

echo $MYSQL_PASSWORD > mysql_root_password.txt
echo $MYSQL_ROOT_PASSWORD > mysql_password.txt

export $(cat .env)

docker stack deploy -c elk-stack.yml elk
docker stack deploy -c traefik-consul-stack.yml lb
docker stack deploy -c mariadb-stack.yml mariadb
docker stack deploy -c rabbitmq-stack.yml rabbit

exit 0