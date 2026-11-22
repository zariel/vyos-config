# Network addressing

NetBox is the allocation authority. The host service addressing policy is
maintained in the infra workspace as `docs/host-services.md` and covers address ownership,
per-host allocation, shared VIPs and the staged gateway migration.

Reserve `10.5.0.0/16` for host-owned services, with one `/26` per host. The gateway
owns `10.5.0.0/26`, advertised to the core. Matchbox retains `10.5.0.8`; TFTP uses
`.9`, NTP `.10`, and node-exporter `.11`. The NixOS replacement additionally
uses `.53` for its DHCP DNS primary. Keep router identity `10.254.254.1`, transit
addresses and trusted VRRP addressing unchanged. SSH/SFTP remain host management.

The service migration was applied and verified on 2026-11-14. The live bridge
and core BGP route use `/26`. Restart Matchbox after changing the Podman prefix:
the network definition alone does not update the running bridge or create the
exact connected route needed for BGP origination.

TFTP and metrics retain their old listeners during client migration. NTP binds
only `.10`; LAN/WireGuard interception and a scoped transit DNAT rule preserve
clients using the old device address. Chrony supports one IPv4 bind address. The
installed node-exporter supports repeatable `--web.listen-address` arguments.
The three Kubernetes nodes and Beefchunk now synchronize against `.10`, and
VictoriaMetrics scrapes the new metrics hostname at `.11`. NetBox records these
services and `/26` as active; the old `/24` is a reserved allocation hold.

TFTP was verified from the servers network with a real client and a matching
SHA256 of `undionly.kpxe`. VyOS's tftpd-hpa can source transfer packets from the
servers interface address `10.1.1.1`, even when the request targets `.9`.
Keep the compatibility listener and verify firmware PXE boot before retiring it.
NixOS uses its separately tested native TFTP service.

Review the complete candidate diff before applying: `apply-config.sh` loads a
default configuration and rebuilds all sections, so unrelated repository drift
must be reconciled with the running gateway. Verify the core's `/26` route,
Matchbox asset fetches, TFTP boot, NTP replies and old/new metrics listeners before
updating clients. Update NetBox's active prefix/interface records only after live
verification. Never run VyOS and its NixOS replacement as simultaneous owners.
