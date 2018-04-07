#!/bin/bash

### ### ### ### ### ### ### ### ### ### ###
# Deploy script for Synker docker stack
### ### ### ### ### ### ### ### ### ### ###

set +e
mkdir /mnt/nfs/elastic ||
mkdir /mnt/nfs/elastic/data ||
mkdir /mnt/nfs/consul        ||
mkdir /mnt/nfs/consul/data ||
mkdir /mnt/nfs/synker ||
mkdir /mnt/nfs/synker/data ||
mkdir /mnt/nfs/mariadb ||
mkdir /mnt/nfs/mariadb/data ||
mkdir /mnt/nfs/rabbitmq ||
mkdir /mnt/nfs/rabbitmq/data ||
mkdir /mnt/nfs/logstash ||
mkdir /mnt/nfs/kibana ||
mkdir /mnt/nfs/kibana/data ||
mkdir /mnt/nfs/filebeat ||
mkdir /mnt/nfs/filebeat/data ||
mkdir /mnt/nfs/filebeat/logs ||
mkdir /mnt/nfs/webgrab ||
mkdir /mnt/nfs/webgrab/config ||
mkdir /mnt/nfs/webgrab/data ||
echo "Creating directories ok..."

echo "Installing stacks ..."
REMOTE_USER=${1:-pl}
MYSQL_PASSWORD=${2:-password}
MYSQL_ROOT_PASSWORD=${3:-root}

set -euox

cd /home/$REMOTE_USER/synker-docker/

docker network create --driver overlay ntw_front \
  --attachable || true \
  --opt encrypted=true || true

docker network create --driver overlay ingress_net_backend \
  --attachable || true \
  --subnet=70.28.0.0/16 \
  --opt com.docker.network.driver.mtu=9216 \
  --opt encrypted=true || true

echo $MYSQL_PASSWORD > mysql_root_password.txt
echo $MYSQL_ROOT_PASSWORD > mysql_password.txt

export $(cat .env)

docker stack deploy -c traefik-consul-stack.yml lb
sleep 20
docker stack deploy -c elk-stack.yml elk
docker stack deploy -c rabbitmq-stack.yml rabbit
docker stack deploy -c ./webgrab/docker-compose.yml webgrab
docker stack deploy -c synker-stack.yml synker

echo "Clean up ..."
docker system prune -f

exit 0