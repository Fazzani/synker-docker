#!/bin/bash

### ### ### ### ### ### ### ### ### ### ###
# Deploy script for Synker docker stack
### ### ### ### ### ### ### ### ### ### ###

set +e
mkdir /mnt/nfs/elastic || true
mkdir /mnt/nfs/elastic/data || true
mkdir /mnt/nfs/elastic/config || true
mkdir /mnt/nfs/elastic/synkerconfig || true
mkdir /mnt/nfs/consul        || true
mkdir /mnt/nfs/consul/data || true
mkdir /mnt/nfs/synker || true
mkdir /mnt/nfs/synker/data || true
mkdir /mnt/nfs/mariadb || true
mkdir /mnt/nfs/mariadb/data || true
# mkdir /mnt/nfs/rabbitmq || true
# mkdir /mnt/nfs/rabbitmq/data || true
mkdir /mnt/nfs/kibana || true
mkdir /mnt/nfs/kibana/data || true
mkdir /mnt/nfs/filebeat || true
mkdir /mnt/nfs/filebeat/data || true
mkdir /mnt/nfs/filebeat/logs || true
mkdir /mnt/nfs/filebeat/logs_usr_share || true
mkdir /mnt/nfs/webgrab || true
mkdir /mnt/nfs/webgrab/config || true
mkdir /mnt/nfs/webgrab/data || true
mkdir /mnt/nfs/logstash || true
mkdir /mnt/nfs/logstash/pipeline || true
mkdir /mnt/nfs/logstash/data || true
mkdir /mnt/nfs/logstash/log || true

REMOTE_USER=${1:-pl}
MYSQL_PASSWORD=${2}
MYSQL_ROOT_PASSWORD=${3}
MYSQL_DATABASE=${4:-playlist}
MYSQL_RESET_DATABASE=${5:-true}

set -euox

cd /home/$REMOTE_USER/synker-docker/

# copy some elastic config
yes | cp elastic/stopwords.txt /mnt/nfs/elastic/synkerconfig
yes | cp elastic/mapping_synker.txt /mnt/nfs/elastic/config
# copy some logstash config
yes | cp logstash/config/*.conf /mnt/nfs/logstash/config/

sudo chmod 777 -R /mnt/nfs

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
awk '{ sub("\r$", ""); print }' .env > env
export $(cat env)

docker stack deploy -c traefik-consul-stack.yml lb
sleep 10
docker stack deploy -c elk-stack.yml elk
#docker stack deploy -c rabbitmq-stack.yml rabbit
docker stack deploy -c ./webgrab/docker-compose.yml webgrab
docker stack deploy -c synker-stack.yml synker

#docker stack deploy -c vpn/openvpn.yml openvpn

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