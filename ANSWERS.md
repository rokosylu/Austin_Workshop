# Finished Configurations

The finished configuration for each task, for when you get stuck or want to check your work. **Try the task yourself first.**

How to use these:
- Enter the lines in configuration mode (`configure terminal`) on the router named in the heading.
- Run `show configuration` and check it before you `commit`, as in the guides.
- `show running-config` does not list `no shutdown`, because an enabled interface simply has no `shutdown` line.
- Task 1 has no configuration answer, only the questions at the end of the guide.

| Task | Routers | Jump to |
|---|---|---|
| [Task 2](TASK2.md) | R1 | [Underlay on R1](#task-2-underlay-on-r1) |
| [Task 3](TASK3.md) | R1, R4 | [Port-based pseudowire](#task-3-port-based-pseudowire-r1-and-r4) |
| [Task 4](TASK4.md) | R2, R3, R5, R6 | [VLAN-based pseudowires](#task-4-vlan-based-pseudowires-r2-r3-r5-r6) |

---

## Task 2: Underlay on R1

Guide: [Task 2](TASK2.md)

```
interface Loopback0
 description Router-ID and SR prefix-SID
 ipv4 address 1.1.1.1 255.255.255.255
!
interface GigabitEthernet0/0/0/0
 description to R2 Gi0/0/0/0
 ipv4 address 10.1.2.0 255.255.255.254
!
interface GigabitEthernet0/0/0/1
 description to R6 Gi0/0/0/1
 ipv4 address 10.1.6.0 255.255.255.254
!
router ospf 1
 router-id 1.1.1.1
 segment-routing mpls
 area 0
  interface Loopback0
   passive enable
   prefix-sid index 1
  !
  interface GigabitEthernet0/0/0/0
   network point-to-point
   fast-reroute per-prefix
   fast-reroute per-prefix ti-lfa enable
  !
  interface GigabitEthernet0/0/0/1
   network point-to-point
   fast-reroute per-prefix
   fast-reroute per-prefix ti-lfa enable
  !
 !
!
mpls oam
!
```

---

## Task 3: Port-based pseudowire (R1 and R4)

Guide: [Task 3](TASK3.md)

**R1**

```
mpls ldp
 router-id 1.1.1.1
 address-family ipv4
  discovery targeted-hello accept
 !
!
interface GigabitEthernet0/0/0/5
 description to alpine-1 eth1
 l2transport
 !
!
l2vpn
 xconnect group PORT_BASED
  p2p R1_to_R4
   interface GigabitEthernet0/0/0/5
   neighbor ipv4 4.4.4.4 pw-id 100
   !
  !
 !
!
```

**R4** (the `mpls ldp` block was already there)

```
interface GigabitEthernet0/0/0/5
 description to alpine-4 eth1
 l2transport
 !
!
l2vpn
 xconnect group PORT_BASED
  p2p R4_to_R1
   interface GigabitEthernet0/0/0/5
   neighbor ipv4 1.1.1.1 pw-id 100
   !
  !
 !
!
```

---

## Task 4: VLAN-based pseudowires (R2, R3, R5, R6)

Guide: [Task 4](TASK4.md)

**R2**

```
interface GigabitEthernet0/0/0/5
 description to alpine-2 eth1
!
interface GigabitEthernet0/0/0/5.10 l2transport
 description VLAN 10
 encapsulation dot1q 10
!
l2vpn
 xconnect group VLAN_BASED
  p2p VLAN10
   interface GigabitEthernet0/0/0/5.10
   neighbor ipv4 3.3.3.3 pw-id 10
   !
  !
 !
!
```

**R3**

```
interface GigabitEthernet0/0/0/5
 description to alpine-3 eth1
!
interface GigabitEthernet0/0/0/5.10 l2transport
 description VLAN 10
 encapsulation dot1q 10
!
interface GigabitEthernet0/0/0/5.11 l2transport
 description VLAN 11
 encapsulation dot1q 11
!
l2vpn
 xconnect group VLAN_BASED
  p2p VLAN10
   interface GigabitEthernet0/0/0/5.10
   neighbor ipv4 2.2.2.2 pw-id 10
   !
  !
  p2p VLAN11
   interface GigabitEthernet0/0/0/5.11
   neighbor ipv4 5.5.5.5 pw-id 11
   !
  !
 !
!
```

**R5**

```
interface GigabitEthernet0/0/0/5
 description to alpine-5 eth1
!
interface GigabitEthernet0/0/0/5.11 l2transport
 description VLAN 11
 encapsulation dot1q 11
!
interface GigabitEthernet0/0/0/5.12 l2transport
 description VLAN 12
 encapsulation dot1q 12
!
l2vpn
 xconnect group VLAN_BASED
  p2p VLAN11
   interface GigabitEthernet0/0/0/5.11
   neighbor ipv4 3.3.3.3 pw-id 11
   !
  !
  p2p VLAN12
   interface GigabitEthernet0/0/0/5.12
   neighbor ipv4 6.6.6.6 pw-id 12
   !
  !
 !
!
```

**R6**

```
interface GigabitEthernet0/0/0/5
 description to alpine-6 eth1
!
interface GigabitEthernet0/0/0/5.12 l2transport
 description VLAN 12
 encapsulation dot1q 12
!
l2vpn
 xconnect group VLAN_BASED
  p2p VLAN12
   interface GigabitEthernet0/0/0/5.12
   neighbor ipv4 5.5.5.5 pw-id 12
   !
  !
 !
!
```

`show running-config` does not list `no shutdown` on the parent port, because an enabled interface simply has no `shutdown` line.
