# SecureCRT sessions for the lab

`Create-Sessions.py` creates one SSH2 session for each of the 12 lab devices in SecureCRT.

| Folder | Sessions | Address |
|---|---|---|
| `Austin Workshop/Routers` | R1 to R6 | `198.18.1.11` to `198.18.1.16` |
| `Austin Workshop/Hosts` | alpine-1 to alpine-6 | `198.18.1.21` to `198.18.1.26` |

All sessions use SSH2, port 22 and the username `cisco`.

## How to use it

1. Connect to the lab VPN first. See [LAB-ACCESS.md](../LAB-ACCESS.md).
2. In SecureCRT choose **Script > Run...** and select `Create-Sessions.py`.
3. A message box says how many sessions were created.
4. Open **File > Connect** (Ctrl+Shift+C). The sessions are under **Austin Workshop**.
5. When asked for a password, enter `cisco`.

Running the script again overwrites the sessions with the same names, so it is safe to repeat.

## Notes

- The password is deliberately **not** saved in the sessions. SecureCRT asks for it at each login.
- The script needs a SecureCRT version with Python 3 scripting (9.0 or later). With an older version, create the sessions by hand
  with the table above.
- To change an address, edit the `DEVICES` list at the top of the script. It matches `XR_PW_Workshop_Tracker.xlsx`.
- **Status:** the script's logic was tested against a stand-in for the SecureCRT scripting API, which printed the
  expected 12 sessions. It has **not** been run in SecureCRT itself yet. If it fails when you try it,
  tell the instructor which message you got.
