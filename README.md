# Austin XR PW Services Workshop

A hands-on lab for engineers new to **Cisco IOS XR**: learn the XR configuration model, build an SR-MPLS underlay on one router,
then build port-based and VLAN-based **pseudowires** across a six-router core.

The student guide is a MkDocs site. The pages are in [`docs/`](docs/).

| Page | Source |
|---|---|
| Home | [docs/index.md](docs/index.md) |
| Lab Access (VPN and SecureCRT) | [docs/LAB-ACCESS.md](docs/LAB-ACCESS.md) |
| Task 1 - IOS XR Basics | [docs/TASK1.md](docs/TASK1.md) |
| Task 2 - Underlay on R1 | [docs/TASK2.md](docs/TASK2.md) |
| Task 3 - Port-Based Pseudowire | [docs/TASK3.md](docs/TASK3.md) |
| Task 4 - VLAN-Based Pseudowires | [docs/TASK4.md](docs/TASK4.md) |
| Answers | [docs/ANSWERS.md](docs/ANSWERS.md) |

## Preview or build the guide

```
pip install -r requirements.txt
python3 -m mkdocs serve          # live preview at http://127.0.0.1:8000
python3 -m mkdocs build --strict # writes the static site to site/
```

The guides use MkDocs features (boxes, tabs), so read them in the built site rather than on GitHub.

## Repository contents

| Path | What it is |
|---|---|
| `docs/` | The student guide (single source for the site) |
| `configs/` | Router start configs for R2 to R6 and the alpine host configs (CML node configs) |
| `solutions/` | Finished router configs for each task (instructor reference) |
| `backups/` | Scripts to back up and restore the lab devices |
| `DEVICES.md`, `XR_PW_Workshop_Tracker.xlsx` | Addressing plan and device tracker |
| `CHANGELOG.md` | History of changes to the lab and guides |

The lab runs in Cisco dCloud (IOS XR 25.1.1 on CML). The `cisco` / `cisco` logins are lab-only.
