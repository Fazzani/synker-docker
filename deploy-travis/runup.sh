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
  #sudo chmod 777 -R /mnt/nfs/logstash
  sudo chmod 777 -R /mnt/nfs/postgres
  sudo chmod 777 -R /mnt/nfs/nginx-proxy
  sudo chmod 777 -R /mnt/nfs/traefik
  sudo chmod 777 -R /mnt/nfs/domotic
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
  sudo mkdir /mnt/nfs/rabbitmq || true
  sudo mkdir /mnt/nfs/rabbitmq/config || true
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
  sudo mkdir /mnt/nfs/webgrab/config/sitepack || true
  sudo mkdir /mnt/nfs/webgrab/data || true
  sudo mkdir /mnt/nfs/webgrab/log || true
  #sudo mkdir /mnt/nfs/logstash || true
  #sudo mkdir /mnt/nfs/logstash/pipeline || true
  #sudo mkdir /mnt/nfs/logstash/data || true
  #sudo mkdir /mnt/nfs/logstash/log || true
  #sudo mkdir /mnt/nfs/logstash/config || true
  # sudo mkdir /mnt/nfs/emby || true
  # sudo mkdir /mnt/nfs/emby/config || true
  # sudo mkdir /mnt/nfs/emby/data || true
  sudo mkdir /mnt/nfs/freebox || true
  sudo mkdir /mnt/nfs/nginx-proxy || true
  sudo mkdir /mnt/nfs/nginx-proxy/html || true
  sudo mkdir /mnt/nfs/nginx-proxy/log || true
  sudo mkdir /mnt/nfs/traefik || true
  sudo mkdir /mnt/nfs/traefik/log || true
  sudo mkdir /mnt/nfs/domotic || true
  sudo mkdir /mnt/nfs/domotic/data || true
  sudo mkdir /mnt/nfs/domotic/db || true
  sudo mkdir /mnt/nfs/domotic/db/data || true
  sudo mkdir /mnt/nfs/domotic/mongodb || true
  sudo mkdir /mnt/nfs/domotic/mongodb/data || true
}

set +e

REMOTE_USER=$1
MYSQL_PASSWORD=$2
POSTGRES_PASSWORD=$2
MYSQL_ROOT_PASSWORD=$3
MYSQL_DATABASE=${4:-playlist}
MYSQL_RESET_DATABASE=${5:-false}
echo "script param 6 => $6"
SYNKER_VERSION=${6:-0.0.93}

create_shares
set_folder_permission

set -euox

cd /home/${REMOTE_USER}/synker-docker/

# copy some elastic config
yes | cp -rf elastic/stopwords.txt /mnt/nfs/elastic/synkerconfig
yes | cp -rf elastic/mapping_synker.txt /mnt/nfs/elastic/config
yes | cp -rf nginx-proxy/index.html /mnt/nfs/nginx-proxy/html
yes | cp -rf nginx-proxy/favicon.ico /mnt/nfs/nginx-proxy/html

yes | cp -rf ./configs/definitions.json /mnt/nfs/rabbitmq/config
yes | cp -rf ./configs/rabbitmq.config /mnt/nfs/rabbitmq/config
# copy some logstash config
# yes | cp logstash/config/*.conf /mnt/nfs/logstash/config/
# yes | cp logstash/config/*.yml /mnt/nfs/logstash/config/

set_folder_permission

if [ "$MYSQL_RESET_DATABASE" = true ]; then
  rm  -rf /mnt/nfs/mariadb/data/*
fi

sudo docker network create --driver overlay ntw_front \
  --attachable \
  --subnet=10.0.0.0/24 \
  --opt encrypted=true || true

sudo docker network create --driver overlay ingress_net_backend \
  --attachable \
  --subnet=70.28.0.0/16 \
  --opt com.docker.network.driver.mtu=9216 \
  --opt encrypted=true || true

echo $POSTGRES_PASSWORD > postgres_password.txt
awk '{ sub("\r$", ""); print }' .env > env
export $(cat env)
echo $TAG
export SYNKER_VERSION=$SYNKER_VERSION
sudo docker stack deploy -c 1-consul-stack.yml sd
sleep 15
sudo docker stack deploy -c 2-traefik-init-stack.yml traefik-init
sleep 10
sudo docker stack deploy -c 3-traefik-stack.yml lb
sudo docker stack deploy -c 4-elk-stack.yml elk
sudo docker stack deploy -c ./webgrab/docker-compose.yml webgrab
sudo docker stack deploy -c 5-synker-stack.yml synker
sudo docker stack deploy -c 6-xviewer-stack.yml xviewer
sudo docker stack deploy -c 8-mongo-stack.yml mongo
# sudo docker stack deploy -c 7-domotic-stack.yml --resolve-image never domotic
#sudo docker stack deploy -c postgres-stack.yml postresql
#sudo docker stack deploy -c ./others/others-stack.yml others

#docker stack deploy -c vpn/openvpn.yml openvpn

log "Clean up ..."
sudo docker system prune -f

# Restoring maridb data 
# Must be running on mariadb host container
sleep 15
log "add sitepack.ini pipeline to elasticsearch"
curl -k --insecure -H 'Content-Type: application/json' -XPUT 'https://elastic.synker.ovh/_ingest/pipeline/sitepack_pipeline' -d "@webgrab/sitepack_pipeline.json"

if [ "$MYSQL_RESET_DATABASE" = true ] ; then
   SERVICE_ID=$(sudo docker service ps -q -f desired-state=running  synker_synkerdb | head -1)
   CONTAINER_ID=$(sudo docker inspect --format "{{.Status.ContainerStatus.ContainerID}}" $SERVICE_ID | head -1)
   cat ./synker/playlist.dump-2018-05-21.sql | \
   sudo docker exec -i -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" -e MYSQL_DATABASE="${MYSQL_DATABASE}" $CONTAINER_ID \
   mysql -u root -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" --force
fi
exit 0