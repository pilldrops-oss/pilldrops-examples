#!/usr/bin/env bash
# The whole PillDrops journey from a terminal, for real, in ~60 seconds.
# Creates a sandbox, runs code in it, moves files both ways, then cleans up.
#
#   npm install -g @pilldrops/cli                      # once
#   pilldrops login --api-url <your server> --key <key> # once
#   bash tour.sh
set -euo pipefail

say() { printf '\n\033[1m── %s\033[0m\n' "$1"; }

say "create a sandbox (warm pool: ~1s to running)"
ID=$(pilldrops --json sandbox create --template python-3.11 \
     | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')
echo "$ID"
trap 'echo; echo "── cleanup"; pilldrops sandbox rm "$ID" >/dev/null 2>&1 && echo "destroyed $ID"' EXIT

say "run code inside it"
pilldrops exec "$ID" -- python -c 'print("2 + 2 =", 2 + 2)'

say "push a file in"
echo "hello from your laptop" > /tmp/pd-tour-in.txt
pilldrops cp /tmp/pd-tour-in.txt "$ID:/root/in.txt"
pilldrops exec "$ID" -- cat /root/in.txt

say "let the sandbox produce something, pull it back"
pilldrops exec "$ID" -- sh -c 'python -c "print(sum(i*i for i in range(10)))" > /root/out.txt'
pilldrops cp "$ID:/root/out.txt" /tmp/pd-tour-out.txt
echo "downloaded: $(cat /tmp/pd-tour-out.txt)"

say "inspect it live"
pilldrops metrics "$ID" 2>/dev/null | head -3 || echo "(metrics need a moment on a fresh box)"

say "its history: duration and usage"
pilldrops history --limit 3 2>/dev/null | head -5

echo
echo "That's the whole loop. Public app previews: see ../05-app-preview."
echo "Agents: run \`pilldrops ai\` for the machine-readable command contract."
