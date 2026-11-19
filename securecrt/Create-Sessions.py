# $language = "Python3"
# $interface = "1.0"
#
# Austin Workshop - create SecureCRT sessions for every lab device.
#
# Creates 12 SSH2 sessions under the folder "Austin Workshop":
#   Austin Workshop/Routers/R1 .. R6        198.18.1.11 - 198.18.1.16
#   Austin Workshop/Hosts/alpine-1 .. 6     198.18.1.21 - 198.18.1.26
# Username is "cisco". The password (also "cisco") is NOT stored; SecureCRT asks for it
# when you connect.
#
# Run it from SecureCRT: Script > Run... and pick this file. Running it again
# overwrites the sessions with the same names. Requires SecureCRT with Python 3 scripting (9.0 or later).
# You must be connected to the lab VPN to connect to the sessions (see LAB-ACCESS.md).

ROOT = "Austin Workshop"
USERNAME = "cisco"
PORT = 22

# Keep in sync with XR_PW_Workshop_Tracker.xlsx (Devices and Hosts sheets).
DEVICES = [
    ("Routers", "R1", "198.18.1.11"),
    ("Routers", "R2", "198.18.1.12"),
    ("Routers", "R3", "198.18.1.13"),
    ("Routers", "R4", "198.18.1.14"),
    ("Routers", "R5", "198.18.1.15"),
    ("Routers", "R6", "198.18.1.16"),
    ("Hosts", "alpine-1", "198.18.1.21"),
    ("Hosts", "alpine-2", "198.18.1.22"),
    ("Hosts", "alpine-3", "198.18.1.23"),
    ("Hosts", "alpine-4", "198.18.1.24"),
    ("Hosts", "alpine-5", "198.18.1.25"),
    ("Hosts", "alpine-6", "198.18.1.26"),
]


def create_session(folder, name, host):
    path = "%s/%s/%s" % (ROOT, folder, name)
    cfg = crt.OpenSessionConfiguration("Default")
    cfg.SetOption("Protocol Name", "SSH2")
    cfg.SetOption("Hostname", host)
    cfg.SetOption("Port", PORT)
    cfg.SetOption("Username", USERNAME)
    cfg.Save(path)
    return path


def main():
    made = []
    problems = []
    for folder, name, host in DEVICES:
        try:
            made.append(create_session(folder, name, host))
        except Exception as e:  # keep going so one failure does not stop the rest
            problems.append("%s: %s" % (name, e))
    msg = "Created %d of %d sessions under '%s'." % (len(made), len(DEVICES), ROOT)
    if problems:
        msg += "\n\nProblems:\n" + "\n".join(problems)
    else:
        msg += "\n\nOpen them from File > Connect (Ctrl+Shift+C). Password: cisco."
    crt.Dialog.MessageBox(msg, "Austin Workshop sessions")


main()
