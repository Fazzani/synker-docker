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

sudo docker network create --driver overlay ntw_front \
  --attachable || true \
  --opt encrypted=true || true

sudo docker network create --driver overlay ingress_net_backend \
  --attachable || true \
  --subnet=70.28.0.0/16 \
  --opt com.docker.network.driver.mtu=9216 \
  --opt encrypted=true || true

echo $MYSQL_PASSWORD > mysql_root_password.txt
echo $MYSQL_ROOT_PASSWORD > mysql_password.txt

sudo export $(cat .env)

sudo docker stack deploy -c traefik-consul-stack.yml lb
sleep 20
sudo docker stack deploy -c elk-stack.yml elk
sudo docker stack deploy -c rabbitmq-stack.yml rabbit
sudo docker stack deploy -c ./webgrab/docker-compose.yml webgrab
sudo docker stack deploy -c synker-stack.yml synker

echo "Clean up ..."
sudo docker system prune -f

exit 0