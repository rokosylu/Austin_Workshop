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

| Host | eth0 (mgmt) | Gateway | Attached to | Router interface | Host eth1 | Login |
|---|---|---|---|---|---|---|
| alpine-1 | 198.18.1.21/24 | 198.18.1.1 | R1 | GigabitEthernet0/0/0/5 | TBD | cisco/cisco |
| alpine-2 | 198.18.1.22/24 | 198.18.1.1 | R2 | GigabitEthernet0/0/0/5 | TBD | cisco/cisco |
| alpine-3 | 198.18.1.23/24 | 198.18.1.1 | R3 | GigabitEthernet0/0/0/5 | TBD | cisco/cisco |
| alpine-4 | 198.18.1.24/24 | 198.18.1.1 | R4 | GigabitEthernet0/0/0/5 | TBD | cisco/cisco |
| alpine-5 | 198.18.1.25/24 | 198.18.1.1 | R5 | GigabitEthernet0/0/0/5 | TBD | cisco/cisco |
| alpine-6 | 198.18.1.26/24 | 198.18.1.1 | R6 | GigabitEthernet0/0/0/5 | TBD | cisco/cisco |

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

## Configuration Status

| Router | Underlay (link IPs, Loopback0, OSPF 1 area 0, SR-MPLS, MPLS OAM, TI-LFA) | Notes |
|---|---|---|
| R1 | Built by the student in Task 1 (reference solution in `solutions/task1/R1.cfg`) | LLDP on, core ports no-shut, Gi0/0/0/5 shut |
| R2 | Pre-built and verified (`configs/task1-prebuilt/R2.txt`) | LLDP on, core ports no-shut, Gi0/0/0/5 shut |
| R3 | Pre-built and verified (`configs/task1-prebuilt/R3.txt`) | LLDP on, core ports no-shut, Gi0/0/0/5 shut |
| R4 | Pre-built and verified (`configs/task1-prebuilt/R4.txt`) | LLDP on, core ports no-shut, Gi0/0/0/5 shut |
| R5 | Pre-built and verified (`configs/task1-prebuilt/R5.txt`) | LLDP on, core ports no-shut, Gi0/0/0/5 shut |
| R6 | Pre-built and verified (`configs/task1-prebuilt/R6.txt`) | LLDP on, core ports no-shut, Gi0/0/0/5 shut |

All core interfaces have a `description` naming the peer router and port. The pseudowire (LDP) and host-port configuration is not done yet (Task 2).

## Pseudowires

To be defined. Planned: LDP-signaled VPWS (no BGP in core), for example alpine-1 to alpine-6 between R1 and R6 using pw-id 100.
