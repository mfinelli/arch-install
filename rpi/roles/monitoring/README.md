# monitoring

Sets up various monitoring and observability.

For now, this requires manually creating files (secrets) on the hosts in order
to run, but as soon as the yubikeys arrive, I will setup ansible-vault.

## grafana

Installs and configures the `grafana-agent` to send metrics and logs to our
[Grafana Cloud](https://grafana.com/products/cloud/) instance.

You must populate the following files with the appropriate values or this role
won't do anything. (You can find the correct values by going to grafana, going
to "Connections", "Add a new connection", pick "Agent Configuration", "Use an
existing token" and then it will pop up their setup script with the values
set). This role essentially reverse-engineers that script.

- /root/grafana-api-key.txt
- /root/grafana-logs-id.txt
- /root/grafana-logs-url.txt
- /root/grafana-metrics-id.txt
- /root/grafana-metrics-url.txt

References:

- https://storage.googleapis.com/cloud-onboarding/agent/scripts/static/install-linux.sh
- https://grafana.com/docs/grafana-cloud/monitor-infrastructure/integrations/integration-reference/integration-raspberry-pi-node/
- https://storage.googleapis.com/cloud-onboarding/agent/config/config.yaml

## healthchecks.io

Sets up a simple uptime check to [healthchecks.io](https://healthchecks.io).

Create a file in `/root/hc-ping-uuid.txt` with the UUID for the desired check.
