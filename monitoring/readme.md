# Synker Monitoring

## Swarm monitoring stack

- Prometheus
- AlertManager
- Grafana
- Unsee
- CAdvisor
- Node-exporter

## Prometheus schema

![Prometheus](https://blog.octo.com/wp-content/uploads/2017/03/prom-archi.png 'Prometheus schema')

## TODO

- [ ] Synker APP Metrics
- [ ] Prometheus pushgateway
- [ ] Caddy: swarmstack/caddy:no-stats-0.11.5
- [ ] Synker Apps Metrics to Prometheus / Grafana dashboard
- [ ] Grafana db to postgre
- [ ] AlertManager en mode cluster
- [x] AlertManager // Slack, sendgrid
- [x] Register all Prometheus exporters by service discovery (consul/swarm dns)

### Tasks to install for more monitoring

```yaml
collectd:
  image: prom/collectd-exporter
  ports:
    - 9103:9103
  networks:
    - monitoring

pushgateway:
  image: prom/pushgateway:v0.7.0

caddy:
  image: swarmstack/caddy:no-stats-0.11.5
```

## References

- [Reference swarm 1](https://github.com/swarmstack/swarmstack/blob/master/docker-compose.yml)
- [Alerting with Grafana and Slack Example](https://medium.com/pharos-production/grafana-alerting-and-slack-notifications-3affe9d5f688)
- [Source 2](https://github.com/stefanprodan/swarmprom)
- [Source 3](https://blog.octo.com/exemple-dutilisation-de-prometheus-et-grafana-pour-le-monitoring-dun-cluster-kubernetes/)
