# Changelog

Log of changes made to the workshop lab devices, tooling and documentation, newest first.
File changes are also in `git log`. This file exists for changes that git cannot show, such as
configuration applied to the live routers and hosts.

**Entry format:** date, devices, what changed, how it was verified, matching backup.
Take a backup before and after each device change with `backups/backup-configs.sh`.

---

## 2026-11-16

### Backup and restore tooling
- **Added** `backups/backup-configs.sh`: saves `show running-config` from R1-R6 and the network
  files (`/etc/hostname`, `/etc/hosts`, `/etc/network/interfaces`) from alpine-1 to alpine-6
  into `backups/<timestamp>/`, with a `latest` link.
- **Added** `backups/restore-configs.sh`: restores routers with a validate-then-`load`/`commit`
  (merge, or `-r` to replace) and rewrites the host files. Supports `-n` dry run.
- **Verified:** backup run saved 12 of 12 devices. Restore tested in merge mode on R1 and alpine-1
  from their own backup; a fresh backup afterwards matched the original apart from R1's
  "last configuration change" timestamp. `-r` (replace) and restoring a wiped node are untested.
- **Side effect:** a temporary file `harddisk:/restore-test.cfg` was copied to R1 for a
  load-without-commit test (session aborted) and deleted again.
- **Backup:** `20261116-202808` was the first backup, taken after the LLDP change below, so it contains it.

### LLDP and R-R links up (R1-R6)
- **Changed:** `lldp` enabled globally and `no shutdown` on all R-R interfaces on R1-R6.
  Host ports Gi0/0/0/5 left shut down. No IP addresses configured.
  - R1: Gi0/0/0/0, Gi0/0/0/1. R2: Gi0/0/0/0-2. R3: Gi0/0/0/0-1.
  - R4: Gi0/0/0/0-1. R5: Gi0/0/0/0-2. R6: Gi0/0/0/0-1.
- **Verified:** all 7 core links are up and show the correct LLDP neighbor and port at both
  ends (R1-R2, R2-R3, R3-R4, R4-R5, R5-R6, R2-R5, R1-R6).
- **Note:** the R1-R6 link first showed down/down because it was not connected in CML.
  After it was connected it came up with no further change.
- **Backup:** `20261116-202808`.

### Lab state set up outside this log (by the instructor)
- SSH enabled on R1-R6; mgmt interface in VRF `management`; `cisco/cisco` login works.
- Alpine hosts alpine-1 to alpine-6 configured with mgmt IPs 198.18.1.21-26/24,
  gateway 198.18.1.1, matching hostnames, and login `cisco/cisco`.
- Some nodes restarted and lost configuration; R2 and R5 were restored. After the restore,
  all 6 routers and all 6 hosts were reachable.

### Topology revision
- **Changed:** alpine hosts renamed to alpine-1..6 (one per router, on Gi0/0/0/5), and a new
  core link R1 Gi0/0/0/1 to R6 Gi0/0/0/1 added. All six routers are PEs.
- **Docs:** tracker and `DEVICES.md` updated; `topology.png` replaced with the new diagram.

### Documentation
- `ee40997` Update devices for revised topology.
- `b58bd25` Add device information reference (`DEVICES.md`).
- `01da82d` Add lab access guide, Part 1: VPN connection (`LAB-ACCESS.md`).
- `XR_PW_Workshop_Tracker.xlsx` created: devices, IP plan, links, hosts, OSPF/SR, pseudowires, login checks.
- **IP plan agreed:** links `10.<A>.<B>.<n>/31` (lower router gets the even address),
  loopbacks `R.R.R.R/32`, SR prefix-SID label 16000+R, mgmt `198.18.1.1X`.

### Not done yet
- No IP addresses on any R-R link or Loopback0. No OSPF, SR-MPLS or LDP configuration.
- Host ports Gi0/0/0/5 shut down; no `l2transport` or pseudowire configuration.
- Alpine eth1 data addressing not decided.
