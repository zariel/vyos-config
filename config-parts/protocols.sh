#!/bin/vbash

# needed to route traffic to WAN
set protocols static route 0.0.0.0/0 dhcp-interface eth3

set protocols static route 10.0.0.0/8 reject

# Keep trusted peers reachable with only the permanent /32 on this interface.
# This static route is not redistributed; VRRP alone creates the connected /24.
set protocols static route 10.1.2.0/24 interface 'bond0.20'

set policy route-map BGP-ALLOW-ALL rule 10 action 'permit'

# Send the core only locally originated routes, including connected ownership.
# A trusted route learned back from the core while BACKUP must not be re-exported.
set policy as-path-list BGP-LOCAL-ORIGIN rule 10 action 'permit'
set policy as-path-list BGP-LOCAL-ORIGIN rule 10 regex '^$'
set policy route-map BGP-TO-CORE rule 10 action 'permit'
set policy route-map BGP-TO-CORE rule 10 match as-path 'BGP-LOCAL-ORIGIN'

# Originate only the connected trusted /24, present while VRRP owns .1/24.
# Exact prefix and interface matches exclude the node /32 and other networks.
set policy prefix-list BGP-CONNECTED-TRUSTED rule 10 action 'permit'
set policy prefix-list BGP-CONNECTED-TRUSTED rule 10 prefix '10.1.2.0/24'
set policy route-map BGP-CONNECTED-TRUSTED rule 10 action 'permit'
set policy route-map BGP-CONNECTED-TRUSTED rule 10 match ip address prefix-list 'BGP-CONNECTED-TRUSTED'
set policy route-map BGP-CONNECTED-TRUSTED rule 10 match interface 'bond0.20'

# Accept only /32 VIPs from the Katl lab's control planes and export nothing.
set policy prefix-list KATL-LAB-VIPS rule 10 action 'permit'
set policy prefix-list KATL-LAB-VIPS rule 10 ge '32'
set policy prefix-list KATL-LAB-VIPS rule 10 le '32'
set policy prefix-list KATL-LAB-VIPS rule 10 prefix '172.31.250.0/24'
set policy route-map KATL-LAB-IN rule 10 action 'permit'
set policy route-map KATL-LAB-IN rule 10 match ip address prefix-list 'KATL-LAB-VIPS'
set policy route-map KATL-LAB-IN rule 10000 action 'deny'
set policy route-map KATL-LAB-OUT rule 10000 action 'deny'

# Advertise only the test destination to the ICX7150 and accept nothing from it.
set policy prefix-list6 ICX7150-TEST rule 10 action 'permit'
set policy prefix-list6 ICX7150-TEST rule 10 prefix '2001:db8:7150::1/128'
set policy route-map ICX7150-V6-OUT rule 10 action 'permit'
set policy route-map ICX7150-V6-OUT rule 10 match ipv6 address prefix-list 'ICX7150-TEST'
set policy route-map ICX7150-V6-IN rule 10 action 'deny'

set protocols bgp system-as '65000'
set protocols bgp parameters router-id '10.254.254.1'
set protocols bgp parameters log-neighbor-changes
set protocols bgp parameters network-import-check
set protocols bgp parameters ebgp-requires-policy

set protocols bgp neighbor 10.254.0.1 description 'ICX7250 core'
set protocols bgp neighbor 10.254.0.1 remote-as '65001'
set protocols bgp neighbor 10.254.0.1 address-family ipv4-unicast
set protocols bgp neighbor 10.254.0.1 address-family ipv4-unicast route-map import 'BGP-ALLOW-ALL'
set protocols bgp neighbor 10.254.0.1 address-family ipv4-unicast route-map export 'BGP-TO-CORE'

set protocols bgp peer-group KATL-LAB remote-as '64513'
set protocols bgp peer-group KATL-LAB address-family ipv4-unicast maximum-prefix '256'
set protocols bgp peer-group KATL-LAB address-family ipv4-unicast route-map import 'KATL-LAB-IN'
set protocols bgp peer-group KATL-LAB address-family ipv4-unicast route-map export 'KATL-LAB-OUT'
set protocols bgp neighbor 10.1.1.110 description 'katl-cp-1'
set protocols bgp neighbor 10.1.1.110 peer-group 'KATL-LAB'
set protocols bgp neighbor 10.1.1.111 description 'katl-cp-2'
set protocols bgp neighbor 10.1.1.111 peer-group 'KATL-LAB'
set protocols bgp neighbor 10.1.1.112 description 'katl-cp-3'
set protocols bgp neighbor 10.1.1.112 peer-group 'KATL-LAB'

set protocols bgp neighbor 2001:db8:3099::2 description 'ICX7150 IPv6 test AS65011'
set protocols bgp neighbor 2001:db8:3099::2 remote-as '65011'
set protocols bgp neighbor 2001:db8:3099::2 address-family ipv6-unicast route-map import 'ICX7150-V6-IN'
set protocols bgp neighbor 2001:db8:3099::2 address-family ipv6-unicast route-map export 'ICX7150-V6-OUT'
# Install a VIP advertised by several control planes as equal-cost paths.
set protocols bgp address-family ipv4-unicast maximum-paths ebgp '3'

set protocols bgp address-family ipv4-unicast redistribute connected route-map 'BGP-CONNECTED-TRUSTED'

set protocols bgp address-family ipv4-unicast network '0.0.0.0/0'
set protocols bgp address-family ipv4-unicast network '10.0.0.0/8'
set protocols bgp address-family ipv4-unicast network '192.168.0.0/16'
set protocols bgp address-family ipv4-unicast network '172.16.0.0/12'
set protocols bgp address-family ipv4-unicast network '10.0.11.0/24'
set protocols bgp address-family ipv4-unicast network '10.1.0.0/24'
set protocols bgp address-family ipv4-unicast network '10.1.1.0/24'
set protocols bgp address-family ipv4-unicast network '10.1.3.0/24'
set protocols bgp address-family ipv4-unicast network '10.1.4.0/24'
set protocols bgp address-family ipv4-unicast network '10.5.0.0/26'
set protocols bgp address-family ipv4-unicast network '10.254.254.1/32'
set protocols bgp address-family ipv4-unicast network '192.168.2.0/24'
set protocols bgp address-family ipv6-unicast network '2001:db8:7150::1/128'

# IPv4 IGMP queries are owned by VyOS on Trusted, IoT and ROON.
# The boot hook enables supervised pimd startup; see docs/multicast.md.
set protocols pim interface bond0.20 passive
set protocols pim interface bond0.20 igmp version 2
set protocols pim interface bond0.20 igmp query-interval 125
set protocols pim interface bond0.20 igmp query-max-response-time 10
set protocols pim interface bond0.40 passive
set protocols pim interface bond0.40 igmp version 2
set protocols pim interface bond0.40 igmp query-interval 125
set protocols pim interface bond0.40 igmp query-max-response-time 10
set protocols pim interface bond0.60 passive
set protocols pim interface bond0.60 igmp version 2
set protocols pim interface bond0.60 igmp query-interval 125
set protocols pim interface bond0.60 igmp query-max-response-time 10

# igmp ipv6 multicast, vyos is querier
set protocols pim6 interface bond0.20 mld version 2
set protocols pim6 interface bond0.20 mld interval 125
# bug in vyos 1.4 cant set this
# set protocols pim6 interface bond0.20 mld max-response-time 10000
set protocols pim6 interface bond0.40 mld version 2
set protocols pim6 interface bond0.40 mld interval 125
# set protocols pim6 interface bond0.40 mld max-response-time 10000

# OTBR advertises its OMR route on VLAN 1100. Restricted RIO learning is
# configured in matter-networks.sh; do not pin a static route to the old IoT IP.
