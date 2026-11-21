#!/bin/sh
set -eu

# VyOS starts containers before VRRP assigns Trusted's /24. The relay reads
# interface subnets once at startup to build its capture and broadcast rules.
until ip -4 -o addr show dev bond0.20 | grep -Fq ' 10.1.2.1/24 '; do
  sleep 1
done

exec /usr/local/bin/udp-proxy-2020 --interface "$INTERFACES" --port "$PORTS"
