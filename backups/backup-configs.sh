#!/usr/bin/env bash
# Back up configs from all lab devices to a local, timestamped folder.
#
#   Routers R1-R6  (198.18.1.11-16)  -> show running-config
#   Hosts alpine-1..6 (198.18.1.21-26) -> /etc/hostname, /etc/hosts, /etc/network/interfaces
#
# Usage:  ./backups/backup-configs.sh [output_dir]
# Output: <output_dir>/<YYYYmmdd-HHMMSS>/<device>.cfg   (default: ./backups)
#         <output_dir>/latest -> most recent run
# Requires: sshpass, ssh, and VPN connectivity to 198.18.1.0/24.
# Read-only on the devices. Lab-only credentials (cisco/cisco).

set -u
USER_NAME="cisco"
PASS="cisco"
RETRIES=4

ROUTERS=("R1:198.18.1.11" "R2:198.18.1.12" "R3:198.18.1.13" "R4:198.18.1.14" "R5:198.18.1.15" "R6:198.18.1.16")
HOSTS=("alpine-1:198.18.1.21" "alpine-2:198.18.1.22" "alpine-3:198.18.1.23" "alpine-4:198.18.1.24" "alpine-5:198.18.1.25" "alpine-6:198.18.1.26")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_ROOT="${1:-$SCRIPT_DIR}"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$OUT_ROOT/$STAMP"

command -v sshpass >/dev/null 2>&1 || { echo "sshpass not found (brew install sshpass)"; exit 1; }
mkdir -p "$OUT" || exit 1

SSH_OPTS=(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=10)

# run_cmd <ip> <command>  -> prints output to stdout, returns non-zero on failure
run_cmd() {
  sshpass -p "$PASS" ssh "${SSH_OPTS[@]}" "$USER_NAME@$1" "$2" 2>/dev/null
}

ok=0; fail=0; failed=()

backup_router() {
  local name=$1 ip=$2 tmp
  tmp="$(mktemp)"
  for ((t=1; t<=RETRIES; t++)); do
    run_cmd "$ip" "show running-config" > "$tmp"
    # a complete XR config ends with a line containing only "end"
    if tail -n 3 "$tmp" | tr -d '\r' | grep -qx "end"; then
      # drop the volatile timestamp/banner lines so repeated backups diff cleanly
      tr -d '\r' < "$tmp" | grep -vE '^(Mon|Tue|Wed|Thu|Fri|Sat|Sun) [A-Z][a-z]{2} +[0-9]+ [0-9:.]+ [A-Z]+$' > "$OUT/$name.cfg"
      rm -f "$tmp"; return 0
    fi
    sleep 5
  done
  rm -f "$tmp"; return 1
}

backup_host() {
  local name=$1 ip=$2 tmp
  tmp="$(mktemp)"
  for ((t=1; t<=RETRIES; t++)); do
    run_cmd "$ip" 'for f in /etc/hostname /etc/hosts /etc/network/interfaces; do echo "##### $f"; cat $f; echo; done' > "$tmp"
    if grep -q '##### /etc/network/interfaces' "$tmp" && grep -q 'iface' "$tmp"; then
      tr -d '\r' < "$tmp" > "$OUT/$name.cfg"; rm -f "$tmp"; return 0
    fi
    sleep 3
  done
  rm -f "$tmp"; return 1
}

echo "Backing up to: $OUT"
for d in "${ROUTERS[@]}"; do
  n=${d%%:*}; ip=${d##*:}
  if backup_router "$n" "$ip"; then echo "  OK    $n ($ip)  $(wc -l < "$OUT/$n.cfg" | tr -d ' ') lines"; ((ok++)); else echo "  FAIL  $n ($ip)"; ((fail++)); failed+=("$n"); fi
done
for d in "${HOSTS[@]}"; do
  n=${d%%:*}; ip=${d##*:}
  if backup_host "$n" "$ip"; then echo "  OK    $n ($ip)"; ((ok++)); else echo "  FAIL  $n ($ip)"; ((fail++)); failed+=("$n"); fi
done

ln -sfn "$STAMP" "$OUT_ROOT/latest"
echo "Done: $ok ok, $fail failed${failed:+ (${failed[*]})}"
[ "$fail" -eq 0 ]
