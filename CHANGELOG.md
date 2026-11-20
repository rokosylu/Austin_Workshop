# Changelog

Log of changes made to the workshop lab devices, tooling and documentation, newest first.
File changes are also in `git log`. This file exists for changes that git cannot show, such as
configuration applied to the live routers and hosts.

**Entry format:** date, devices, what changed, how it was verified, matching backup.
Take a backup before and after each device change with `backups/backup-configs.sh`.

---

## 2026-11-19

### Finished configurations moved to ANSWERS.md
- **Reason (instructor):** students could not find the answer when stuck (Task 4 Step 3 said "at the end of this guide", where it sat
  inside a collapsed box about 270 lines further down).
- **Changed:** new `ANSWERS.md` with one section per task (Task 2: R1; Task 3: R1, R4; Task 4: R2, R3, R5, R6), copied from the
  guides. The "Compare with the answer" sections of `TASK2.md`, `TASK3.md` and `TASK4.md` now just link to the matching section;
  `TASK2.md` (verification line) and `TASK4.md` Step 3 also link to it directly. The quiz answers (the "Answers" boxes under
  "Questions to think about" in `TASK3.md` and `TASK4.md`, and the Task 1 questions) stay in the guides. The instructor copies in
  `solutions/` are unchanged.
- **Not checked:** the links were not clicked on GitHub; the anchors (`#task-2-underlay-on-r1` and so on) follow GitHub's
  heading-link rules.

### Host pings: removed `-W 2`
- **Changed (instructor):** removed `-W 2` from the five alpine `ping` commands in `TASK3.md` and `TASK4.md` (the ones expected
  to fail); `-c` stays on all host pings. A failing ping now waits for the default timeout before showing the summary.
  (I had used `-W 2` in my scripted tests so they would not hang.)

### Task 3 "Your Network" picture updated
- **Changed (instructor):** replaced `images/network-task3.png` with a new export of the diagram (the alpine-2 selection handles
  are gone). `TASK3.md` already pointed at this file, so no text changed.

### Removed the "(an estimate, not yet timed with a student)" wording
- **Changed (instructor request):** `TASK3.md` and `TASK4.md` now say just "about 30 minutes" and "about 45 minutes".
  `TASK1.md` and `TASK2.md` already had no qualifier. The times themselves are still estimates; no task has been timed with a student.

### Tasks 2-4: show the `show configuration` output before the commit
- **Reason (instructor):** in TASK2 Steps 2-5 the staged commands, `show configuration`, `commit` and `end` were in one
  code block, so a student who pastes it commits straight away and never sees the output block (and after a commit
  `show configuration` no longer lists those lines).
- **Changed `TASK2.md`:** Steps 2-5 now end the first block at `show configuration`, say that the output below is what you
  will see before you commit, and have a separate "Only when it matches, apply it" `commit` / `end` block, as Step 1
  already did. Step 2 gained the expected output, which I captured from R1 by staging the commands and running `abort`
  (nothing was committed). The Recap section explains that `show configuration` only lists uncommitted changes; Step 1
  wording matches.
- **Changed `TASK3.md` and `TASK4.md`:** these already kept `commit` separate; added a sentence before the `show configuration`
  output ("you will see this output before you commit") and "only when the output matches" before the commit blocks.
  `TASK1.md` already did this (Parts 1 and 4) and is unchanged. A scan finds no `show configuration` immediately followed by
  `commit` in any task.
- **Observed while capturing:** R1 already had OSPF and SR configured (the instructor working through Task 2), so the lab
  was not at the start state at that time. Nothing was committed or changed by me on R1.

### TASK1.md Part 5: made clear the XR config is a preview
- **Changed:** Part 5 now says up front that it is read-only and that nothing should be typed on R1; the XE block is
  labeled "for comparison only", the XR block "a preview of what you will enter in Task 2", and the closing line says nothing
  in the part changes R1. Wording only; no commands changed.

### SecureCRT: host sessions use password-only login
- **Found:** SecureCRT could connect to R1-R6 but showed "Keyboard-interactive authentication with the SSH2 server failed" on
  alpine-1..6. Checked from the shell: all six hosts advertise `publickey,password,keyboard-interactive`, accept
  `password`, and reject `keyboard-interactive` every time. R1 accepts keyboard-interactive. SecureCRT tries
  keyboard-interactive before password.
- **Changed:** `securecrt/Create-Sessions.py` sets `SSH2 Authentications V2` to `password` for the sessions in the `Hosts` folder.
  Routers are unchanged. `LAB-ACCESS.md` Part 2 troubleshooting and `securecrt/README.md` mention it.
- **Verified:** the instructor reran the script and confirmed the hosts connect ("that's better"). The root cause on the
  hosts (why keyboard-interactive fails; probably sshd without PAM) was not investigated and the hosts were not changed.

### LAB-ACCESS.md moved from SJC to RTP
- **Changed:** the lab is hosted in the Cisco dCloud RTP data center. Replaced `images/access-vpn-url.png`,
  `access-vpn-credentials.png` and `access-vpn-connected.png` with the RTP screenshots (VPN address
  `dcloud-rtp-anyconnect.cisco.com`). `access-vpn-app.png` (the app icon) is unchanged. In `LAB-ACCESS.md` the VPN Address row
  now shows the RTP address, the pod-specific note in Step 2 names it, Step 3 mentions the **Anyconnect-to-dCloud** group
  shown in the new screenshot, and Step 4 refers to the RTP(US) banner. No other file mentions SJC.
- **Follow-up:** the first RTP credentials screenshot, and the original SJC one, showed pod usernames, so
  `access-vpn-credentials.png` is now an empty dialog (no username or password). The git history was rewritten (force-push) so
  that file only ever has this version, which **changed every commit hash** from the first commit onward. Commit hashes quoted
  in this changelog were updated to the new ones. Anything that recorded old hashes elsewhere is stale.

### LAB-ACCESS.md Part 2 drafted (SecureCRT)
- **Added** Part 2 to `LAB-ACCESS.md`: device table with addresses, running `securecrt/Create-Sessions.py`, connecting to R1,
  checking the prompt, connecting to a host, tips for working with several tabs, which devices each task uses, and a
  troubleshooting table. The credentials table at the top now has the access method, addresses and `cisco`/`cisco` login
  instead of "TBD".
- **Not verified:** the SecureCRT menu steps (Connect window, host key window, save password) are written from general
  knowledge of SecureCRT and only the script run was seen by the instructor. There are no screenshots for Part 2 yet.
  The advice about the first connection being reset comes from SSH logins to the lab during the build.

### New "Your Network" pictures for Tasks 2, 3 and 4
- **Changed:** added `images/network-underlay.png` (the instructor's new diagram, hosts on Gi0/0/0/5 and the seven
  core links) and pointed the "Your Network" section of `TASK2.md` at it. The diagram was checked against the lab's link
  table: all labeled interfaces match. The R2-R5 link has no interface labels in the picture.
- **Task 3:** added `images/network-task3.png` (same diagram with the red port-based PW between R1 Gi0/0/0/5 and R4 Gi0/0/0/5, and
  the label "Port Based Network = 172.16.1.x/24") and pointed `TASK3.md` at it. The picture still shows alpine-2 with
  editor selection handles around it.
- **Task 4:** added `images/network-task4.png` (blue VLAN-based PWs: VLAN 10 R2-R3, VLAN 11 R3-R5, VLAN 12 R5-R6, with the
  VLAN subnets listed) and pointed `TASK4.md` at it.
- **`topology.png`:** no guide references it any more; it is still in the repo root.

### SecureCRT session script added
- **Added** `securecrt/Create-Sessions.py` and `securecrt/README.md`. Run from SecureCRT (**Script > Run**), the script
  creates 12 SSH2 sessions (user `cisco`, port 22, no stored password) under `Austin Workshop/Routers` (R1-R6,
  198.18.1.11-16) and `Austin Workshop/Hosts` (alpine-1..6, 198.18.1.21-26). Addresses match the tracker.
- **Decision (instructor):** all students use SecureCRT.
- **Fixes after the first real runs (instructor in SecureCRT):** (1) "Invalid character encountered in script header at
  line 4": SecureCRT reads every leading `#` line as a header directive, so the description moved into a docstring after
  a blank line. (2) "The session option was not found: Port": the SSH2 port option is named `[SSH2] Port`. My mock
  had accepted any option name, which hid this; it now rejects unknown names.
- **Verified:** after those fixes the instructor ran it in SecureCRT and it created the sessions. Connecting to the devices
  from those sessions was not reported by me, and the Python 3 / SecureCRT version requirement is unconfirmed.
- **Not done:** `LAB-ACCESS.md` Part 2 (device access) still needs to be written; it can now point at this script.

### Task 4 added: VLAN-based PWs (PW2-PW4) on R2, R3, R5, R6
- **Added** `TASK4.md` and `solutions/task4/R2.cfg`, `R3.cfg`, `R5.cfg`, `R6.cfg`. `TASK3.md` now points to Task 4.
  `DEVICES.md` task and PW tables and the tracker Pseudowires sheet (PW2-PW4) updated.
- **Design (from the instructor's diagram):** on each PE `Gi0/0/0/5` gets `no shutdown` (not `l2transport`), plus one
  `Gi0/0/0/5.<vlan> l2transport` sub-interface per VLAN with `encapsulation dot1q <vlan>`, and `l2vpn / xconnect group
  VLAN_BASED / p2p VLAN<n>` with the peer loopback and pw-id = VLAN. VLAN 10 R2-R3, VLAN 11 R3-R5, VLAN 12 R5-R6; R3 and R5
  carry two VLANs on one port. LDP comes from the baseline, so nothing is added for it.
- **Tested on the lab (then reverted):** all three xconnects UP/UP/UP, LDP sessions up (R3 and R5 have two each),
  `PW(...)` entries tied to the sub-interfaces, `ping mpls pseudowire` 5/5 on R2 and R3. Hosts: alpine-2 to alpine-3,
  alpine-3 to alpine-5 and alpine-5 to alpine-6 all 0% loss with MACs in `ip neigh`. **End to end alpine-2 <-> alpine-6
  0% loss both ways**; traceroute from alpine-2 shows 192.168.10.3, 192.168.11.5, 192.168.12.6. alpine-5 to alpine-2 and
  alpine-6 to alpine-3 also work, so the static routes and forwarding on alpine-3/5 from `configs/alpine/` are confirmed.
  alpine-2 cannot reach the Task 3 island 172.16.1.1 (100% loss), as expected. Before the build, alpine-2 to alpine-3 had
  100% loss.
- **Observed:** `show l2vpn xconnect detail` on a VLAN AC shows `Type VLAN`, `VLAN ranges: [10, 10]`, `Rewrite Tags: []`
  and `MTU 1504` (1500 on the port-based AC), so the tag crosses the PW unchanged.
- **Failures captured (rolled back):** wrong VLAN on R6 (`dot1q 99`): xconnect and PW stay UP/UP/UP but alpine-5 to
  alpine-6 gets 100% loss. Parent port shut on R6: `AC ... state is down (Admin)`, xconnect DN. Restored; alpine-5 to
  alpine-6 pings again.
- **Not verified:** the explanations of two shut parents dropping both PWs (R3, R5) and the answers to the guide questions
  are reasoning, not tests. The "about 45 minutes" time is an estimate. I did not capture the R3 half-built output, so
  the guide describes it in words.
- **Reverted:** `rollback configuration to T4-VLAN-PW` on R2, R3, R5, R6. Backup `20261119-140639` is identical to the start
  state `20261119-132329` for all 12 devices. R2/R3/R5/R6 now have extra `T4-*` commits in their history.

### Task 3 added: port-based PW between R1 and R4 (PW1)
- **Added** `TASK3.md` (student guide) and `solutions/task3/R1.cfg`, `solutions/task3/R4.cfg`. Also fixed the header of
  `solutions/task2/R1.cfg` (said Task 1) and pointed the end of `TASK2.md` at Task 3. `DEVICES.md` task table, PW table and
  the tracker Pseudowires sheet (PW1: group `PORT_BASED`, pw-id 100) updated.
- **Design:** R1 adds `mpls ldp` (router-id 1.1.1.1, `discovery targeted-hello accept`; R4 already has it from the baseline),
  then on both PEs `interface Gi0/0/0/5` with `l2transport` and `no shutdown`, and `l2vpn / xconnect group PORT_BASED /
  p2p / interface Gi0/0/0/5 / neighbor ipv4 <peer loopback> pw-id 100`. R1 p2p name `R1_to_R4`, R4 `R4_to_R1`.
- **Tested on the lab (then reverted):** R1 temporarily got the Task 2 solution (plus `no shutdown` on Gi0/0/0/0-1), then the
  Task 3 config on R1 and R4. Verified: targeted LDP session R1-R4 up; `show l2vpn xconnect` UP/UP/UP; PW label 24014 both
  ways, `protocol LDP`, `LSP : Up`; `PW(4.4.4.4:100)` in `show mpls forwarding`; **alpine-1 <-> alpine-4 ping 0% loss both
  ways** with each host holding the other's MAC in `ip neigh`; `ping mpls pseudowire 4.4.4.4 100` 5/5. Before the PW
  existed alpine-1's ping had 100% loss. With only R1 built, the xconnect showed DN/UP/DN.
- **Failure captured:** pw-id mismatch (R4 on 101) gave `state is down ( local ready )` with remote label `unknown`;
  rolled back and the PW came back up. A shut AC showed `state is down (Admin)` in the earlier R2-R3 test.
- **Not verified / notes:** removing `mpls ldp` from R1 did not take the established PW down within about 30 seconds (it
  was restored right after), so the guide does not claim a "missing LDP" failure. Outputs in the guide came from these runs;
  the one change is that R1's AC description was shortened to `to alpine-1 eth1` in the guide (the tested text had
  extra words in parentheses). The "questions" answers 1-4 are explanations; answer 3 (third host on the port) is untested.
  The "about 30 minutes" time is an estimate.
- **Reverted:** R1 rolled back to before the temporary underlay (`rollback configuration to T3-PREP-UNDERLAY`) and R4 to its
  baseline (`rollback configuration to T3-PW`). Backup `20261119-134348` after the revert is identical to the start state
  `20261119-132329` for all 12 devices (R1 ports shut again, no LDP/l2vpn). Backup `20261119-133235` was taken before.
  The commit history on R1 and R4 now has extra commits (labels `T3-*`), so commit IDs will differ from students'.

### restore-configs.sh now skips the alpine hosts by default
- **Changed:** with no device named, `backups/restore-configs.sh` restores R1-R6 only. New `-H` flag adds the hosts, and
  naming a host (`alpine-2`) always restores it. Reason: hostname, IPs, VLANs and routes now come from the CML node config
  (`configs/alpine/`), and restoring the default `/etc` files over them would break that.
- **Verified:** dry runs only (`-n`): default lists R1-R6 with a note, `-H` lists all 12, `alpine-2` alone lists the host.
  No device was changed, and a real restore with the new logic was not run.

### Student start baseline confirmed (`task1-start`)
- **Confirmed:** the current lab state (backup `20261119-132329`, `backups/latest`) is the student start state. R1 has its
  core ports shut and no underlay; R2-R6 are pre-built (underlay, `mpls oam`, TI-LFA, targeted LDP); the hosts take their
  settings from the CML node configs in `configs/alpine/`.
- **Found:** the hosts' on-disk files are back to CML defaults (hostname `localhost`, eth0 DHCP), so the old host files in
  the baselines were stale. The R1 and R2-R6 files in `backups/baselines/task1-start` match the current backup exactly.
- **Changed (local, git-ignored):** refreshed the host and R2-R6 files in `backups/baselines/task1-start` and
  `task2-start`, and added README warnings: restore routers only (`restore-configs.sh -d baselines/task1-start R2 R3 R4 R5 R6`),
  never the hosts, because the restore script would write the default files over the node-config settings.
- **Not done:** `restore-configs.sh` itself still restores hosts when asked; I did not change it.

### Alpine node configs verified on the nodes
- **Checked (read-only, all six hosts, up 14-16 minutes after the CML config change):** hostnames are `alpine-1` to
  `alpine-6` (the `inserthostname-here` problem is fixed), eth0 has 198.18.1.2X/24 with default via 198.18.1.1, eth1 /
  `eth1.<vlan>` addresses match `configs/alpine/`, static routes are present, and `ip_forward` is 1 only on alpine-3 and
  alpine-5. The `8021q` module loaded on the four hosts that use VLANs.
- **Not tested:** connectivity across the PWs (no PWs exist and the routers' Gi0/0/0/5 ports are shut), including the
  alpine-2 to alpine-6 path through alpine-3 and alpine-5. Do that after Task 3.
- **Changed:** nothing on the devices. Docs only (`DEVICES.md` note updated).

### Targeted LDP added to the R2-R6 baseline (for LDP-signaled PWs)
- **Changed (R2-R6):** `mpls ldp` with `router-id` = Loopback0 (2.2.2.2 to 6.6.6.6) and, under `address-family ipv4`,
  `discovery targeted-hello accept`. Committed on each. No LDP on any interface, so there is no link LDP and the
  transport stays SR-MPLS. Saved in `configs/task2-prebuilt/R2.txt` to `R6.txt`. R1 is not changed: the student adds LDP
  in Task 3.
- **Decisions (instructor):** keep `targeted-hello accept`, no `log neighbor`.
- **Command note:** `discovery targeted-hello accept` is rejected directly under `mpls ldp` on XR 25.1.1; it must be
  under `address-family ipv4`. The first apply committed only the router-id; the second pass added the accept line.
- **Verified (temporary test, then rolled back):** built an `l2vpn` xconnect (group TMP, `neighbor ipv4 3.3.3.3 pw-id 999`
  on Gi0/0/0/5) on R2 and R3. The targeted LDP session came up loopback to loopback (`Tgt:3.3.3.3`, neighbor up),
  PW labels were exchanged (local 24012, remote 24013), `LSP : Up`. The PW stayed down only because Gi0/0/0/5 is shut
  (AC down). `rollback configuration last 1` on both removed the l2vpn config and left the LDP baseline; Gi0/0/0/5 is
  back to `shutdown`. The R2 to R3 LDP session stayed up after the rollback.
- **Observed:** routes to non-adjacent loopbacks still use the SR label (for example 6.6.6.6 outgoing 16006). I did
  not compare label allocation before and after LDP was added.
- **Backups:** `20261119-131852` (before), `20261119-132329` (after, now the lab start state). A diff showed only the
  `mpls ldp` block added on R2-R6. R1 and the alpine hosts are unchanged. Local baselines `task1-start` and
  `task2-start` had R2-R6 replaced with the new configs.
- **Docs:** `DEVICES.md` configuration status table and the tracker Devices sheet updated.

### Alpine hosts: startup configs moved into CML node config, data addressing and static routes designed
- **Found:** the alpine hosts' live hostname was `inserthostname-here` after the relaunch. Cause: CML attaches a config
  disc to each node, and the image's `/etc/local.d/virl2-01-day0config.start` runs its `node.cfg` as a shell script on
  every boot. The default `hostname inserthostname-here` line in it ran after `/etc/hostname` was applied. (Read-only
  diagnosis on alpine-1; nothing was changed on the hosts.)
- **Decision (instructor):** put all host settings in each node's CML configuration, so they survive a wipe or relaunch.
  The instructor edited the node configs in CML for the hostname; after that the hosts stopped answering ping/SSH (nodes
  restarting), and `ip addr` showed no address, which is why the IPs were added to the config too.
- **Added** `configs/alpine/alpine-1.cfg` to `alpine-6.cfg`: hostname, eth0 mgmt IP (198.18.1.2X/24) and default route,
  eth1 data addressing, static routes, and the `cisco/cisco` account lines CML needs. Design from the instructor's
  diagram:
  - Port-based PW alpine-1 <-> alpine-4: `172.16.1.X/24` untagged on eth1.
  - VLAN PWs on `eth1.<vlan>` (`modprobe 8021q`): VLAN 10 alpine-2 <-> alpine-3 (`192.168.10.X/24`), VLAN 11 alpine-3
    <-> alpine-5 (`192.168.11.X/24`), VLAN 12 alpine-6 <-> alpine-5 (`192.168.12.X/24`).
  - alpine-3 and alpine-5 forward IP (`net.ipv4.ip_forward=1`). Static routes let alpine-2 reach alpine-5/6 and back:
    alpine-2 via 192.168.10.3, alpine-3 to VLAN 12 via 192.168.11.5, alpine-5 to VLAN 10 via 192.168.11.3, alpine-6 via
    192.168.12.5.
- **Docs:** tracker Hosts sheet (data addressing, static routes, config file, role) and Pseudowires sheet (planned PW1-PW4,
  not configured) updated; `DEVICES.md` regenerated with the host startup configuration and planned pseudowires.
- **Not verified:** the config files passed a shell syntax check (`sh -n`) only. They have not been run on the nodes, and
  `8021q` VLAN support in the image is unconfirmed. The hosts were still down when this was written. Routers were not
  touched. Task 3 (the PW configuration itself) has not been started.
- **Backups:** none taken (no device changes from this side). After the hosts return, take a backup and re-check the
  hostnames, IPs and routes; the `task1-start`/`task2-start` host baselines hold the old static `/etc/network/interfaces`.

### Post-outage relaunch: R1 core ports now start shut; Task 1 enables them
- **Event:** the datacenter had an outage and the lab was checkpointed and relaunched. After reconnecting the VPN,
  all 12 devices answered ping and SSH (cisco/cisco). Routers were up 14 minutes, alpine hosts 18 minutes.
- **Found:** R2-R6 and all alpine config files matched the `task2-start` baseline. R1 differed: Gi0/0/0/0 and Gi0/0/0/1
  came back with an explicit `shutdown` (a bare `no shutdown` leaves no config lines, so it did not survive the
  relaunch). R1 therefore had no LLDP neighbors. The alpine hosts' live hostnames reset to `inserthostname-here`
  even though `/etc/hostname` still held the right name (not fixed yet).
- **Decision:** R1's core ports are assumed to start shut. `TASK1.md` has a new **Part 4 - Enable R1's core
  interfaces** (stage with `no shutdown`, `show configuration`, `commit`, verify with `show ip interface brief` and
  `show lldp neighbors`). The old Part 4 (XE vs XR OSPF) is now Part 5. `TASK2.md` starting state and troubleshooting
  now say the ports are enabled in Task 1. `DEVICES.md` task table and R1 notes updated.
- **Changed then reverted (R1):** ran the Part 4 commands on R1 to capture output (ports Up/Up, LLDP showed R2 and R6
  after about a minute), then put `shutdown` back on both ports. A backup diff confirmed R1 matches the post-relaunch
  backup `20261119-102507`.
- **Verified:** LLDP neighbors take up to about a minute to appear after the ports come up, and the guide says so.
- **Backups:** `20261119-102507` (post-relaunch state), `20261119-103002` (Task 1 start state, R1 ports shut).
- **Baselines (local):** new `backups/baselines/task1-start` (R1 ports shut). `task2-start` is unchanged and is the state
  after Task 1 completes; its README now warns that a merge restore cannot remove an explicit `shutdown` and that a bare
  `no shutdown` does not survive a relaunch.

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
- `c07c4f3` Update devices for revised topology.
- `5df04ea` Add device information reference (`DEVICES.md`).
- `2db152b` Add lab access guide, Part 1: VPN connection (`LAB-ACCESS.md`).
- `XR_PW_Workshop_Tracker.xlsx` created: devices, IP plan, links, hosts, OSPF/SR, pseudowires, login checks.
- **IP plan agreed:** links `10.<A>.<B>.<n>/31` (lower router gets the even address),
  loopbacks `R.R.R.R/32`, SR prefix-SID label 16000+R, mgmt `198.18.1.1X`.

### Not done yet
- No LDP or pseudowire configuration (Task 2). (Update 2026-11-19: PW pairs and alpine eth1 addressing are now decided; see the top entry.)
- Host ports Gi0/0/0/5 stay shut down; students enable them in Task 2.
