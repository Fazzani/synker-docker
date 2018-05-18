# SYNKER docker deploy stack

[![Build Status](https://travis-ci.org/Fazzani/synker-docker.svg?branch=master)](https://travis-ci.org/Fazzani/synker-docker)

## TODO

### Swarm services to install

- [x] [MariaDb][docker_mariadb] see [official registry][mariadb_registry]
  - [x] Compose file
  - [x] Resotre data
  - [ ] Test galera version (distributed version)
- [x] RabbitMQ scale on 2 instances [Image to upgrade version][RabbitMQ_Image_repo]
- [ ] Elk and Filebeat (elastic data scaled on 2 instances) [ex 1][ex_elk2] [ex 2][ex_elk] [ex 3][elk_3]
  - [x] [logstash config][link_logstash_config]
  - [ ] [Elastic config][elastic_off_guide] [elastic docker compose example][elastic_compose_ref]
- [x] WebGrab Synker from commands [docker version](https://github.com/linuxserver/docker-webgrabplus)
- [ ] [Dockbeat](https://github.com/Ingensi/dockbeat) to monitor and log docker deamon into elasticsearch
- [x] Synker
  - [x] WebApi       scaled on 2 instances
  - [x] WebClient    scaled on 2 instances
  - [x] Batch
  - [x] Broker
- [ ] Reverse proxy and LB [traefik][ex_traefik] [good example][traefix_good_example]
  - [ ] Circuit breaker
  - [ ] Sub domains configuration
  - [x] Lets Encrypt certification (broken => there is an issue on that)
  - [x] Create internal network for backend services
  - [x] LB
- [ ] Fix auto deploy for appveyor and [travis ci](#travis-deploy) [example travis][example_travis]
- [ ] Monitoring/alerting all the cluster (Prometheus)
- [x] Emby
- [ ] Redis
- [ ] Install Vault
- [ ] Install [Tvheadend]
- [x] Upgrading Docker
- [x] Gluster fs
- [x] Fix rabbitmq docker service not go on when running rundown.sh script
- [ ] Dockerfile manifest
- [ ] Auto backup/Restore database
  - [x] Restore
  - [ ] Daily Backup
- [ ] Auto backup/Restore nfs share storage

### Others

- [ ] xlf files (Internationalisation)
- [x] Test dokcer remote api
- [ ] [Appveyor for linux CI/CD][appveyor_linux]
- [x] Replace npm by [Yarn][vs2017_yarn]
- [ ] Restore crontab and incrontab
- [ ] Rex-ray (google cloud storage 5G, Ceph, GlusterFS, Network File System (NFS))
- [ ] SSL Elk communication AND [keystore][keystore_logstash]
- [x] Restore Filebeat and Logstash configurations
- [x] Fix [NetShare][NetShare] plugin

#### To test

* [filebeat][filebeat]
* [heartbeat][heartbeat]
* [metricbeat][metricbeat]
* [packetbeat][packetbeat]

### Create Swarm by Ansible

- [x] [Create Swarm by Ansible](https://thisendout.com/2016/09/13/deploying-docker-swarm-with-ansible/)
- [ ] WebGrab
- [ ] ALL custom scripts and crontab
- [ ] Auto creating nfs volumes

### Docker Stack

For elasticsearch to not give Out of Memory errors, we need set vm.max_map_count of the kernel of VMs to atleast 262144. To do this, run the following commands.

```shell

docker-machine ssh manager sudo sysctl -w vm.max_map_count=262144
docker-machine ssh agent1 sudo sysctl -w vm.max_map_count=262144
docker-machine ssh agent2 sudo sysctl -w vm.max_map_count=262144

```

`SSH connection and executing remote commands`

```sh
ssh user@host <<'ENDSSH'
#commands to run on remote host
ENDSSH

```

### Create ansible user and add permissions

```sh
visudo
# Put the line after all other lines in the sudoers file
ansible    ALL=(ALL) NOPASSWD:ALL
```

### Docker node labels (on manager node)

ssh ansible@ovh1 "sudo docker node update --label-add size=large --label-add provider=ovh vps448126 &&
sudo docker node update --label-add size=medium --label-add provider=ovh vps507934 &&
sudo docker node update --label-add size=small --label-add provider=arub arub1 &&
sudo docker node update --label-add size=small --label-add provider=arub arub2 &&
sudo docker node update --label-add size=small --label-add provider=arub arub3"

### travis encrypt file

In bash windows

```sh
cd /mnt/c/Users/Heni/Source/Repos/synker-docker
tar cvf secret.tar ./synker/* deploy_rsa .env
travis encrypt-file secret.tar --add

# Copy public key to deployment host (ovh1)
ssh ansible@ovh1 "cat  >> ~/.ssh/authorized_keys" < ../synker-docker/deploy_rsa.pub
```

## NOTES

>To backup mysql database we have to set `MYSQL_RESET_DATABASE` to true in travis build

[beats]: https://www.elastic.co/products/beats
[elastic]: https://www.elastic.co/
[filebeat]: https://www.elastic.co/guide/en/beats/filebeat/current/running-on-docker.html
[heartbeat]: https://www.elastic.co/guide/en/beats/heartbeat/current/running-on-docker.html
[metricbeat]: https://www.elastic.co/guide/en/beats/metricbeat/current/running-on-docker.html
[packetbeat]: https://www.elastic.co/guide/en/beats/packetbeat/current/running-on-docker.html
[Tvheadend]:https://github.com/linuxserver/docker-tvheadend
[ex_traefik]:https://zerokspot.com/weblog/2017/09/03/docker-stacks-for-local-development/
[ex_elk]:https://github.com/elastic/stack-docker/blob/master/docker-compose.yml
[ex_elk2]:https://github.com/ahromis/swarm-elk
[elk_3]:https://github.com/elastic/examples/blob/master/Miscellaneous/docker/full_stack_example/docker-compose-linux.yml
[elastic_compose_ref]:https://github.com/elastic/examples/blob/master/Miscellaneous/docker/full_stack_example/docker-compose-linux.yml
[elastic_off_guide]:https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html
[link_logstash_config]:https://www.elastic.co/guide/en/logstash/5.5/docker.html
[keystore_logstash]:https://www.elastic.co/guide/en/logstash/current/keystore.html
[NetShare]:http://netshare.containx.io/docs/getting-started
[docker_mariadb]:https://docs.docker.com/samples/library/mariadb
[example_travis]:https://www.linux.com/learn/automatically-deploy-build-images-travis
[travis_encrypt_file]:https://docs.travis-ci.com/user/encrypting-files/
[travis_example_1]:https://www.linux.com/learn/automatically-deploy-build-images-travis
[RabbitMQ_Image_repo]:https://github.com/harbur/docker-rabbitmq-cluster
[mariadb_registry]:https://hub.docker.com/_/mariadb/
[traefix_good_example]:https://medium.com/lucjuggery/docker-clouds-swarm-mode-feature-702bfae9bf23
[appveyor_linux]:https://www.appveyor.com/docs/getting-started-with-appveyor-for-linux/
[vs2017_yarn]:https://elanderson.net/2018/01/change-asp-net-core-from-npm-to-yarn/