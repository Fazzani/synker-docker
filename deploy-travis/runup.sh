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
MYSQL_PASSWORD=${2}
MYSQL_ROOT_PASSWORD=${3}
MYSQL_DATABASE=${4:-playlist}
MYSQL_RESET_DATABASE=${5:-true}

set -euox

cd /home/$REMOTE_USER/synker-docker/

if [ "$MYSQL_RESET_DATABASE" = true ] ; then
  sudo rm  -rf /mnt/nfs/mariadb/data/*
fi

docker network create --driver overlay ntw_front \
  --attachable || true \
  --opt encrypted=true || true

docker network create --driver overlay ingress_net_backend \
  --attachable || true \
  --subnet=70.28.0.0/16 \
  --opt com.docker.network.driver.mtu=9216 \
  --opt encrypted=true || true

echo $MYSQL_PASSWORD > mysql_password.txt
echo $MYSQL_ROOT_PASSWORD > mysql_root_password.txt

export $(cat .env)

docker stack deploy -c traefik-consul-stack.yml lb
sleep 10
docker stack deploy -c elk-stack.yml elk
docker stack deploy -c rabbitmq-stack.yml rabbit
docker stack deploy -c ./webgrab/docker-compose.yml webgrab
docker stack deploy -c synker-stack.yml synker

echo "Clean up ..."
docker system prune -f

# Restoring maridb data 
# Must be running on mariadb host container
sleep 15

if [ "$MYSQL_RESET_DATABASE" = true ] ; then
   SERVICE_ID=$(docker service ps -q -f desired-state=running  synker_synkerdb | head -1)
   CONTAINER_ID=$(docker inspect --format "{{.Status.ContainerStatus.ContainerID}}" $SERVICE_ID | head -1)
   cat ./synker/playlist.dump-2018-02-28.sql | \
   sudo docker exec -i -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" -e MYSQL_DATABASE="${MYSQL_DATABASE}" $CONTAINER_ID \
   mysql -u root -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" --force
fi
exit 0