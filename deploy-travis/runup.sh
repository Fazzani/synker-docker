#!/bin/bash

### ### ### ### ### ### ### ### ### ### ###
# Deploy script for Synker docker stack
### ### ### ### ### ### ### ### ### ### ###

script=$(basename "$0")

function log {
   echo -e "[$(date +"%d-%m-%Y %H:%M:%S") $HOSTNAME $USER $script] $1" 
}

function set_folder_permission {
  sudo chmod 777 -R /mnt/nfs/elastic
  sudo chmod 777 -R /mnt/nfs/consul
  sudo chmod 777 -R /mnt/nfs/synker
  #sudo chmod 777 -R /mnt/nfs/mariadb
  sudo chmod 777 -R /mnt/nfs/rabbitmq
  sudo chmod 777 -R /mnt/nfs/kibana
  sudo chmod 777 -R /mnt/nfs/filebeat
  sudo chmod 777 -R /mnt/nfs/webgrab
  sudo chmod 777 -R /mnt/nfs/logstash
  sudo chmod 777 -R /mnt/nfs/postgres
  # sudo chmod 777 /mnt/nfs/emby
}

function create_shares {
  sudo mkdir /mnt/nfs/elastic || true
  sudo mkdir /mnt/nfs/elastic/data || true
  sudo mkdir /mnt/nfs/elastic/config || true
  sudo mkdir /mnt/nfs/elastic/synkerconfig || true
  sudo mkdir /mnt/nfs/consul        || true
  sudo mkdir /mnt/nfs/consul/data || true
  sudo mkdir /mnt/nfs/synker || true
  sudo mkdir /mnt/nfs/synker/data || true
  sudo mkdir /mnt/nfs/postgres || true
  sudo mkdir /mnt/nfs/postgres/data || true
#  sudo mkdir /mnt/nfs/mariadb || true
#  sudo mkdir /mnt/nfs/mariadb/data || true
  sudo mkdir /mnt/nfs/rabbitmq || true
  sudo mkdir /mnt/nfs/rabbitmq/data || true
  sudo mkdir /mnt/nfs/rabbitmq/data/mnesia || true
  sudo mkdir /mnt/nfs/kibana || true
  sudo mkdir /mnt/nfs/kibana/data || true
  sudo mkdir /mnt/nfs/filebeat || true
  sudo mkdir /mnt/nfs/filebeat/data || true
  sudo mkdir /mnt/nfs/filebeat/logs || true
  sudo mkdir /mnt/nfs/filebeat/logs_usr_share || true
  sudo mkdir /mnt/nfs/webgrab || true
  sudo mkdir /mnt/nfs/webgrab/config || true
  sudo mkdir /mnt/nfs/webgrab/data || true
  sudo mkdir /mnt/nfs/webgrab/log || true
  sudo mkdir /mnt/nfs/logstash || true
  sudo mkdir /mnt/nfs/logstash/pipeline || true
  sudo mkdir /mnt/nfs/logstash/data || true
  sudo mkdir /mnt/nfs/logstash/log || true
  sudo mkdir /mnt/nfs/logstash/config || true
  # sudo mkdir /mnt/nfs/emby || true
  # sudo mkdir /mnt/nfs/emby/config || true
  # sudo mkdir /mnt/nfs/emby/data || true
  sudo mkdir /mnt/nfs/freebox || true
}

set +e

REMOTE_USER=$1
MYSQL_PASSWORD=$2
POSTGRES_PASSWORD=$2
MYSQL_ROOT_PASSWORD=$3
MYSQL_DATABASE=${4:-playlist}
MYSQL_RESET_DATABASE=${5:-false}
SYNKER_VERSION=${6:-0.0.77}

create_shares
set_folder_permission

set -euox

cd /home/${REMOTE_USER}/synker-docker/

# copy some elastic config
yes | cp elastic/stopwords.txt /mnt/nfs/elastic/synkerconfig
yes | cp elastic/mapping_synker.txt /mnt/nfs/elastic/config
# copy some logstash config
yes | cp logstash/config/*.conf /mnt/nfs/logstash/config/
yes | cp logstash/config/*.yml /mnt/nfs/logstash/config/

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

echo $POSTGRES_PASSWORD > postgres_password.txt
awk '{ sub("\r$", ""); print }' .env > env
export $(cat env)
echo $TAG
export SYNKER_VERSION=$SYNKER_VERSION
sudo docker stack deploy -c 1-consul-stack.yml consul
sleep 15
sudo docker stack deploy -c 2-traefik-init-stack.yml lb
sleep 10
sudo docker stack deploy -c 3-traefik-stack.yml lb
sudo docker stack deploy -c 4-elk-stack.yml elk
sudo docker stack deploy -c ./webgrab/docker-compose.yml webgrab
sudo docker stack deploy -c 5-synker-stack.yml synker
#sudo docker stack deploy -c postgres-stack.yml postresql
#sudo docker stack deploy -c ./others/others-stack.yml others

#docker stack deploy -c vpn/openvpn.yml openvpn

log "Clean up ..."
sudo docker system prune -f

# Restoring maridb data 
# Must be running on mariadb host container
sleep 15

if [ "$MYSQL_RESET_DATABASE" = true ] ; then
   SERVICE_ID=$(sudo docker service ps -q -f desired-state=running  synker_synkerdb | head -1)
   CONTAINER_ID=$(sudo docker inspect --format "{{.Status.ContainerStatus.ContainerID}}" $SERVICE_ID | head -1)
   cat ./synker/playlist.dump-2018-05-21.sql | \
   sudo docker exec -i -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" -e MYSQL_DATABASE="${MYSQL_DATABASE}" $CONTAINER_ID \
   mysql -u root -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" --force
fi
exit 0