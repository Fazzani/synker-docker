#!/bin/bash

### ### ### ### ### ### ### ### ### ### ###
# Functions
### ### ### ### ### ### ### ### ### ### ###

echo "Install stacks ..."
set -euox

cd /home/$REMOTE_USER/synker-docker/

docker network create --driver overlay ntw_front || true

echo $MYSQL_PASSWORD > mysql_root_password.txt
echo $MYSQL_ROOT_PASSWORD > mysql_password.txt

export $(cat .env)

docker stack deploy -c elk-stack.yml elk
docker stack deploy -c traefik-consul-stack.yml lb
docker stack deploy -c mariadb-stack.yml mariadb
docker stack deploy -c rabbitmq.yml rabbit

exit 0