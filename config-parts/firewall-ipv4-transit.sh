# From TRANSIT to LOCAL
set firewall ipv4 name transit-local default-action 'drop'
set firewall ipv4 name transit-local default-log

set firewall ipv4 name transit-local rule 15 action 'accept'
set firewall ipv4 name transit-local rule 15 description 'Allow BGP from core'
set firewall ipv4 name transit-local rule 15 protocol 'tcp'
set firewall ipv4 name transit-local rule 15 source address '10.254.0.1'
set firewall ipv4 name transit-local rule 15 destination address '10.254.0.0'
set firewall ipv4 name transit-local rule 15 destination port '179'

set firewall ipv4 name transit-local rule 30 action accept
set firewall ipv4 name transit-local rule 30 description 'Allow NTP'
set firewall ipv4 name transit-local rule 30 destination port 123
set firewall ipv4 name transit-local rule 30 destination group address-group 'gateway_ntp'
set firewall ipv4 name transit-local rule 30 protocol udp

set firewall ipv4 name transit-local rule 110 action accept
set firewall ipv4 name transit-local rule 110 description 'Allow access to node_exporter'
set firewall ipv4 name transit-local rule 110 destination port 9100
set firewall ipv4 name transit-local rule 110 destination group address-group 'gateway_metrics'
set firewall ipv4 name transit-local rule 110 source group network-group POD_NETS
set firewall ipv4 name transit-local rule 110 protocol tcp

set firewall ipv4 name transit-local rule 120 action accept
set firewall ipv4 name transit-local rule 120 description 'Allow tftpd access'
set firewall ipv4 name transit-local rule 120 destination port 69
set firewall ipv4 name transit-local rule 120 destination group address-group 'gateway_tftp'
set firewall ipv4 name transit-local rule 120 protocol udp
set firewall ipv4 name transit-local rule 120 source address 10.254.0.0/24 

# From TRANSIT to CONTAINERS
set firewall ipv4 name transit-containers rule 10 action accept
set firewall ipv4 name transit-containers rule 10 description 'Allow DNS'
set firewall ipv4 name transit-containers rule 10 destination port 53
set firewall ipv4 name transit-containers rule 10 destination address 10.5.0.4
set firewall ipv4 name transit-containers rule 10 protocol tcp_udp

set firewall ipv4 name transit-containers rule 110 action accept
set firewall ipv4 name transit-containers rule 110 description 'Allow access to scrape dnsdist'
set firewall ipv4 name transit-containers rule 110 destination port 8083
set firewall ipv4 name transit-containers rule 110 destination address 10.5.0.4
set firewall ipv4 name transit-containers rule 110 source group network-group POD_NETS
set firewall ipv4 name transit-containers rule 110 protocol tcp

set firewall ipv4 name transit-containers rule 120 action accept
set firewall ipv4 name transit-containers rule 120 description 'Allow access to scrape blocky'
set firewall ipv4 name transit-containers rule 120 destination port 4000
set firewall ipv4 name transit-containers rule 120 destination address 10.5.0.7
set firewall ipv4 name transit-containers rule 120 source group network-group POD_NETS
set firewall ipv4 name transit-containers rule 120 protocol tcp

# From TRANSIT to WAN
set firewall ipv4 name transit-wan default-action drop
set firewall ipv4 name transit-wan rule 50 action 'drop'
set firewall ipv4 name transit-wan rule 50 destination geoip country-code 'cn'
set firewall ipv4 name transit-wan rule 50 destination geoip country-code 'ru'
set firewall ipv4 name transit-wan rule 100 action accept
set firewall ipv4 name transit-wan rule 100 description 'Allow K8S to access WAN'
set firewall ipv4 name transit-wan rule 100 source group address-group k8s_nodes

set firewall ipv4 name transit-wan rule 110 action accept
set firewall ipv4 name transit-wan rule 110 description 'Allow truenas to access HTTP'
set firewall ipv4 name transit-wan rule 110 source group address-group STORAGE
set firewall ipv4 name transit-wan rule 110 destination port 80,443
set firewall ipv4 name transit-wan rule 110 protocol tcp

set firewall ipv4 name transit-wan rule 120 action accept
set firewall ipv4 name transit-wan rule 120 description 'Allow pods to access internet'
set firewall ipv4 name transit-wan rule 120 source group network-group POD_NETS

set firewall ipv4 name transit-wan rule 200 action accept
set firewall ipv4 name transit-wan rule 200 description 'Allow dns to access internet'
set firewall ipv4 name transit-wan rule 200 source group network-group DNS_SERVERS

# From TRANSIT to TRUSTED
set firewall ipv4 name transit-trusted default-action drop
set firewall ipv4 name transit-trusted rule 100 action accept
set firewall ipv4 name transit-trusted rule 100 description 'Allow access to node_exporter and smartctl_exporter'
set firewall ipv4 name transit-trusted rule 100 source group network-group POD_NETS
set firewall ipv4 name transit-trusted rule 100 destination port 9100,9633
set firewall ipv4 name transit-trusted rule 100 destination group address-group node_exporter_targets
set firewall ipv4 name transit-trusted rule 100 protocol tcp

set firewall ipv4 name transit-trusted rule 110 action accept
set firewall ipv4 name transit-trusted rule 110 description 'Allow pods to Brother scanner'
set firewall ipv4 name transit-trusted rule 110 source group network-group POD_NETS
set firewall ipv4 name transit-trusted rule 110 destination address 10.1.2.70
set firewall ipv4 name transit-trusted rule 110 destination port 443,54921
set firewall ipv4 name transit-trusted rule 110 protocol tcp

# Home Assistant reaches these Trusted devices from the pod network.
set firewall ipv4 name transit-trusted rule 120 action accept
set firewall ipv4 name transit-trusted rule 120 description 'Allow pods to Anthem A/V control'
set firewall ipv4 name transit-trusted rule 120 source group network-group POD_NETS
set firewall ipv4 name transit-trusted rule 120 destination address 10.1.2.53
set firewall ipv4 name transit-trusted rule 120 destination port 14999
set firewall ipv4 name transit-trusted rule 120 protocol tcp

set firewall ipv4 name transit-trusted rule 130 action accept
set firewall ipv4 name transit-trusted rule 130 description 'Allow pods to Kodi JSON-RPC'
set firewall ipv4 name transit-trusted rule 130 source group network-group POD_NETS
set firewall ipv4 name transit-trusted rule 130 destination address 10.1.2.54
set firewall ipv4 name transit-trusted rule 130 destination port 8080,9090
set firewall ipv4 name transit-trusted rule 130 protocol tcp

set firewall ipv4 name transit-trusted rule 140 action accept
set firewall ipv4 name transit-trusted rule 140 description 'Allow pods to Unfolded Circle remote API'
set firewall ipv4 name transit-trusted rule 140 source group network-group POD_NETS
set firewall ipv4 name transit-trusted rule 140 destination address 10.1.2.56
set firewall ipv4 name transit-trusted rule 140 destination port 80
set firewall ipv4 name transit-trusted rule 140 protocol tcp

set firewall ipv4 name transit-trusted rule 150 action accept
set firewall ipv4 name transit-trusted rule 150 description 'Allow pods to Brother printer SNMP'
set firewall ipv4 name transit-trusted rule 150 source group network-group POD_NETS
set firewall ipv4 name transit-trusted rule 150 destination address 10.1.2.70
set firewall ipv4 name transit-trusted rule 150 destination port 161
set firewall ipv4 name transit-trusted rule 150 protocol udp

# From TRANSIT to IOT
set firewall ipv4 name transit-iot default-action drop

# From TRANSIT to SERVERS
set firewall ipv4 name transit-servers default-action drop
set firewall ipv4 name transit-servers rule 100 action accept
set firewall ipv4 name transit-servers rule 100 description 'Allow access to node_exporter and smartctl_exporter'
set firewall ipv4 name transit-servers rule 100 source group network-group POD_NETS
set firewall ipv4 name transit-servers rule 100 destination port 9100,9633,9290
set firewall ipv4 name transit-servers rule 100 destination group address-group node_exporter_targets
set firewall ipv4 name transit-servers rule 100 protocol tcp

set firewall ipv4 name transit-servers rule 110 action accept
set firewall ipv4 name transit-servers rule 110 description 'Allow access to nix cache'
set firewall ipv4 name transit-servers rule 110 destination port 5000
set firewall ipv4 name transit-servers rule 110 destination address 10.1.1.155
set firewall ipv4 name transit-servers rule 110 protocol tcp

set firewall ipv4 name transit-servers rule 120 action accept
set firewall ipv4 name transit-servers rule 120 description 'Allow access to proxmox nodes'
set firewall ipv4 name transit-servers rule 120 destination group port-group PROXMOX_PORTS
set firewall ipv4 name transit-servers rule 120 destination group address-group PROXMOX_HOSTS
set firewall ipv4 name transit-servers rule 120 protocol tcp

set firewall ipv4 name transit-servers rule 130 action 'accept'
set firewall ipv4 name transit-servers rule 130 description 'Allow pods to deploy PVE IPMI certificates'
set firewall ipv4 name transit-servers rule 130 source group network-group 'POD_NETS'
set firewall ipv4 name transit-servers rule 130 destination address '10.1.1.30'
set firewall ipv4 name transit-servers rule 130 destination port '443'
set firewall ipv4 name transit-servers rule 130 protocol 'tcp'

set firewall ipv4 name transit-servers rule 200 action accept
set firewall ipv4 name transit-servers rule 200 description 'allow k8s access to ollama'
set firewall ipv4 name transit-servers rule 200 destination port 11434
set firewall ipv4 name transit-servers rule 200 destination address 10.1.1.55
set firewall ipv4 name transit-servers rule 200 source group network-group POD_NETS
set firewall ipv4 name transit-servers rule 200 protocol tcp

# From TRANSIT to LAN

set firewall ipv4 name transit-lan default-log

set firewall ipv4 name transit-lan rule 101 action accept
set firewall ipv4 name transit-lan rule 101 description 'Allow access to node_exporter'
set firewall ipv4 name transit-lan rule 101 destination port 9100
set firewall ipv4 name transit-lan rule 101 source group network-group POD_NETS
set firewall ipv4 name transit-lan rule 101 protocol tcp
set firewall ipv4 name transit-lan rule 101 destination group address-group node_exporter_targets

set firewall ipv4 name transit-lan rule 120 action 'accept'
set firewall ipv4 name transit-lan rule 120 description 'Allow pods to access UniFi Network MCP controller'
set firewall ipv4 name transit-lan rule 120 source group network-group 'POD_NETS'
set firewall ipv4 name transit-lan rule 120 destination address '10.1.0.23'
set firewall ipv4 name transit-lan rule 120 destination port '443'
set firewall ipv4 name transit-lan rule 120 protocol 'tcp'
