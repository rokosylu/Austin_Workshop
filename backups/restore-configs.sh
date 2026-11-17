#!/usr/bin/env bash
# Restore configs from a backup made by backup-configs.sh.
#
#   Routers: the .cfg is copied to the router (harddisk:) and applied with
#            "load" + "commit" (merge, default) or "commit replace" (-r).
#   Hosts:   /etc/hostname, /etc/hosts and /etc/network/interfaces are rewritten
#            (needs root, sudo or doas on the host), then "lbu commit" if present.
#            Network changes take effect after: rc-service networking restart (or reboot).
#
# Usage: ./restore-configs.sh [-d backup_dir] [-n] [-r] [-y] [device ...]
#   -d DIR   backup folder to restore from (default: ./latest next to this script)
#   -n       dry run: show what would be restored, change nothing
#   -r       routers only: REPLACE the entire running config instead of merging
#   -y       do not ask for confirmation
#   device   any of R1..R6 alpine-1..alpine-6 (default: every device that has a .cfg in DIR)
#
# Examples:
#   ./restore-configs.sh -n                      # dry run, everything
#   ./restore-configs.sh R2 R5                   # merge latest backup into R2 and R5
#   ./restore-configs.sh -d 20261116-202808 -y   # a specific backup, no prompt
#
# Requires: sshpass, ssh, scp, expect, VPN access to 198.18.1.0/24. Lab-only credentials.

set -u
USER_NAME="cisco"; PASS="cisco"
ip_of() {
  case "$1" in
    R1) echo 198.18.1.11;; R2) echo 198.18.1.12;; R3) echo 198.18.1.13;;
    R4) echo 198.18.1.14;; R5) echo 198.18.1.15;; R6) echo 198.18.1.16;;
    alpine-1) echo 198.18.1.21;; alpine-2) echo 198.18.1.22;; alpine-3) echo 198.18.1.23;;
    alpine-4) echo 198.18.1.24;; alpine-5) echo 198.18.1.25;; alpine-6) echo 198.18.1.26;;
  esac
}
ORDER=(R1 R2 R3 R4 R5 R6 alpine-1 alpine-2 alpine-3 alpine-4 alpine-5 alpine-6)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$SCRIPT_DIR/latest"; DRY=0; REPLACE=0; YES=0
while getopts "d:nry" o; do
  case $o in
    d) if [ -d "$OPTARG" ]; then DIR="$OPTARG"; else DIR="$SCRIPT_DIR/$OPTARG"; fi ;;
    n) DRY=1 ;; r) REPLACE=1 ;; y) YES=1 ;;
    *) sed -n '2,25p' "$0"; exit 2 ;;
  esac
done
shift $((OPTIND-1))

for c in sshpass ssh scp expect; do command -v $c >/dev/null 2>&1 || { echo "$c not found"; exit 1; }; done
[ -d "$DIR" ] || { echo "Backup folder not found: $DIR"; exit 1; }
DIR="$(cd "$DIR" && pwd -P)"

# choose devices
SEL=()
if [ $# -gt 0 ]; then
  for d in "$@"; do [ -n "$(ip_of "$d")" ] || { echo "Unknown device: $d"; exit 2; }; SEL+=("$d"); done
else
  for d in "${ORDER[@]}"; do [ -f "$DIR/$d.cfg" ] && SEL+=("$d"); done
fi
for d in "${SEL[@]}"; do [ -s "$DIR/$d.cfg" ] || { echo "Missing or empty backup: $DIR/$d.cfg"; exit 1; }; done
[ ${#SEL[@]} -gt 0 ] || { echo "No backups found in $DIR"; exit 1; }

MODE=merge; [ $REPLACE -eq 1 ] && MODE=replace
echo "Backup: $DIR"
echo "Devices: ${SEL[*]}"
echo "Router mode: $MODE$([ $REPLACE -eq 1 ] && echo '  (REPLACES the whole running config)')"
if [ $DRY -eq 1 ]; then
  for d in "${SEL[@]}"; do
    case $d in R*) kind="router, load+commit ($MODE)";; *) kind="host, rewrite /etc files";; esac
    reach="unreachable"; nc -z -G3 "$(ip_of "$d")" 22 >/dev/null 2>&1 && reach="reachable"
    echo "  would restore $d ($(ip_of "$d"), $reach): $(wc -l < "$DIR/$d.cfg" | tr -d ' ') lines, $kind"
  done
  echo "Dry run only - nothing changed."; exit 0
fi
if [ $YES -ne 1 ]; then
  read -r -p "Restore these devices now? [y/N] " a; [[ "$a" =~ ^[Yy]$ ]] || { echo "Cancelled."; exit 1; }
fi

SSH_OPTS=(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=10)
EXP="$(mktemp)"; CMDS="$(mktemp)"; LOG="$(mktemp)"; trap 'rm -f "$EXP" "$CMDS" "$LOG"' EXIT
# Small expect runner: logs in, sends each line of a command file, waits for the prompt,
# answers "[no]:" confirmations with "yes". Prints the session transcript.
cat > "$EXP" <<'EOF'
#!/usr/bin/expect -f
set host [lindex $argv 0]
set cmdfile [lindex $argv 1]
set timeout 40
log_user 1
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=10 cisco@$host
expect {
  "assword:" { send "cisco\r" }
  timeout { puts "LOGIN_TIMEOUT"; exit 2 }
  eof { puts "LOGIN_EOF"; exit 2 }
}
expect {
  -re {#\s*$} {}
  timeout { puts "NOPROMPT"; exit 2 }
  eof { puts "LOGIN_EOF"; exit 2 }
}
set f [open $cmdfile r]
while {[gets $f line] >= 0} {
  send "$line\r"
  expect {
    -re {\[no\]:\s*$} { send "yes\r"; exp_continue }
    -re {#\s*$} {}
    timeout { puts "CMD_TIMEOUT: $line"; exit 3 }
    eof { puts "SESSION_EOF"; exit 3 }
  }
}
send "exit\r"
expect eof
EOF
chmod +x "$EXP"

# run_xr <ip> : runs $CMDS on the router (retrying flaky logins), transcript in $LOG
run_xr() {
  local t
  for ((t=1;t<=4;t++)); do
    "$EXP" "$1" "$CMDS" 2>&1 | tr -d '\r' > "$LOG"
    grep -qE 'LOGIN_|NOPROMPT|CMD_TIMEOUT|SESSION_EOF' "$LOG" || return 0
    sleep 5
  done
  return 1
}

restore_router() {  # name ip
  local name=$1 ip=$2 rpath="harddisk:/restore-$1.cfg" commit="commit" why
  [ "$MODE" = replace ] && commit="commit replace"
  sshpass -p "$PASS" scp -O "${SSH_OPTS[@]}" "$DIR/$name.cfg" "$USER_NAME@$ip:$rpath" >/dev/null 2>&1 || { echo "FAIL could not copy file to router"; return 1; }
  # pass 1: validate only (load, then abort - nothing is committed)
  printf 'terminal length 0\nconfigure terminal\nload %s\nabort\n' "$rpath" > "$CMDS"
  run_xr "$ip" || { echo "FAIL login problems (validation)"; return 1; }
  if ! grep -q 'bytes parsed' "$LOG" || grep -q '^%' "$LOG"; then
    why="$(grep -m1 '^%' "$LOG")"; echo "FAIL config did not load cleanly ${why:+- $why}"; return 1
  fi
  # pass 2: load + commit, then remove the uploaded file
  printf 'terminal length 0\nconfigure terminal\nload %s\n%s\nend\ndelete /noprompt %s\n' "$rpath" "$commit" "$rpath" > "$CMDS"
  run_xr "$ip" || { echo "FAIL login problems (commit)"; return 1; }
  if grep -qiE 'failed|^%' "$LOG"; then why="$(grep -m1 -iE 'failed|^%' "$LOG")"; echo "FAIL commit error - $why"; return 1; fi
  if grep -q 'No configuration changes' "$LOG"; then echo "OK (already matches, no changes needed)"; else echo "OK"; fi
}

restore_host() {  # name ip
  local name=$1 ip=$2 f sect tmp ok=1 pre
  tmp="$(mktemp -d)"
  awk -v d="$tmp" '/^##### /{n=$2; gsub("/","_",n); out=d"/"n; blank=0; next} out{ if ($0=="") blank++; else { for(;blank>0;blank--) print "" > out; print > out } }' "$DIR/$name.cfg"
  # find a way to write as root on the host
  pre="$(sshpass -p "$PASS" ssh "${SSH_OPTS[@]}" "$USER_NAME@$ip" 'if [ "$(id -u)" = 0 ]; then echo root; elif sudo -n true 2>/dev/null; then echo "sudo -n"; elif doas -n true 2>/dev/null; then echo "doas -n"; else echo none; fi' 2>/dev/null)"
  if [ -z "$pre" ] || [ "$pre" = none ]; then echo "FAIL no root/sudo/doas on host"; rm -rf "$tmp"; return 1; fi
  [ "$pre" = root ] && pre=""
  for f in /etc/hostname /etc/hosts /etc/network/interfaces; do
    sect="$tmp/$(echo "$f" | tr '/' '_')"
    [ -s "$sect" ] || { echo "FAIL section $f missing in backup"; rm -rf "$tmp"; return 1; }
    sshpass -p "$PASS" ssh "${SSH_OPTS[@]}" "$USER_NAME@$ip" "$pre tee $f >/dev/null" < "$sect" 2>/dev/null || ok=0
  done
  [ $ok -eq 1 ] && sshpass -p "$PASS" ssh "${SSH_OPTS[@]}" "$USER_NAME@$ip" "$pre hostname -F /etc/hostname; command -v lbu >/dev/null 2>&1 && $pre lbu commit >/dev/null 2>&1; true" 2>/dev/null
  rm -rf "$tmp"
  [ $ok -eq 1 ] && echo "OK (network changes apply after: rc-service networking restart)" || echo "FAIL writing files"
  [ $ok -eq 1 ]
}

pass=0; fail=0; failed=()
for d in "${SEL[@]}"; do
  ip="$(ip_of "$d")"; printf '  %-9s (%s) ... ' "$d" "$ip"
  for ((t=1;t<=3;t++)); do
    case $d in R*) msg="$(restore_router "$d" "$ip")";; *) msg="$(restore_host "$d" "$ip")";; esac
    rc=$?; [ $rc -eq 0 ] && break; sleep 5
  done
  echo "$msg"
  if [ $rc -eq 0 ]; then ((pass++)); else ((fail++)); failed+=("$d"); fi
done
echo "Done: $pass restored, $fail failed${failed:+ (${failed[*]})}"
[ $fail -eq 0 ]
