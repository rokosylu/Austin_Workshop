# Device Information

Single reference for every device, address, and link in the workshop lab. Source of truth: `XR_PW_Workshop_Tracker.xlsx`.

> Lab-only credentials and addressing. Loopbacks use `R.R.R.R/32` (public-looking space) and must never be routed toward the management or VPN network.

## Addressing Scheme

| Item | Scheme | Example |
|---|---|---|
| Point-to-point links | 10.&lt;A&gt;.&lt;B&gt;.&lt;n&gt;/31 : A = lower router #, B = higher router # | R2-R5 -> 10.2.5.0/31 |
| Address assignment | Lower-numbered router = even address, higher = odd | R2 = 10.2.5.0, R5 = 10.2.5.1 |
| Parallel links (same pair) | &lt;n&gt; steps by 2: 0, 2, 4 ... | 2nd R2-R5 link -> 10.2.5.2/31 |
| Loopback0 / Router-ID | R.R.R.R/32 (R = router #, lab-only addressing) | R3 = 3.3.3.3/32 |
| SR-MPLS SRGB | Default 16000-23999 |  |
| Prefix-SID | Index = X, label = 16000 + X | R3 = index 3 / label 16003 |
| Management | 198.18.1.1X/24 (X = router #) | R3 = 198.18.1.13 |
| IPv6 (optional) | 2001:db8:&lt;A&gt;:&lt;B&gt;::&lt;n&gt;/127 (same A/B/n rules) | R2-R5 -> 2001:db8:2:5::/127 |
| OSPF | Process 1 (suggested), area 0, point-to-point on core links |  |

## Routers

| Router | Mgmt IP | Mgmt VRF | Role | Loopback0 | Prefix-SID label | OSPF Area | XR Version | Login |
|---|---|---|---|---|---|---|---|---|
| R1 | 198.18.1.11 | management | PE (CE: alpine-1) | 1.1.1.1/32 | 16001 | 0 | 25.1.1 | cisco/cisco |
| R2 | 198.18.1.12 | management | PE (CE: alpine-2) | 2.2.2.2/32 | 16002 | 0 | 25.1.1 | cisco/cisco |
| R3 | 198.18.1.13 | management | PE (CE: alpine-3) | 3.3.3.3/32 | 16003 | 0 | 25.1.1 | cisco/cisco |
| R4 | 198.18.1.14 | management | PE (CE: alpine-4) | 4.4.4.4/32 | 16004 | 0 | 25.1.1 | cisco/cisco |
| R5 | 198.18.1.15 | management | PE (CE: alpine-5) | 5.5.5.5/32 | 16005 | 0 | 25.1.1 | cisco/cisco |
| R6 | 198.18.1.16 | management | PE (CE: alpine-6) | 6.6.6.6/32 | 16006 | 0 | 25.1.1 | cisco/cisco |

Router interfaces map from the diagram labels `G0/N` to `GigabitEthernet0/0/0/N`.

## Alpine Hosts (CE)

| Host | eth0 (mgmt) | Gateway | Attached to | Router interface | Data addressing (eth1) | Role | Login |
|---|---|---|---|---|---|---|---|
| alpine-1 | 198.18.1.21/24 | 198.18.1.1 | R1 | GigabitEthernet0/0/0/5 | eth1: 172.16.1.1/24 (untagged) | End host (port-based PW) | cisco/cisco |
| alpine-2 | 198.18.1.22/24 | 198.18.1.1 | R2 | GigabitEthernet0/0/0/5 | eth1.10: 192.168.10.2/24 | End host (VLAN 10) | cisco/cisco |
| alpine-3 | 198.18.1.23/24 | 198.18.1.1 | R3 | GigabitEthernet0/0/0/5 | eth1.10: 192.168.10.3/24; eth1.11: 192.168.11.3/24; ip_forward=1 | Router between VLAN 10 and 11 | cisco/cisco |
| alpine-4 | 198.18.1.24/24 | 198.18.1.1 | R4 | GigabitEthernet0/0/0/5 | eth1: 172.16.1.4/24 (untagged) | End host (port-based PW) | cisco/cisco |
| alpine-5 | 198.18.1.25/24 | 198.18.1.1 | R5 | GigabitEthernet0/0/0/5 | eth1.11: 192.168.11.5/24; eth1.12: 192.168.12.5/24; ip_forward=1 | Router between VLAN 11 and 12 | cisco/cisco |
| alpine-6 | 198.18.1.26/24 | 198.18.1.1 | R6 | GigabitEthernet0/0/0/5 | eth1.12: 192.168.12.6/24 | End host (VLAN 12) | cisco/cisco |

### Host startup configuration (CML node config)

Each alpine node's CML configuration is a shell script run at every boot. It sets the hostname (CML's default
`hostname inserthostname-here` line would otherwise override it), the eth0 management IP and default route, the eth1
data addressing (port-based, or VLAN sub-interfaces) and the static routes. The files are in `configs/alpine/`
(`alpine-1.cfg` to `alpine-6.cfg`). Verified on the nodes (hostname, IPs, VLAN interfaces, routes, forwarding) on 2026-11-19; end-to-end pings need the Task 3 PWs.

| Host | Static routes | Config file |
|---|---|---|
| alpine-1 | none | `configs/alpine/alpine-1.cfg` |
| alpine-2 | 192.168.11.0/24 and 192.168.12.0/24 via 192.168.10.3 | `configs/alpine/alpine-2.cfg` |
| alpine-3 | 192.168.12.0/24 via 192.168.11.5 | `configs/alpine/alpine-3.cfg` |
| alpine-4 | none | `configs/alpine/alpine-4.cfg` |
| alpine-5 | 192.168.10.0/24 via 192.168.11.3 | `configs/alpine/alpine-5.cfg` |
| alpine-6 | 192.168.10.0/24 and 192.168.11.0/24 via 192.168.12.5 | `configs/alpine/alpine-6.cfg` |

Addressing: port-based PW `172.16.1.X/24`; VLAN 10 `192.168.10.X/24`; VLAN 11 `192.168.11.X/24`; VLAN 12 `192.168.12.X/24`
(X = alpine number). alpine-3 and alpine-5 forward IP traffic so alpine-2 and alpine-5/alpine-6 can reach each other
(alpine-2 - VLAN 10 - alpine-3 - VLAN 11 - alpine-5 - VLAN 12 - alpine-6).

## Core Links

| Link | A-side | A-side IP | Z-side | Z-side IP | Subnet |
|---|---|---|---|---|---|
| L1 | R1 GigabitEthernet0/0/0/0 | 10.1.2.0/31 | R2 GigabitEthernet0/0/0/0 | 10.1.2.1/31 | 10.1.2.0/31 |
| L2 | R2 GigabitEthernet0/0/0/1 | 10.2.3.0/31 | R3 GigabitEthernet0/0/0/0 | 10.2.3.1/31 | 10.2.3.0/31 |
| L3 | R3 GigabitEthernet0/0/0/1 | 10.3.4.0/31 | R4 GigabitEthernet0/0/0/0 | 10.3.4.1/31 | 10.3.4.0/31 |
| L4 | R4 GigabitEthernet0/0/0/1 | 10.4.5.0/31 | R5 GigabitEthernet0/0/0/0 | 10.4.5.1/31 | 10.4.5.0/31 |
| L5 | R5 GigabitEthernet0/0/0/1 | 10.5.6.0/31 | R6 GigabitEthernet0/0/0/0 | 10.5.6.1/31 | 10.5.6.0/31 |
| L6 | R2 GigabitEthernet0/0/0/2 | 10.2.5.0/31 | R5 GigabitEthernet0/0/0/2 | 10.2.5.1/31 | 10.2.5.0/31 |
| L7 | R1 GigabitEthernet0/0/0/1 | 10.1.6.0/31 | R6 GigabitEthernet0/0/0/1 | 10.1.6.1/31 | 10.1.6.0/31 |

## Attachment Circuits (CE-facing)

| Link | Router | Interface | Host | Host Interface | Type | IP |
|---|---|---|---|---|---|---|
| L8 | R1 | GigabitEthernet0/0/0/5 | alpine-1 | eth1 | L2 AC (`l2transport`) | none on router |
| L9 | R2 | GigabitEthernet0/0/0/5 | alpine-2 | eth1 | L2 AC (`l2transport`) | none on router |
| L10 | R3 | GigabitEthernet0/0/0/5 | alpine-3 | eth1 | L2 AC (`l2transport`) | none on router |
| L11 | R4 | GigabitEthernet0/0/0/5 | alpine-4 | eth1 | L2 AC (`l2transport`) | none on router |
| L12 | R5 | GigabitEthernet0/0/0/5 | alpine-5 | eth1 | L2 AC (`l2transport`) | none on router |
| L13 | R6 | GigabitEthernet0/0/0/5 | alpine-6 | eth1 | L2 AC (`l2transport`) | none on router |

## OSPF / SR-MPLS

| Router | Router-ID | Area | Prefix-SID index | Label |
|---|---|---|---|---|
| R1 | 1.1.1.1 | Process 1 / Area 0 | 1 | 16001 |
| R2 | 2.2.2.2 | Process 1 / Area 0 | 2 | 16002 |
| R3 | 3.3.3.3 | Process 1 / Area 0 | 3 | 16003 |
| R4 | 4.4.4.4 | Process 1 / Area 0 | 4 | 16004 |
| R5 | 5.5.5.5 | Process 1 / Area 0 | 5 | 16005 |
| R6 | 6.6.6.6 | Process 1 / Area 0 | 6 | 16006 |

SRGB: default 16000-23999. All six routers are PEs, each with one attached alpine host. R2 and R5 also carry transit traffic.

## Training Tasks

| Task | Guide | Focus | Devices | Lab state at start |
|---|---|---|---|---|
| 1 | [TASK1.md](TASK1.md) | IOS XR basics: two-stage commit, abort/clear, rollback, enable R1 core ports, OSPF on XE vs XR | R1 | R1 core ports shut, R2-R6 pre-built |
| 2 | [TASK2.md](TASK2.md) | Underlay on R1: link IPs, OSPF, SR-MPLS, MPLS OAM, TI-LFA | R1 (R2-R6 pre-built) | Task 1 done: R1 core ports up, no IPs |
| 3 | TASK3.md (to come) | Pseudowires (LDP-signaled) | All devices | Task 2 complete |

## Configuration Status

| Router | Underlay (link IPs, Loopback0, OSPF 1 area 0, SR-MPLS, MPLS OAM, TI-LFA) | LDP (for PW signaling) | Notes |
|---|---|---|---|
| R1 | Built by the student in Task 2 (reference solution in `solutions/task2/R1.cfg`) | Student adds in Task 3 | LLDP on; core ports start shut (enabled in Task 1); Gi0/0/0/5 shut |
| R2 | Pre-built and verified (`configs/task2-prebuilt/R2.txt`) | Pre-built: `router-id` = Loopback0, `discovery targeted-hello accept` (no LDP on interfaces) | LLDP on, core ports up, Gi0/0/0/5 shut |
| R3 | Pre-built and verified (`configs/task2-prebuilt/R3.txt`) | Pre-built: `router-id` = Loopback0, `discovery targeted-hello accept` (no LDP on interfaces) | LLDP on, core ports up, Gi0/0/0/5 shut |
| R4 | Pre-built and verified (`configs/task2-prebuilt/R4.txt`) | Pre-built: `router-id` = Loopback0, `discovery targeted-hello accept` (no LDP on interfaces) | LLDP on, core ports up, Gi0/0/0/5 shut |
| R5 | Pre-built and verified (`configs/task2-prebuilt/R5.txt`) | Pre-built: `router-id` = Loopback0, `discovery targeted-hello accept` (no LDP on interfaces) | LLDP on, core ports up, Gi0/0/0/5 shut |
| R6 | Pre-built and verified (`configs/task2-prebuilt/R6.txt`) | Pre-built: `router-id` = Loopback0, `discovery targeted-hello accept` (no LDP on interfaces) | LLDP on, core ports up, Gi0/0/0/5 shut |

All core interfaces have a `description` naming the peer router and port. R1 LDP, the pseudowire (`l2vpn`) and host-port configuration are not done yet (Task 3).

## Pseudowires (planned, not configured)

LDP-signaled VPWS (no BGP in core) over the SR-MPLS underlay. Pw-ids and names are decided in Task 3.

| PW | Type | PE-A | PE-A attachment circuit | PE-Z | PE-Z attachment circuit | Hosts |
|---|---|---|---|---|---|---|
| PW1 | port-based | R1 | Gi0/0/0/5 port-based (untagged) | R4 | Gi0/0/0/5 port-based (untagged) | alpine-1 172.16.1.1 <-> alpine-4 172.16.1.4 |
| PW2 | VLAN-tagged | R2 | Gi0/0/0/5 VLAN 10 | R3 | Gi0/0/0/5 VLAN 10 | alpine-2 192.168.10.2 <-> alpine-3 192.168.10.3 |
| PW3 | VLAN-tagged | R3 | Gi0/0/0/5 VLAN 11 | R5 | Gi0/0/0/5 VLAN 11 | alpine-3 192.168.11.3 <-> alpine-5 192.168.11.5 |
| PW4 | VLAN-tagged | R6 | Gi0/0/0/5 VLAN 12 | R5 | Gi0/0/0/5 VLAN 12 | alpine-6 192.168.12.6 <-> alpine-5 192.168.12.5 |
