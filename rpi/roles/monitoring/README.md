# monitoring

Sets up various monitoring and observability.

For now, this requires manually creating files (secrets) on the hosts in order
to run, but as soon as the yubikeys arrive, I will setup ansible-vault.

## grafana

- https://grafana.com/docs/grafana-cloud/monitor-infrastructure/integrations/integration-reference/integration-raspberry-pi-node/

## healthchecks.io

Sets up a simple uptime check to [healthchecks.io](https://healthchecks.io).

Create a file in `/root/hc-ping-uuid.txt` with the UUID for the desired check.
