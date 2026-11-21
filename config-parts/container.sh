#!/bin/vbash

# Container networks
set container network containers description 'Network for VyOS containers'
set container network containers prefix '10.5.0.0/26'
set container network containers prefix 'fd74:f571:d3bd:1005::/64'

# node-exporter
set container name node-exporter arguments '--web.listen-address=10.5.0.11:9100 --web.listen-address=10.254.254.1:9100'
set container name node-exporter environment procfs value '/host/proc'
set container name node-exporter environment rootfs value '/host/rootfs'
set container name node-exporter environment sysfs value '/host/sys'
set container name node-exporter image 'quay.io/prometheus/node-exporter:v1.12.1'
set container name node-exporter memory '0'
set container name node-exporter allow-host-networks
set container name node-exporter restart 'on-failure'
set container name node-exporter shared-memory '0'
set container name node-exporter volume procfs source '/proc'
set container name node-exporter volume procfs destination '/host/proc'
set container name node-exporter volume procfs mode 'ro'
set container name node-exporter volume rootfs source '/'
set container name node-exporter volume rootfs destination '/host/rootfs'
set container name node-exporter volume rootfs mode 'ro'
set container name node-exporter volume sysfs source '/sys'
set container name node-exporter volume sysfs destination '/host/sys'
set container name node-exporter volume sysfs mode 'ro'

# matchbox
set container name matchbox arguments '-address=0.0.0.0:80 -log-level=debug'
set container name matchbox cap-add 'net-bind-service'
set container name matchbox image 'quay.io/poseidon/matchbox:v0.11.0'
set container name matchbox memory '0'
set container name matchbox network containers address '10.5.0.8'
set container name matchbox shared-memory '0'
set container name matchbox volume matchbox-data destination '/var/lib/matchbox'
set container name matchbox volume matchbox-data mode 'rw'
set container name matchbox volume matchbox-data propagation 'private'
set container name matchbox volume matchbox-data source '/config/containers/matchbox'

# Roon discovery is restricted to the two VLAN interfaces and UDP 9003.
set container name roon-discovery description 'Roon discovery between Trusted and ROON'
set container name roon-discovery image 'docker.io/synfinatic/udp-proxy-2020@sha256:71fb9b54f5a019d40e256490d50c5d25b120965f1332ec97d16a36ff30cda52c'
set container name roon-discovery allow-host-networks
set container name roon-discovery cap-add 'net-raw'
set container name roon-discovery environment INTERFACES value 'bond0.20,bond0.60'
set container name roon-discovery environment PORTS value '9003'
set container name roon-discovery restart 'always'
set container name roon-discovery entrypoint '/bin/sh /usr/local/bin/start-roon-discovery'
set container name roon-discovery volume startup source '/config/scripts/start-roon-discovery.sh'
set container name roon-discovery volume startup destination '/usr/local/bin/start-roon-discovery'
set container name roon-discovery volume startup mode 'ro'
