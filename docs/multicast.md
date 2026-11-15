# Multicast queriers

VyOS owns the IPv4 IGMP and IPv6 MLD querier roles on trusted VLAN 20 and
IoT VLAN 40. The ICX core passively snoops both protocols. IPv6 MLD also
runs on the dedicated OTBR and Matter controller VLANs 1100 and 1101.

## Supervised IPv4 querier on VyOS 1.4

The stock FRR daemon template hard-codes `pimd=no`. The PIM configuration
handler can start it directly, but FRR does not supervise or restore that
process after an FRR reload or restart. IGMP configuration alone therefore
does not ensure that the IPv4 querier remains running.

`scripts/patches/frr-enable-pimd.patch` enables `pimd` in the generated
FRR daemon file. VyOS initially renders that file and starts FRR before
the preconfiguration hook. The hook patches the template and then calls
the native `system_frr.py` handler to reconcile the daemon file. During
boot, the handler restarts FRR if that file changed, before VyOS loads its
routing configuration. This also handles an already patched template with
a stale daemon file. On a running router, the handler reports changes
without restarting FRR automatically.

Interface settings remain owned by `config-parts/protocols.sh`. Both IPv4
interfaces use passive PIM: IGMP queries and membership processing remain
enabled, while PIM control traffic and neighbor discovery are disabled.
There are no PIM neighbors or rendezvous points in this topology. Avahi
provides the configured mDNS reflection between VLANs. There is no separate
IGMP configuration or daemon supervisor. Do not enable IGMP proxy alongside PIM.

For an existing router, install the changed hook and patch under
`/config/scripts`, then:

1. Run `sudo /config/scripts/vyos-preconfig-bootup.script`.
2. Review `sudo /usr/lib/frr/frr-reload.py --test /etc/frr/frr.conf`.
   Resolve unrelated FRR configuration differences before continuing.
3. Run `sudo systemctl reload frr`. FRR reload adds supervision for the
   enabled daemon without restarting the existing routing daemons.
4. Run `sudo /usr/libexec/vyos/conf_mode/protocols_pim.py` to reapply the
   existing VyOS IGMP configuration to the newly running daemon.
5. Apply the repository's passive interface settings through the normal
   configuration workflow, then commit and save.

Verify `pimd=yes`, a supervised `pimd` process, IGMP interfaces/groups,
and packet captures showing queries from VyOS. Check that the core learns
VyOS as the IPv4 router port and that an existing querier yields. IPv6 MLD,
BGP and existing Matter devices should remain healthy.

The previous audit found the Lounge UniFi switch acting as IPv4 querier at
`198.18.0.12` while VyOS's `pimd` was absent. Confirm querier ownership
before removing that switch. Review this compatibility patch on a VyOS
upgrade; remove it when the installed version natively supervises `pimd`.

FRR's [daemon startup and reload documentation](https://docs.frrouting.org/en/stable-9.1/setup.html#starting-a-new-daemon)
describes the supported daemon enablement mechanism.

## Rollout verification

On 2026-11-15, the patch and boot hook were deployed and FRR was reloaded.
Packet captures showed queries from VyOS on both VLANs. The UniFi switch
reported itself as a non-querier, with querier addresses `10.1.2.1` on
VLAN 20 and `10.1.3.1` on VLAN 40; the core learned both on LAG 1.
FRR learned six IPv4 multicast groups. Existing BGP and IPv6 PIM daemon
PIDs were unchanged, the core BGP session had no additional drops, and all
six Matter devices remained available.

The boot hook passed repeated execution and reverse-patch checks. No
router reboot was performed during this rollout.

The subsequent boot-order correction and passive settings were also deployed
on 2026-11-15. Isolated tests used the installed `system_frr.py` handler with
temporary daemon files and intercepted service actions. They covered a fresh
image, an already patched template with a stale daemon file, an already correct
setup, live-router behavior, and repeated execution. The tests requested an
FRR restart only for changed daemon files during boot.

After applying and saving passive mode, captures still showed IGMPv2 queries
on both VLANs, all six IPv4 groups remained learned, and the ICX refreshed
VyOS's querier and router-port entries on LAG 1. Both interfaces reported
passive mode with their PIM hello timers stopped. The `bgpd`, `pimd`, `pim6d`
and `watchfrr` PIDs were unchanged; the core BGP session remained established
with no additional drops. A repeated live hook execution made no service
changes. IPv6 router ports remained present on all four MLD VLANs. These checks
did not include an actual router reboot.
