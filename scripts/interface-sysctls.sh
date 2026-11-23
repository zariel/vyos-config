#!/bin/sh
set -eu

# Per-interface IPv6 RA settings for the IoT and Matter controller VLANs.
# VyOS's `system sysctl` validates keys against the running kernel, and the
# VLANs do not exist when the boot configuration is validated, so these keys
# would make the whole node fail to load. This runs from the postconfig boot
# script and as a commit post-hook, so a commit that recreates a VLAN restores
# them. A missing interface is skipped.

set_iface() {
  interface=$1
  shift
  dir=/proc/sys/net/ipv6/conf/$interface
  [ -d "$dir" ] || return 0
  for kv in "$@"; do
    echo "${kv#*=}" | sudo -n tee "$dir/${kv%%=*}" >/dev/null
  done
}

# IoT: never learn router advertisements.
set_iface bond0.40 accept_ra=0

# Matter controllers: learn only OTBR's /64 route information options, without
# addresses, a default router or MTU, and ignore redirects.
set_iface bond0.1100 \
  accept_ra_defrtr=0 \
  accept_ra_pinfo=0 \
  accept_ra_mtu=0 \
  accept_ra_rtr_pref=1 \
  accept_ra_rt_info_min_plen=64 \
  accept_ra_rt_info_max_plen=64 \
  accept_redirects=0
