# Changelog

Log of changes made to the workshop lab devices, tooling and documentation, newest first.
File changes are also in `git log`. This file exists for changes that git cannot show, such as
configuration applied to the live routers and hosts.

**Entry format:** date, devices, what changed, how it was verified, matching backup.
Take a backup before and after each device change with `backups/backup-configs.sh`.

---

## 2026-11-17

### New Task 1 (IOS XR basics); old Task 1 is now Task 2
- **Renamed:** `TASK1.md` -> `TASK2.md` (underlay), `solutions/task1/` -> `solutions/task2/`,
  `configs/task1-prebuilt/` -> `configs/task2-prebuilt/`. The pseudowire task is now Task 3. Earlier changelog entries
  below use the old names (Task 1 = underlay, Task 2 = pseudowires).
- **Added** `TASK1.md` (XR basics, R1 only): two-stage commit (change the hostname, see it is unchanged in the running
  config until `commit`), previewing with `show configuration`, discarding with `end`+`no`, `abort` and `clear`,
  rolling back with `show configuration commit list`, `rollback configuration last 1` and `rollback configuration to`,
  `commit label` and `commit confirmed`, and an OSPF comparison of IOS XE vs IOS XR for R1.
  `TASK2.md` now has a prerequisite pointing at Task 1.
- **Changed then reverted (R1):** all demo steps were run on R1 to capture real output (hostname changed to
  R1-LAB/R1-TMP/R1-A/R1-B/R1-CONF, scratch `Loopback99` staged but never committed). R1 was set back to `hostname R1`.
  A backup diff showed R1 identical to the `task2-start` baseline apart from the timestamp. The commit history on R1 now
  contains these extra commits (including rollbacks), so commit IDs in `TASK1.md` will differ from students' IDs.
- **Verified behavior worth knowing:** `rollback configuration to <label>` undoes that commit and everything after it
  (it returns to the state *before* the labelled commit); `commit confirmed 30` followed by leaving config mode
  rolls back immediately (XR warns first).
- **Not verified:** the IOS XE configuration in `TASK1.md` is written from knowledge of XE syntax. It was not
  tested on an XE device.
- **Docs:** `DEVICES.md` has a Training Tasks table and new paths; tracker column updated. Local baselines
  renamed to `backups/baselines/task2-start` and `task2-start-before-ti-lfa`.
- **Backups:** `20261117-103113` (all 12 devices, matches the baseline).

### Topology image updated
- `topology.png` replaced with a redrawn diagram (OSPF area labelled "OSPF 1"). Same links, interfaces and hosts; no device or doc changes needed.

### SR TI-LFA added to the baseline (R2-R6) and to Task 1
- **Changed (R2-R6):** `fast-reroute per-prefix` and `fast-reroute per-prefix ti-lfa enable` on every core
  interface under `router ospf 1 / area 0` (R2 and R5: 3 interfaces, R3, R4 and R6: 2). Committed on each. Saved in
  `configs/task1-prebuilt/R2.txt` to `R6.txt`.
- **Changed then reverted (R1):** rebuilt the Task 1 config on R1 (underlay, `mpls oam`, TI-LFA), then removed it again.
  R1 keeps LLDP and `no shutdown` on its core ports.
- **Verified:** on R1 the routes to 2.2.2.2 and 3.3.3.3 changed from a single path to `Protected` with a
  `Backup (TI-LFA)` path via Gi0/0/0/1, repair node 5.5.5.5, labels `16005 16002` / `16005 16003`. Destinations with two
  equal-cost paths (4.4.4.4, 5.5.5.5) protect each other. `show ospf routes backup-path` and
  `show mpls forwarding prefix 3.3.3.3/32 detail` show the backup. **Failure test:** shut R1 Gi0/0/0/0; the route to
  3.3.3.3 moved to the R6 path (metric 5), ping 100%, traceroute via R6 and R5. The interface was restored with
  `no shutdown` (R1 back to two FULL neighbors) before the rollback. Failover speed was not measured.
- **Docs:** `TASK1.md` has a new Step 5 (TI-LFA, with an optional break-a-link test), a checklist item (#10),
  troubleshooting rows and TI-LFA in the answer. `solutions/task1/R1.cfg` and `DEVICES.md` updated.
- **Backups:** `20261117-084731` is now the **lab start state** (`backups/latest`). A backup diff showed R1
  identical to the previous start and R2-R6 differing only by the TI-LFA lines.
- **Baselines (local):** `backups/baselines/task1-start` now holds that state. The previous baseline (without TI-LFA)
  is kept as `backups/baselines/task1-start-before-ti-lfa`.

## 2026-11-16

### Named baseline saved
- **Added** `backups/baselines/task1-start/` (local only, git-ignored): full configs of R1-R6 and alpine-1..6
  at the Task 1 lab start state. Copied from backup `20261116-215346`, taken after confirming R2-R6 have
  link IPs, Loopback0, OSPF 1, SR-MPLS and `mpls oam`, and that R1 has none of them.
- **Restore from it:** `./backups/restore-configs.sh -d baselines/task1-start` (add `-n` for a dry run first).
- The repo copy of the R2-R6 baseline is the command lists in `configs/task1-prebuilt/` (no password hashes).
- **Backups:** `20261116-215346` was `backups/latest` then and matched the previous lab start (`20261116-215206`).

### MPLS OAM added to the baseline (R2-R6) and to Task 1
- **Changed (R2-R6):** `mpls oam` added globally and committed. Saved in `configs/task1-prebuilt/R2.txt` to `R6.txt`.
- **Changed then reverted (R1):** rebuilt the full Task 1 config on R1, confirmed the `ping sr-mpls` error
  ("MPLS Embedded Management Subsystem is not running") without `mpls oam`, added `mpls oam`, tested, then
  removed everything again (including `no mpls oam`). R1 keeps LLDP and `no shutdown` on its core ports.
- **Verified:** `ping sr-mpls` to 2.2.2.2, 3.3.3.3, 4.4.4.4, 5.5.5.5 and 6.6.6.6/32 all 100% from R1;
  `traceroute sr-mpls 4.4.4.4/32` showed the label path R1 -> R6 -> R5 -> R4 ending with `!`;
  a backup diff showed R1 unchanged from the previous lab start and R2-R6 differing only by `mpls oam`.
- **Docs:** `TASK1.md` has a new Step 4 (MPLS OAM), two new checklist items, two troubleshooting rows, and
  `mpls oam` in the answer. `solutions/task1/R1.cfg` includes it. `DEVICES.md` status table updated.
- **Backups:** `20261116-215206` is now the **lab start state** (`backups/latest`). It supersedes
  `20261116-213326`, which does not include `mpls oam` on R2-R6.

### Task 1 underlay: R2-R6 pre-built, R1 reference captured and rolled back
- **Changed (R2-R6):** Loopback0 (`R.R.R.R/32`), link IPs (`10.<A>.<B>.<n>/31`), interface descriptions,
  OSPF process 1 / area 0 (`network point-to-point`, loopback passive) and SR-MPLS (`segment-routing mpls`,
  `prefix-sid index <R>`). Commands are saved in `configs/task1-prebuilt/R2.txt` to `R6.txt`.
- **Changed then reverted (R1):** the same configuration was applied to R1 in three stages (interfaces, OSPF, SR)
  to capture the real commands and outputs for `TASK1.md`, then removed by hand (`no router ospf 1`,
  `no interface Loopback0`, `no description` / `no ipv4 address` on Gi0/0/0/0-1). R1 keeps LLDP and
  `no shutdown` on its core ports, as agreed. A new backup diffed against the pre-change one was identical
  except for the "last configuration change" timestamp.
- **Verified:** R2-R6 formed all expected OSPF adjacencies (everything except the two toward R1) and learned all loopbacks.
  With R1 configured: 2 FULL neighbors, routes to 2.2.2.2-6.6.6.6 (ECMP to 4.4.4.4 and 5.5.5.5),
  SR labels 16002-16006 in `show mpls forwarding`, 100% ping to every loopback from `source 1.1.1.1`,
  traceroute to 4.4.4.4 showing `[MPLS: Label 16004]`, and R4 holding label 16001 for R1.
- **Docs:** added `TASK1.md` (student guide, with captured outputs), `solutions/task1/R1.cfg` (answer),
  updated `DEVICES.md` and the tracker (underlay status column, OSPF process 1).
- **Command that does not work on XR 25.1.1:** `show segment-routing mpls ...`. (`ping/traceroute sr-mpls`
  need `mpls oam`; added in the entry above.)
- **Backups (all in `backups/`, not in git):**
  - `20261116-212733`: before this change (original baseline, R1-R6 with LLDP and no-shut only).
  - `20261116-213210`: R1 solved (reference state, R1 has the Task 1 config). Do **not** use as the lab start.
  - `20261116-213326`: lab start state before `mpls oam` was added (superseded by `20261116-215206`).
- **Known risk:** `restore-configs.sh -r` (replace) has not been tested. A baseline where a port is only
  `no shutdown` shows no config lines for that port, so a full replace might leave it shut down. Use merge mode,
  or re-check `show ip interface brief` after any replace.

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
- No LDP or pseudowire configuration (Task 2). Alpine eth1 addressing and the PW pairs are not decided.
- Host ports Gi0/0/0/5 stay shut down; students enable them in Task 2.
