# Synker Monitoring

[Reference swarm 1](https://github.com/swarmstack/swarmstack/blob/master/docker-compose.yml)
[Source 2](https://github.com/stefanprodan/swarmprom)

## TODO

- Alert Manager // Slack, sendgrid
- Prometheus service discovery (consul)
- Grafana db to postgre
- Synker Apps Metrics to Prometheus / Grafana dashboard
- pushgateway
- caddy: swarmstack/caddy:no-stats-0.11.5
- AlertManager en mode cluster

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