# 08 — CLI tour

Everything the dashboard does, scriptable. Install once, log in once, then
sandboxes are a shell command away — which also means they're one
`subprocess.run` away from any agent.

```bash
npm install -g @pilldrops/cli
pilldrops login --api-url http://localhost:8080 --key "$PILLDROPS_API_KEY"
bash tour.sh
```

Agents: run `pilldrops ai` for the machine-readable contract of every command
(add `--json` anywhere for structured output).
