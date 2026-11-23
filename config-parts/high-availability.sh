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

# Servers IPv4 gateway: VyOS .5/32, backup VM .6/32, shared gateway .1/24. It
# gives trusted clients the servers VLAN (builder, Proxmox, PBS) through the
# backup VM while VyOS is down.
set high-availability vrrp group SERVERS description 'Servers gateway failover'
set high-availability vrrp group SERVERS interface 'bond0.10'
set high-availability vrrp group SERVERS address '10.1.1.1/24'
set high-availability vrrp group SERVERS vrid '10'
set high-availability vrrp group SERVERS priority '200'
set high-availability vrrp group SERVERS advertise-interval '1'
set high-availability vrrp group SERVERS preempt-delay '180'
set high-availability vrrp group SERVERS hello-source-address '10.1.1.5'
set high-availability vrrp group SERVERS peer-address '10.1.1.6'
set high-availability vrrp group SERVERS track interface 'bond0.3001'

# Both gateways must belong to the same router: split ownership would route
# trusted-servers traffic in through one router and back through the other,
# and each firewall would drop its half of the connection.
set high-availability vrrp sync-group GATEWAY member 'TRUSTED'
set high-availability vrrp sync-group GATEWAY member 'SERVERS'
