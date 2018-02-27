# TODO

## Swarm services to install

- [ ] Install Vault
- [ ] [MariaDb][docker_mariadb] and restore data
- [x] RabbitMQ scale on 2 instances
- [ ] Elk and Filebeat (elastic data scaled on 2 instances) [ex 1][ex_elk2] [ex 2][ex_elk] [ex 3][elk_3]
  - [x] [logstash config][link_logstash_config]
  - [ ] [Elastic config][elastic_off_guide] [elastic docker compose example][elastic_compose_ref]
- [x] WebGrab Synker from commands [docker version](https://github.com/linuxserver/docker-webgrabplus)
- [ ] [Dockbeat](https://github.com/Ingensi/dockbeat) to monitor and log docker deamon into elasticsearch
- [ ] Synker
  - [ ] WebApi       scaled on 2 instances
  - [ ] WebClient    scaled on 2 instances
  - [ ] Batch
  - [ ] Broker
- [ ] DNS configuration for all applications
- [ ] Reverse proxy and LB [traefik][ex_traefik]
- [ ] Fix auto deploy for appveyor and [travis ci](#travis-deploy) [example travis][example_travis]
- [ ] Emby
- [ ] Rancher
- [ ] Redis
- [ ] Install [Tvheadend]

## Others

- [ ] Restore crontab and incrontab
- [ ] Rex-ray (google cloud storage 5G, Ceph, GlusterFS, Network File System (NFS))
- [ ] SSL Elk communication AND [keystore][keystore_logstash]
- [x] Restore Filebeat and Logstash configurations
- [x] Fix [NetShare][NetShare] plugin

### To test

* [filebeat][filebeat]
* [heartbeat][heartbeat]
* [metricbeat][metricbeat]
* [packetbeat][packetbeat]

## Create Swarm by Ansible

- [ ] [Create Swarm by Ansible](https://thisendout.com/2016/09/13/deploying-docker-swarm-with-ansible/)
- [ ] WebGrab
- [ ] ALL custom scripts and crontab
- [ ] Auto creating nfs volumes

## Docker Stack

For elasticsearch to not give Out of Memory errors, we need set vm.max_map_count of the kernel of VMs to atleast 262144. To do this, run the following commands.

```shell

docker-machine ssh manager sudo sysctl -w vm.max_map_count=262144
docker-machine ssh agent1 sudo sysctl -w vm.max_map_count=262144
docker-machine ssh agent2 sudo sysctl -w vm.max_map_count=262144

```

## Travis deploy

[tuto][travis_example_1]

1. Encrypt [certif file][travis_encrypt_file] of ssh connection with travis
2. Encrypt user@host variable
3. Connect to master machine with ssh
4. Get Latest version
5. Deploy stack

`SSH connection and executing remote commands`

```sh

ssh user@host <<'ENDSSH'
#commands to run on remote host
ENDSSH

```

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
[link_logstash_config]:https://www.elastic.co/guide/en/logstash/5.5/docker.html
[keystore_logstash]:https://www.elastic.co/guide/en/logstash/current/keystore.html
[NetShare]:http://netshare.containx.io/docs/getting-started
[elk_3]:https://github.com/elastic/examples/blob/master/Miscellaneous/docker/full_stack_example/docker-compose-linux.yml
[elastic_off_guide]:https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html
[elastic_compose_ref]:https://github.com/elastic/examples/blob/master/Miscellaneous/docker/full_stack_example/docker-compose-linux.yml
[docker_mariadb]:https://docs.docker.com/samples/library/mariadb
[example_travis]:https://www.linux.com/learn/automatically-deploy-build-images-travis
[travis_encrypt_file]:https://docs.travis-ci.com/user/encrypting-files/
[travis_example_1]:https://www.linux.com/learn/automatically-deploy-build-images-travis
[RabbitMQ_Image_repo]:https://github.com/lovelysystems/rabbitmq-swarm-cluster