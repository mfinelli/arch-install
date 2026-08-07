# monitoring

Sends system metrics and logs to a self-hosted
[VictoriaMetrics](https://victoriametrics.com) instance using
[vector](https://vector.dev).

The Debian install instructions were created by reverse-engineering the setup
script: https://setup.vector.dev.

Note that we add the systemd hardening options based on the
`hardened-vector.service` unit that ships with the Arch Linux package. We apply
it unconditionally to avoid needing to call either "hardened-vector.service"
or "vector.service" depending on the system: we can just always use "vector.service".
