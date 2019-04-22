# Synker Monitoring

[Reference swarm 1](https://github.com/swarmstack/swarmstack/blob/master/docker-compose.yml)
[Source 2](https://github.com/stefanprodan/swarmprom)

## Prometheus schema

![Prometheus](https://blog.octo.com/wp-content/uploads/2017/03/prom-archi.png 'Prometheus schema')

## TODO

- [ ] Synker APP Metrics
- [ ] AlertManager // Slack, sendgrid
- [ ] Grafana db to postgre
- [ ] Synker Apps Metrics to Prometheus / Grafana dashboard
- [ ] Prometheus pushgateway
- [ ] caddy: swarmstack/caddy:no-stats-0.11.5
- [ ] AlertManager en mode cluster
- [x] Register all Prometheus exporters by service discovery (consul/swarm dns)

```yaml
 collectd:
   image: prom/collectd-exporter
   ports:
     - 9103:9103
   restart: always
   networks:
     - promnet

 pushgateway:
   image: prom/pushgateway:v0.7.0

 caddy:
   image: swarmstack/caddy:no-stats-0.11.5
```