#!/bin/vbash

set interfaces loopback lo address '10.254.254.1/32'
# Host-owned unicast service addresses; Matchbox .8 remains on the container bridge.
set interfaces loopback lo address '10.5.0.9/32'
set interfaces loopback lo address '10.5.0.10/32'
set interfaces loopback lo address '10.5.0.11/32'

set interfaces ethernet eth0 description 'LAN0'
set interfaces ethernet eth0 hw-id '08:c0:eb:0f:e4:30'
set interfaces ethernet eth0 offload gro
set interfaces ethernet eth0 offload gso
set interfaces ethernet eth0 offload rfs
set interfaces ethernet eth0 offload rps
set interfaces ethernet eth0 offload sg
set interfaces ethernet eth0 offload tso
set interfaces ethernet eth0 ring-buffer rx '8192'
set interfaces ethernet eth0 ring-buffer tx '8192'
set interfaces ethernet eth0 disable-flow-control

delete interfaces ethernet eth0 address

set interfaces ethernet eth1 description 'LAN1'
set interfaces ethernet eth1 hw-id '08:c0:eb:0f:e4:31'
set interfaces ethernet eth1 offload gro
set interfaces ethernet eth1 offload gso
set interfaces ethernet eth1 offload rfs
set interfaces ethernet eth1 offload rps
set interfaces ethernet eth1 offload sg
set interfaces ethernet eth1 offload tso
set interfaces ethernet eth1 ring-buffer rx '8192'
set interfaces ethernet eth1 ring-buffer tx '8192'
set interfaces ethernet eth1 disable-flow-control

delete interfaces ethernet eth1 address

set interfaces bonding bond0 description 'LAN'
set interfaces bonding bond0 mode '802.3ad'
set interfaces bonding bond0 hash-policy 'layer3+4'
set interfaces bonding bond0 lacp-rate 'fast'
set interfaces bonding bond0 mac '08:c0:eb:0f:e4:30'
set interfaces bonding bond0 mtu 9000

# Permanent /32; VRRP group SERVERS adds the shared gateway 10.1.1.1/24.
set interfaces bonding bond0 vif 10 address '10.1.1.5/32'
set interfaces bonding bond0 vif 10 description 'SERVERS'
set interfaces bonding bond0 vif 10 mtu 9000
set interfaces bonding bond0 vif 10 ip adjust-mss 'clamp-mss-to-pmtu'

# The client gateway 10.1.2.1 is owned by VRRP (high-availability.sh).
set interfaces bonding bond0 vif 20 address '10.1.2.5/32'
set interfaces bonding bond0 vif 20 address 'fd74:f571:d3bd:20::1/64'
set interfaces bonding bond0 vif 20 description 'TRUSTED'
set interfaces bonding bond0 vif 20 mtu 1500
set interfaces bonding bond0 vif 20 ip adjust-mss 'clamp-mss-to-pmtu'

set interfaces bonding bond0 vif 30 address '192.168.2.1/24'
set interfaces bonding bond0 vif 30 description 'GUEST'
set interfaces bonding bond0 vif 30 mtu 1500
set interfaces bonding bond0 vif 30 ip adjust-mss 'clamp-mss-to-pmtu'

set interfaces bonding bond0 vif 40 address '10.1.3.1/24'
set interfaces bonding bond0 vif 40 address 'fd74:f571:d3bd:40::1/64'
set interfaces bonding bond0 vif 40 description 'IOT'
set interfaces bonding bond0 vif 40 mtu 1500
set interfaces bonding bond0 vif 40 ip adjust-mss 'clamp-mss-to-pmtu'

set interfaces bonding bond0 vif 60 address '10.1.4.1/24'
set interfaces bonding bond0 vif 60 description 'ROON'
set interfaces bonding bond0 vif 60 mtu 1500
set interfaces bonding bond0 vif 60 ip adjust-mss 'clamp-mss-to-pmtu'
set interfaces bonding bond0 vif 60 ipv6 disable-forwarding
set interfaces bonding bond0 vif 60 ipv6 address no-default-link-local

set interfaces bonding bond0 vif 100 address '10.1.0.1/24'
set interfaces bonding bond0 vif 100 description 'management'
set interfaces bonding bond0 vif 100 mtu 1500

# set interfaces bonding bond0 vif 5 address fd74:f571:d3bd:5::0/127
set interfaces bonding bond0 vif 3001 address 10.254.0.0/31
set interfaces bonding bond0 vif 3001 description 'TRANSIT-ICX'
set interfaces bonding bond0 vif 3001 mtu 9000
set interfaces bonding bond0 vif 3001 ip adjust-mss 'clamp-mss-to-pmtu'
set interfaces bonding bond0 vif 3001 ipv6 adjust-mss 'clamp-mss-to-pmtu'

# Temporary IPv6 BGP test link to the ICX7150, using documentation addresses.
set interfaces bonding bond0 vif 3099 address '2001:db8:3099::1/64'
set interfaces bonding bond0 vif 3099 description 'ICX7150 IPv6 BGP test'
set interfaces dummy dum7150 address '2001:db8:7150::1/128'
set interfaces dummy dum7150 description 'ICX7150 BGP test destination'

set interfaces bonding bond0 member interface eth0
set interfaces bonding bond0 member interface eth1

set interfaces ethernet eth2 hw-id 'a0:36:9f:a9:0d:3a'

# set interfaces ethernet eth2 mtu '1500'

set interfaces dummy dum99 description 'ipv6 dhcp-pd holder'
set interfaces dummy dum99 ipv6 disable-forwarding

set interfaces ethernet eth3 hw-id 'a0:36:9f:a9:0d:3b'
set interfaces ethernet eth3 address 'dhcp'
set interfaces ethernet eth3 description 'WAN'
# DHCPv6-PD supplies addresses; router advertisements supply the default route.
set interfaces ethernet eth3 ipv6 address autoconf
set interfaces ethernet eth3 dhcpv6-options rapid-commit
set interfaces ethernet eth3 dhcpv6-options pd 1 length 56
set interfaces ethernet eth3 dhcpv6-options pd 1 interface dum99 sla-id 0
set interfaces ethernet eth3 dhcpv6-options pd 1 interface dum99 address 0

set interfaces ethernet eth3 disable-flow-control
set interfaces ethernet eth3 hw-id 'a0:36:9f:a9:0d:3b'
set interfaces ethernet eth3 ip adjust-mss 'clamp-mss-to-pmtu'
set interfaces ethernet eth3 ip source-validation 'loose'
set interfaces ethernet eth3 ring-buffer rx '1024'
set interfaces ethernet eth3 ring-buffer tx '1024'

set interfaces ethernet eth4 hw-id '50:9a:4c:4b:f6:0c'
# The onboard NIC is the NixOS gateway's out-of-band port (rescue0); VyOS leaves
# it unnumbered.
set interfaces ethernet eth4 description 'OOB port; cabled to the OOB switch, disabled until the NixOS gateway'
set interfaces ethernet eth4 disable

set interfaces wireguard wg01 address '10.0.11.1/24'
set interfaces wireguard wg01 description 'WIREGUARD'
set interfaces wireguard wg01 peer wall-e allowed-ips '10.0.11.4/32'
set interfaces wireguard wg01 peer wall-e persistent-keepalive '15'
set interfaces wireguard wg01 peer wall-e public-key '0wrH9QqKMRbcnMc41xzwEvLX9xyKY/mB1no94woOAhQ='
set interfaces wireguard wg01 peer chris-macbook allowed-ips '10.0.11.5/32'
set interfaces wireguard wg01 peer chris-macbook public-key 'YDJXbNWbwqA7ipjuVaBrR83Yp6DXocojiFigEIUJnVk='
set interfaces wireguard wg01 peer chris-macbook persistent-keepalive '15'
set interfaces wireguard wg01 peer chris-iphone allowed-ips '10.0.11.6/32'
set interfaces wireguard wg01 peer chris-iphone public-key '8GJVX0GvW7BE8n+G1+Be/IlvJx5rMQyno5bG8iIK1EY='
set interfaces wireguard wg01 peer chris-iphone persistent-keepalive '15'
set interfaces wireguard wg01 port '51820'
set interfaces wireguard wg01 private-key "${SECRET_WIREGUARD_PRIVATE_KEY}"
