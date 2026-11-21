#!/bin/vbash

# IPv4 ICMP policy. Rule 1 of every ruleset accepts related and established
# traffic, which already covers echo replies and the ICMP errors that path MTU
# discovery and traceroute rely on. Rule 5 decides only who may start a ping,
# following zone trust; pings to the gateway are rate limited.
declare -A ping_targets=(
    [local]='wan trusted lan servers iot roon guest containers transit'
    [trusted]='local lan servers iot roon guest containers transit'
    [lan]='local servers transit'
    [transit]='local trusted servers lan iot'
    [servers]='local trusted iot transit'
    [iot]='local'
    [guest]='local'
    [roon]='local'
    [containers]='local'
)

for from in "${!ping_targets[@]}"; do
    for to in ${ping_targets[$from]}; do
        set firewall ipv4 name "$from-$to" rule 5 action 'accept'
        set firewall ipv4 name "$from-$to" rule 5 description 'Rule: allow_ping'
        set firewall ipv4 name "$from-$to" rule 5 protocol 'icmp'
        set firewall ipv4 name "$from-$to" rule 5 icmp type-name 'echo-request'
        if [[ $to == local ]]; then
            set firewall ipv4 name "$from-$to" rule 5 limit rate '10/second'
            set firewall ipv4 name "$from-$to" rule 5 limit burst '20'
        fi
    done
done
unset ping_targets from to
