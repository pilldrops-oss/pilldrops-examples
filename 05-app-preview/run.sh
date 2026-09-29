#!/usr/bin/env bash
# App preview: run a server in a sandbox, get a public URL you can share.
#
# Two rules the platform enforces:
#   1. Declare the port at create time (--port) — that's what the URL maps to.
#   2. Previews are PRIVATE by default. Pass --public for a tokenless,
#      shareable URL. (Port 8000 is taken by the sandbox's built-in terminal,
#      so give your app its own port.)
#
#   npm install -g @pilldrops/cli                      # once
#   pilldrops login --api-url <your server> --key <key> # once
#   bash run.sh
set -euo pipefail

PORT=3000

echo "── creating sandbox (public preview on :$PORT)"
ID=$(pilldrops --json sandbox create --template node-20 --port "$PORT" --public \
     | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')
echo "   $ID"

echo "── uploading the app"
pilldrops cp ./app.js "$ID:/root/app.js"

echo "── starting it (survives idle-pause/resume)"
pilldrops start "$ID" --port "$PORT" -- sh -c "cd /root && PORT=$PORT node app.js"

URL=$(pilldrops --json sandbox open "$ID" --print --port "$PORT" \
      | python3 -c 'import json,sys; print(json.load(sys.stdin)["url"])')
echo "── waiting for $URL"
for _ in $(seq 20); do
  if [ "$(curl -s -o /dev/null -w '%{http_code}' "$URL")" = "200" ]; then
    echo
    echo "   LIVE → $URL"
    echo "   (open it in a browser, or share the link)"
    echo
    echo "Tear it down when you're done:  pilldrops sandbox rm $ID"
    exit 0
  fi
  sleep 3
done

echo "!! never served — logs:"
pilldrops exec "$ID" -- cat /root/app.log || true
exit 1
