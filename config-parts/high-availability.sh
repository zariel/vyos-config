#!/bin/vbash

# Trusted IPv4 gateway: VyOS .5/32, backup VM .6/32, shared gateway .1/24.
# Keep the VIP on bond0.20 so the existing zone and NAT interface matches apply.
set high-availability vrrp group TRUSTED description 'Trusted gateway migration failover'
set high-availability vrrp group TRUSTED interface 'bond0.20'
set high-availability vrrp group TRUSTED address '10.1.2.1/24'
set high-availability vrrp group TRUSTED vrid '20'
set high-availability vrrp group TRUSTED priority '200'
set high-availability vrrp group TRUSTED advertise-interval '1'
# trusted-backup has no WAN, so VyOS reclaims the VIP once it is back. The
# delay lets boot finish loading the configuration (about 2.5 minutes) and BGP
# establish before trusted traffic returns.
set high-availability vrrp group TRUSTED preempt-delay '180'
set high-availability vrrp group TRUSTED hello-source-address '10.1.2.5'
set high-availability vrrp group TRUSTED peer-address '10.1.2.6'
set high-availability vrrp group TRUSTED track interface 'bond0.3001'
