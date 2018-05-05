#!/bin/bash

### ### ### ### ### ### ### ### ### ### ###
# Deploy script for Synker docker stack
### ### ### ### ### ### ### ### ### ### ###

function set_folder_permission {
  chmod 777 -R /mnt/nfs/elastic
  chmod 777 -R /mnt/nfs/consul
  chmod 777 -R /mnt/nfs/synker
  chmod 777 -R /mnt/nfs/mariadb
  chmod 777 -R /mnt/nfs/rabbitmq
  chmod 777 -R /mnt/nfs/kibana
  chmod 777 -R /mnt/nfs/filebeat
  chmod 777 -R /mnt/nfs/webgrab
  chmod 777 -R /mnt/nfs/logstash
  chmod 777 /mnt/nfs/emby
}

function create_shares {
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
  mkdir /mnt/nfs/rabbitmq || true
  mkdir /mnt/nfs/rabbitmq/data || true
  mkdir /mnt/nfs/rabbitmq/data/mnesia || true
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
  mkdir /mnt/nfs/logstash/config || true
  mkdir /mnt/nfs/emby || true
  mkdir /mnt/nfs/emby/config || true
  mkdir /mnt/nfs/emby/data || true
  mkdir /mnt/nfs/freebox || true
}

set +e

REMOTE_USER=$1
MYSQL_PASSWORD=$2
MYSQL_ROOT_PASSWORD=$3
MYSQL_DATABASE=${4:-playlist}
MYSQL_RESET_DATABASE=${5:-false}

create_shares

set -euox

cd /home/${REMOTE_USER}/synker-docker/

# copy some elastic config
yes | cp elastic/stopwords.txt /mnt/nfs/elastic/synkerconfig
yes | cp elastic/mapping_synker.txt /mnt/nfs/elastic/config
# copy some logstash config
yes | cp logstash/config/*.conf /mnt/nfs/logstash/config/

set_folder_permission

if [ "$MYSQL_RESET_DATABASE" = true ]; then
  rm  -rf /mnt/nfs/mariadb/data/*
fi

sudo docker network create --driver overlay ntw_front \
  --attachable || true \
  --opt encrypted=true || true

sudo docker network create --driver overlay ingress_net_backend \
  --attachable || true \
  --subnet=70.28.0.0/16 \
  --opt com.docker.network.driver.mtu=9216 \
  --opt encrypted=true || true

echo $MYSQL_PASSWORD > mysql_password.txt
echo $MYSQL_ROOT_PASSWORD > mysql_root_password.txt
awk '{ sub("\r$", ""); print }' .env > env
export $(cat env)
echo $TAG
sudo docker stack deploy -c traefik-consul-stack.yml lb
sleep 10
sudo docker stack deploy -c elk-stack.yml elk
#docker stack deploy -c rabbitmq-stack.yml rabbit
sudo docker stack deploy -c ./webgrab/docker-compose.yml webgrab
sudo docker stack deploy -c synker-stack.yml synker
sudo docker stack deploy -c ./others/others-stack.yml others

#docker stack deploy -c vpn/openvpn.yml openvpn

echo "Clean up ..."
sudo docker system prune -f

# Restoring maridb data 
# Must be running on mariadb host container
sleep 15

if [ "$MYSQL_RESET_DATABASE" = true ] ; then
   SERVICE_ID=$(sudo docker service ps -q -f desired-state=running  synker_synkerdb | head -1)
   CONTAINER_ID=$(sudo docker inspect --format "{{.Status.ContainerStatus.ContainerID}}" $SERVICE_ID | head -1)
   cat ./synker/playlist.dump-2018-02-28.sql | \
   sudo docker exec -i -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" -e MYSQL_DATABASE="${MYSQL_DATABASE}" $CONTAINER_ID \
   mysql -u root -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" --force
fi
exit 0