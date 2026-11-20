# Task 1 - IOS XR Basics

**Goal:** get comfortable with the way IOS XR handles configuration *before* you build anything real.
You will learn the **two-stage commit** model, how to **preview, discard and roll back** changes,
and how a basic **OSPF** configuration looks on **IOS XR** compared with **IOS XE**.

Most of this task is safe practice: you make changes and undo them. The one change you keep is **enabling R1's two core
interfaces** in Part 4, which Task 2 needs. R1's hostname ends exactly as it started.

**What you will learn**

- Why a change on XR does nothing until you `commit`
- How to look at your pending changes (the *target configuration*) and throw them away
- How to roll back a change after it has been committed
- How to enable an interface (a first real change) and confirm it with LLDP
- How XR and XE differ for a basic OSPF setup, using the same R1 design you will build in Task 2

**Time:** about 30 minutes.

---

## Before you start

Log in to **R1** (`198.18.1.11`, username `cisco`, password `cisco`). You should see a prompt like this:

```
RP/0/RP0/CPU0:R1#
```

Read it left to right: `RP/0/RP0/CPU0` is the route processor, and `R1` is the router's hostname.
Keep an eye on the hostname in the prompt. You are about to change it.

---

## Part 1 - The two-stage commit

On IOS XE (and classic IOS), a command takes effect the moment you press Enter.
**IOS XR works differently.** When you type a configuration command it goes into a private
**target configuration** (also called the candidate configuration). The router keeps running the old
**running configuration** until you tell it to apply your changes with `commit`.

```
  you type          +------------------+   commit    +----------------------+
  config commands ->|  TARGET config   | ----------> |   RUNNING config     |
                    | (your pending    |             | (what the router is  |
                    |  changes, only   |             |  actually doing)     |
                    |  you can see it) |             +----------------------+
                    +------------------+
                       |  abort / clear / end + "no"
                       v
                    discarded
```

### Step 1.1 - Check the current hostname

```
show running-config hostname
```

```
RP/0/RP0/CPU0:R1#show running-config hostname
hostname R1
```

### Step 1.2 - Change it, but do not commit yet

```
configure terminal
hostname R1-LAB
```

You are now in configuration mode, and the prompt shows `(config)`. Look closely: the hostname in the
prompt is **still `R1`**. Now look at your pending change:

```
show configuration
```

```
RP/0/RP0/CPU0:R1(config)#show configuration
!! Building configuration...
!! IOS XR Configuration 25.1.1
hostname R1-LAB
end
```

`show configuration` shows **only your uncommitted changes**, which is the target configuration.
Now check what the router is actually running:

```
show running-config hostname
```

```
RP/0/RP0/CPU0:R1(config)#show running-config hostname
hostname R1
```

The running configuration still says `R1`. Your change exists only in the target configuration.
**Nothing has happened to the router yet.**

### Step 1.3 - Commit

```
commit
```

```
RP/0/RP0/CPU0:R1(config)#commit
RP/0/RP0/CPU0:R1-LAB(config)#
```

The prompt changed to `R1-LAB` the moment the commit succeeded. Confirm it:

```
show running-config hostname
```

```
RP/0/RP0/CPU0:R1-LAB(config)#show running-config hostname
hostname R1-LAB
```

Leave configuration mode:

```
end
```

!!! warning ""
    **Remember:** the most common mistake on XR is typing the commands and forgetting `commit`.
    If a change does not seem to work, run `show configuration` in config mode. Anything listed there has not been applied yet.

**Checkpoint:** the prompt shows `R1-LAB` and `show running-config hostname` says `hostname R1-LAB`.

---

## Part 2 - Previewing and discarding pending changes

The target configuration lets you build up several changes, review them together, and apply them
all at once, or throw them away. Start a new session and make two changes:

```
configure terminal
hostname R1-TMP
interface Loopback99
 description scratch
 ipv4 address 99.99.99.99 255.255.255.255
 exit
show configuration
```

```
RP/0/RP0/CPU0:R1-LAB(config)#show configuration
!! Building configuration...
!! IOS XR Configuration 25.1.1
hostname R1-TMP
interface Loopback99
 description scratch
 ipv4 address 99.99.99.99 255.255.255.255
!
end
```

You can review everything you are about to apply in one place. There are three ways to get rid of it
without committing.

### Option A - Leave with `end` and answer `no`

```
end
```

```
RP/0/RP0/CPU0:R1-LAB(config)#end
Uncommitted changes found, commit them before exiting(yes/no/cancel)? [cancel]:
```

XR notices that you have pending changes and asks what to do:

| Answer | What happens |
|---|---|
| `yes` | Commit the changes, then exit |
| `no` | **Discard** the changes and exit |
| `cancel` | Stay in configuration mode (the default) |

Type `no`. Then check that nothing was applied:

```
show running-config interface Loopback99
```

```
RP/0/RP0/CPU0:R1-LAB#show running-config interface Loopback99
% No such configuration item(s)
```

The hostname is also unchanged (`R1-LAB`) and the loopback was never created.

### Option B - `abort`

`abort` discards the target configuration and takes you straight back to exec mode, with no question asked.

```
configure terminal
hostname R1-TMP
abort
show running-config hostname
```

```
RP/0/RP0/CPU0:R1-LAB(config)#abort
RP/0/RP0/CPU0:R1-LAB#show running-config hostname
hostname R1-LAB
```

### Option C - `clear`

`clear` empties the target configuration but keeps you **in configuration mode**, so you can start over.

```
configure terminal
hostname R1-TMP
show configuration
clear
show configuration
end
```

```
RP/0/RP0/CPU0:R1-LAB(config)#show configuration
!! Building configuration...
!! IOS XR Configuration 25.1.1
hostname R1-TMP
end
RP/0/RP0/CPU0:R1-LAB(config)#clear
RP/0/RP0/CPU0:R1-LAB(config)#show configuration
!! Building configuration...
!! IOS XR Configuration 25.1.1
end
```

After `clear`, `show configuration` is empty, so there is nothing pending. Because the target was empty,
`end` does not ask any question.

### Also good to know

- **`show` commands work inside configuration mode.** You do not need `do` as you would on XE, although `do show ...` is accepted too.
- **A configuration file can be loaded into the target configuration** with `load <file>`. You then review it with
  `show configuration` and choose whether to `commit` it. It is the same safety net as typing the commands.
- **`commit` can be given a label and a comment**, which makes a change easy to find later. For example
  `commit label HOSTNAME-DEMO comment Changed hostname for the XR basics demo`. The label then appears in the commit
  history in place of the numeric ID:

```
RP/0/RP0/CPU0:R1-LAB#show configuration commit list 2
SNo. Label/ID              User      Line                Client      Time Stamp
~~~~ ~~~~~~~~              ~~~~      ~~~~                ~~~~~~      ~~~~~~~~~~
1    HOSTNAME-DEMO         cisco     vty0:node0_RP0_CPU  CLI         Tue Nov 17 16:28:05 2026
2    1000000025            cisco     vty0:node0_RP0_CPU  Rollback    Tue Nov 17 16:27:21 2026
```

  This is only an example. You do not need to run it now, because the hostname is already `R1-LAB`.

**Checkpoint:** no loopback `99.99.99.99` exists, and the hostname is still `R1-LAB`.

---

## Part 3 - Rolling back a committed change

A `commit` is not final. XR keeps a **commit history**, and you can undo changes after they have been applied.

### Step 3.1 - Look at the commit history

```
show configuration commit list 4
```

```
RP/0/RP0/CPU0:R1-LAB#show configuration commit list 4
SNo. Label/ID              User      Line                Client      Time Stamp
~~~~ ~~~~~~~~              ~~~~      ~~~~                ~~~~~~      ~~~~~~~~~~
1    1000000024            cisco     vty0:node0_RP0_CPU  CLI         Tue Nov 17 16:27:17 2026
2    1000000023            cisco     con0_RP0_CPU0       CLI         Tue Nov 17 15:15:25 2026
3    1000000022            cisco     vty0:node0_RP0_CPU  CLI         Tue Nov 17 14:46:30 2026
4    1000000021            cisco     vty0:node0_RP0_CPU  CLI         Tue Nov 17 14:46:10 2026
```

Every commit gets an ID (or the label you gave it), the user, and a timestamp.
**Your IDs and timestamps will be different.** The newest commit is at the top.
The one at the top is your hostname change.

### Step 3.2 - See what the last commit changed

```
show configuration commit changes last 1
```

```
RP/0/RP0/CPU0:R1-LAB#show configuration commit changes last 1
!! Building configuration...
!! IOS XR Configuration 25.1.1
hostname R1-LAB
end
```

### Step 3.3 - Preview the rollback before doing it

```
show configuration rollback changes last 1
```

```
RP/0/RP0/CPU0:R1-LAB#show configuration rollback changes last 1
!! Building configuration...
!! IOS XR Configuration 25.1.1
hostname R1
end
```

This shows what the router would be changed *to* if you rolled back one commit: the hostname goes back to `R1`.
It changes nothing yet.

### Step 3.4 - Roll back

```
rollback configuration last 1
```

```
RP/0/RP0/CPU0:R1-LAB#rollback configuration last 1
Loading Rollback Changes.
Loaded Rollback Changes in 1 sec 
Committing.
1 items committed in 1 sec (0)items/sec
Updating.
Updated Commit database in 1 sec 
Configuration successfully rolled back 1 commits.
RP/0/RP0/CPU0:R1#
```

The prompt is `R1` again. Confirm and look at the history:

```
show running-config hostname
show configuration commit list 4
```

```
RP/0/RP0/CPU0:R1#show running-config hostname
hostname R1
RP/0/RP0/CPU0:R1#show configuration commit list 4
SNo. Label/ID              User      Line                Client      Time Stamp
~~~~ ~~~~~~~~              ~~~~      ~~~~                ~~~~~~      ~~~~~~~~~~
1    1000000025            cisco     vty0:node0_RP0_CPU  Rollback    Tue Nov 17 16:27:21 2026
2    1000000024            cisco     vty0:node0_RP0_CPU  CLI         Tue Nov 17 16:27:17 2026
3    1000000023            cisco     con0_RP0_CPU0       CLI         Tue Nov 17 15:15:25 2026
4    1000000022            cisco     vty0:node0_RP0_CPU  CLI         Tue Nov 17 14:46:30 2026
```

Notice that **the rollback is itself a new commit** (Client = `Rollback`). Nothing is erased from the history.
You can even undo a rollback by rolling back again.

### Rolling back further, and by label

| Command | Effect |
|---|---|
| `rollback configuration last 1` | Undo the most recent commit |
| `rollback configuration last 3` | Undo the last three commits |
| `rollback configuration to <ID or label>` | Undo that commit **and every commit after it** |

For example, if you committed two changes labelled `STEP-A` then `STEP-B`,
`rollback configuration to STEP-A` returns the router to the configuration it had **before** STEP-A. Both
changes are undone.

### A safety net for risky changes: `commit confirmed`

```
configure terminal
hostname R1-CONF
commit confirmed 30
```

`commit confirmed 30` applies the change, but **only for 30 seconds**. To keep it you must run `commit`
again while still in configuration mode before the timer ends. If you do not (for example because the change cut off your connection),
the router rolls back by itself. Leaving configuration mode without confirming also rolls it back, and XR warns you:

```
RP/0/RP0/CPU0:R1-CONF(config)#end
You are exiting after a 'commit confirm' with an active rollback session.  If you exit the configuration awaiting confirmation will not be confirmed and the router will immediately rollback to the previous configuration.
Do you wish to exit? [no]:
```

Answer `yes` and the hostname returns to `R1`. This is the habit to use when changing something that could lock you out.

**Checkpoint:** `show running-config hostname` says `hostname R1`, and you have seen a `Rollback` entry in the commit list.

---

## Part 4 - Enable R1's core interfaces

Now use what you have learned on a real change. R1 is cabled to R2 and R6, but on XR an interface stays
**shut down** until someone enables it, and R1's two core interfaces start that way. Task 2 needs them up.

First look at the current state:

```
show ip interface brief
show lldp neighbors
```

```
RP/0/RP0/CPU0:R1#show ip interface brief
Interface                      IP-Address      Status          Protocol Vrf-Name
MgmtEth0/RP0/CPU0/0            198.18.1.11     Up              Up       management
GigabitEthernet0/0/0/0         unassigned      Shutdown        Down     default
GigabitEthernet0/0/0/1         unassigned      Shutdown        Down     default
GigabitEthernet0/0/0/2         unassigned      Shutdown        Down     default
GigabitEthernet0/0/0/3         unassigned      Shutdown        Down     default
GigabitEthernet0/0/0/4         unassigned      Shutdown        Down     default
GigabitEthernet0/0/0/5         unassigned      Shutdown        Down     default
RP/0/RP0/CPU0:R1#show lldp neighbors
Device ID       Local Intf                      Hold-time  Capability      Port ID
Total entries displayed: 0
```

Every interface is `Shutdown` and R1 sees no neighbors. Gi0/0/0/0 goes to R2 and Gi0/0/0/1 goes to R6
(see the topology in Task 2). Enable just those two, following the same steps as in Part 1: stage the change,
review it, then commit.

```
configure terminal
interface GigabitEthernet0/0/0/0
 no shutdown
 exit
interface GigabitEthernet0/0/0/1
 no shutdown
 exit
show configuration
```

```
RP/0/RP0/CPU0:R1(config)#show configuration
!! Building configuration...
!! IOS XR Configuration 25.1.1
interface GigabitEthernet0/0/0/0
 no shutdown
!
interface GigabitEthernet0/0/0/1
 no shutdown
!
end
```

Your pending changes are exactly the two you meant. Apply them:

```
commit
end
```

### Verify Part 4

```
show ip interface brief
```

```
Interface                      IP-Address      Status          Protocol Vrf-Name
MgmtEth0/RP0/CPU0/0            198.18.1.11     Up              Up       management
GigabitEthernet0/0/0/0         unassigned      Up              Up       default
GigabitEthernet0/0/0/1         unassigned      Up              Up       default
GigabitEthernet0/0/0/2         unassigned      Shutdown        Down     default
GigabitEthernet0/0/0/3         unassigned      Shutdown        Down     default
GigabitEthernet0/0/0/4         unassigned      Shutdown        Down     default
GigabitEthernet0/0/0/5         unassigned      Shutdown        Down     default
```

Both interfaces are now `Up / Up`. They have no IP address yet. That comes in Task 2. Leave Gi0/0/0/2 to
Gi0/0/0/5 shut down. Now check that R1 can see its neighbors. LLDP sends a message about every 30 seconds, so it can
take up to a minute for them to appear. If the list is empty, wait a little and run it again:

```
show lldp neighbors
```

```
Device ID       Local Intf                      Hold-time  Capability      Port ID
R2              GigabitEthernet0/0/0/0          120        R               GigabitEthernet0/0/0/0
R6              GigabitEthernet0/0/0/1          120        R               GigabitEthernet0/0/0/1
Total entries displayed: 2
```

LLDP confirms the cabling: R1 Gi0/0/0/0 reaches R2 Gi0/0/0/0, and R1 Gi0/0/0/1 reaches R6 Gi0/0/0/1.

!!! tip ""
    **If you ever need to undo it:** `show configuration commit changes last 1` shows this change, and
    `rollback configuration last 1` would shut the ports again. Do not roll it back now, because Task 2 needs them up.

**Checkpoint:** Gi0/0/0/0 and Gi0/0/0/1 are `Up / Up`, and `show lldp neighbors` lists R2 and R6.

---

## Part 5 - OSPF on IOS XE vs IOS XR

If you know IOS or IOS XE, XR will feel familiar but organised differently. Here is the **same basic OSPF
design for R1** in both: a loopback, two point-to-point /31 links, OSPF process 1 in area 0, and the loopback passive.

!!! warning ""
    **This part is for reading only. Do not type any of these configurations on R1 now.** The XE and XR blocks below are
    shown side by side so you can *see* how the two platforms differ. You will **enter the XR configuration yourself in
    [Task 2](TASK2.md)**, step by step, and verify it.

### IOS XE (for comparison only)

```
interface Loopback0
 ip address 1.1.1.1 255.255.255.255
 ip ospf 1 area 0
!
interface GigabitEthernet1
 description to R2
 ip address 10.1.2.0 255.255.255.254
 ip ospf network point-to-point
 ip ospf 1 area 0
 no shutdown
!
interface GigabitEthernet2
 description to R6
 ip address 10.1.6.0 255.255.255.254
 ip ospf network point-to-point
 ip ospf 1 area 0
 no shutdown
!
router ospf 1
 router-id 1.1.1.1
 passive-interface Loopback0
```

Every line takes effect as soon as you press Enter.

### IOS XR (a preview of what you will enter in Task 2)

This is the XR version of the same design. **Do not enter it now.** In Task 2 you build it in stages
(addresses, then OSPF) and check each stage before moving on.

```
interface Loopback0
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
 area 0
  interface Loopback0
   passive enable
  !
  interface GigabitEthernet0/0/0/0
   network point-to-point
  !
  interface GigabitEthernet0/0/0/1
   network point-to-point
  !
 !
!
```

### What is different

| | IOS XE | IOS XR |
|---|---|---|
| **Applying changes** | Immediately, line by line | Staged in the target config, applied together with `commit` |
| **Undoing a change** | Retype it with `no`, or restore a saved file | `abort` / `clear` before the commit, `rollback configuration` after |
| **Saving** | `write memory` (or `copy run start`) | No separate save: a successful `commit` is recorded in the commit history |
| **IP address command** | `ip address` | `ipv4 address` |
| **Where OSPF is enabled on an interface** | On the interface: `ip ospf 1 area 0` (or a `network` statement under `router ospf`) | Under the router: `router ospf 1` then `area 0` then `interface ...` |
| **Interface OSPF settings** | `ip ospf network point-to-point` on the interface | `network point-to-point` under the interface inside the OSPF area |
| **Passive interface** | `passive-interface Loopback0` | `passive enable` under the interface inside the OSPF area |
| **Structure** | Mostly flat, with a few blocks | Hierarchical: process, area, interface. The `!` closes a block |
| **Interface names** | Differ by platform, for example `GigabitEthernet1` | Rack/slot/module/port, for example `GigabitEthernet0/0/0/0` |
| **Leaving config mode** | `end` or Ctrl-Z | `end` asks whether to commit if anything is pending |

### The same commands, in both

| Task | IOS XE | IOS XR |
|---|---|---|
| OSPF neighbors | `show ip ospf neighbor` | `show ospf neighbor` |
| OSPF interfaces | `show ip ospf interface brief` | `show ospf interface brief` |
| OSPF routes | `show ip route ospf` | `show route ospf` |
| Interface summary | `show ip interface brief` | `show ip interface brief` (same) |
| OSPF config only | `show running-config \| section ospf` | `show running-config router ospf 1` |
| Show a show command from config mode | `do show ...` | `show ...` (or `do show ...`) |

!!! note ""
    **In the lab:** XR interfaces start shut down unless someone enables them, which is why you enabled R1's two core
    interfaces in Part 4. On XE the same step is `no shutdown`, and a new router interface often needs it too.

Nothing in this part changes R1. You will configure the XR version yourself in **Task 2**, and you will use
`show configuration` and `commit` exactly as practised here.

---

## Check your understanding

<details markdown="1">
<summary>1. You type <code>hostname R1-NEW</code> in configuration mode and then run <code>show running-config hostname</code>. What does it show?</summary>

`hostname R1`. The change is only in the target configuration until you `commit`.
</details>

<details markdown="1">
<summary>2. You made several changes and want to start over without leaving configuration mode. Which command?</summary>

`clear`. It empties the target configuration and keeps you in config mode. `abort` would also discard everything, but it takes you out of config mode.
</details>

<details markdown="1">
<summary>3. You committed a bad change an hour ago, and two other commits came after it. How do you undo only the most recent commit, and how do you undo the bad one and everything after it?</summary>

`rollback configuration last 1` undoes only the most recent commit. `rollback configuration to <ID or label>` undoes the named commit and every commit after it. `show configuration commit list` shows the IDs.
</details>

<details markdown="1">
<summary>4. Where do you enable OSPF on an interface in XR, compared with XE?</summary>

In XR the interface goes under the area inside `router ospf`. In XE it is usually configured on the interface itself with `ip ospf 1 area 0`.
</details>

<details markdown="1">
<summary>5. You are about to change a link that you reach the router through. What is the safest way to commit?</summary>

`commit confirmed <seconds>`. If the change breaks your connection and you cannot confirm it, the router rolls itself back.
</details>

---

## Cleanup

Make sure R1 ends in the right state for Task 2:

```
show running-config hostname
show ip interface brief
```

The hostname should be `hostname R1`, and Gi0/0/0/0 and Gi0/0/0/1 should be `Up / Up`. If the hostname is wrong, set it back:

```
configure terminal
hostname R1
commit
end
```

---

## XR command cheat sheet

| Command | What it does |
|---|---|
| `configure terminal` | Enter configuration mode |
| `show configuration` | Show pending (uncommitted) changes |
| `commit` | Apply the pending changes |
| `commit confirmed <seconds>` | Apply for a limited time, then roll back unless confirmed |
| `commit label <name> comment <text>` | Commit with a label and a comment |
| `abort` | Discard pending changes and leave config mode |
| `clear` | Discard pending changes, stay in config mode |
| `end` | Leave config mode (asks about uncommitted changes) |
| `exit` | Go up one level (for example out of an interface) |
| `show running-config [section]` | Show the running configuration, or one part of it |
| `show configuration commit list` | Show the commit history |
| `show configuration commit changes last <n>` | Show what the last n commits changed |
| `show configuration rollback changes last <n>` | Preview a rollback |
| `rollback configuration last <n>` | Undo the last n commits |
| `rollback configuration to <ID or label>` | Undo that commit and everything after it |
| `?` and Tab | Context help and command completion |
| <code>&#124; include &lt;text&gt;</code> | Filter output, for example `show interfaces brief \| include Gi` |

**Next:** [Task 2 - Build the Underlay on R1](TASK2.md)
