#!/usr/bin/env bash
# Coding agent on a disposable machine — one command, start to diff.
#
# Credentials are read from the environment, or from files in your home
# directory. They are never printed, never written into this repo, and only
# ever travel to the sandbox over the API.
#
#   ANTHROPIC_API_KEY   or  ~/.anthropic-key    (required)
#   ANTHROPIC_BASE_URL  or  ~/.anthropic-url    (optional — gateway/proxy)
#   PillDrops:              `pilldrops login`   (required)
#
# Usage:
#   bash run.sh
#   REPO=https://github.com/you/repo TASK="fix the failing tests" bash run.sh
set -euo pipefail

REPO="${REPO:-https://github.com/octocat/Hello-World}"
TASK="${TASK:-add a CONTRIBUTING.md that explains how to open a pull request}"
WAIT_SECS="${WAIT_SECS:-900}"

# ── credentials (env wins, else file) ────────────────────────────────────────
if [ -z "${ANTHROPIC_API_KEY:-}" ] && [ -f "$HOME/.anthropic-key" ]; then
  ANTHROPIC_API_KEY="$(tr -d '[:space:]' < "$HOME/.anthropic-key")"
fi
if [ -z "${ANTHROPIC_BASE_URL:-}" ] && [ -f "$HOME/.anthropic-url" ]; then
  ANTHROPIC_BASE_URL="$(tr -d '[:space:]' < "$HOME/.anthropic-url")"
fi
: "${ANTHROPIC_BASE_URL:=}"

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "!! No Anthropic credential. export ANTHROPIC_API_KEY=… or write ~/.anthropic-key" >&2
  exit 2
fi
pilldrops whoami >/dev/null 2>&1 || { echo "!! run: pilldrops login" >&2; exit 2; }

echo "── credentials"
echo "   anthropic : ${#ANTHROPIC_API_KEY} chars, starts ${ANTHROPIC_API_KEY:0:6}…"
echo "   endpoint  : ${ANTHROPIC_BASE_URL:-api.anthropic.com (default)}"
echo "   pilldrops : $(pilldrops whoami 2>/dev/null | head -1)"
echo
echo "── repo: $REPO"
echo "── task: $TASK"

# ── sandbox ──────────────────────────────────────────────────────────────────
# IS_SANDBOX=1 lets Claude Code use --dangerously-skip-permissions as root —
# true here by construction: the box is a disposable microVM.
ENV_ARGS=(--env "ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY" --env "IS_SANDBOX=1")
if [ -n "$ANTHROPIC_BASE_URL" ]; then
  # gateways want Bearer; direct api.anthropic.com uses x-api-key. Send both.
  ENV_ARGS+=(--env "ANTHROPIC_BASE_URL=$ANTHROPIC_BASE_URL"
             --env "ANTHROPIC_AUTH_TOKEN=$ANTHROPIC_API_KEY")
fi

echo
echo "── creating sandbox"
ID=$(pilldrops --json sandbox create --template claude --vcpu 2 --mem 2048 \
      --timeout 3600 "${ENV_ARGS[@]}" \
     | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')
echo "   $ID"
trap 'echo; echo "── cleanup"; pilldrops sandbox rm "$ID" >/dev/null 2>&1 && echo "destroyed $ID"' EXIT

echo "── cloning"
pilldrops exec "$ID" --timeout 120 -- git clone --depth 1 "$REPO" /root/work
pilldrops exec "$ID" -- sh -c 'cd /root/work && git config user.email agent@example.com && git config user.name agent'

# --detach is essential: a blocking exec dies at the control plane's ~150s
# node-request timeout, and real agent runs take minutes.
echo "── starting the agent (detached)"
pilldrops exec "$ID" --detach -- sh -c \
  "cd /root/work && claude --dangerously-skip-permissions -p '$TASK' > /root/agent.log 2>&1; echo \$? > /root/agent.done"

echo "── waiting (polling; up to ${WAIT_SECS}s)"
START=$(date +%s)
while :; do
  sleep 10
  CODE=$(pilldrops exec "$ID" -- sh -c 'cat /root/agent.done 2>/dev/null || true' 2>/dev/null | tr -d '[:space:]')
  ELAPSED=$(( $(date +%s) - START ))
  if [ -n "$CODE" ]; then echo "   agent finished after ${ELAPSED}s (exit $CODE)"; break; fi
  if [ "$ELAPSED" -ge "$WAIT_SECS" ]; then echo "   !! still running after ${ELAPSED}s — showing what we have"; break; fi
  printf '   …%ss\n' "$ELAPSED"
done

echo
echo "── agent output (tail)"
pilldrops exec "$ID" -- sh -c 'tail -c 1200 /root/agent.log 2>/dev/null || echo "(no log)"'

echo
echo "── what changed in the repo"
pilldrops exec "$ID" -- sh -c 'cd /root/work && git status --short && echo "--- diffstat ---" && git diff --stat && git status --porcelain | head'

echo
echo "── pulling the result back to ./repo-fixed"
rm -rf ./repo-fixed
pilldrops cp "$ID:/root/work" ./repo-fixed >/dev/null 2>&1 || echo "   (download skipped)"
[ -d ./repo-fixed ] && echo "   ls: $(ls ./repo-fixed | tr '\n' ' ')"
