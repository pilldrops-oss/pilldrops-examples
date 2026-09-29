# 07 — MCP: let your agent drive sandboxes itself

No SDK, no code. One line connects Claude (or Cursor, or any MCP client) to
your PillDrops server — then you just ask for things.

## Connect

```bash
# Remote: the control plane serves MCP at /mcp; no install
claude mcp add --transport http pilldrops https://<your server>/mcp \
  --header "Authorization: Bearer $PILLDROPS_API_KEY"

# Or local over stdio via the CLI
npm install -g @pilldrops/cli
pilldrops login --api-url <your server> --key <key>
claude mcp add pilldrops -- pilldrops mcp
```

## Then just ask, in plain language

> "Create a sandbox and run my test suite in it."

> "Spin up a Python sandbox, fetch this CSV, and tell me which month had the
> highest revenue."

> "Write a small Flask API for a todo list, run it in a sandbox, and give me
> the preview URL."

> "Show me the logs from the last sandbox and destroy it."

The server exposes the full toolkit: create / pause / resume / destroy
sandboxes, run commands, read & write files, start servers with public
preview URLs, logs, metrics, and usage.

## For CLI-driving agents

Hand your agent the CLI instead and have it run `pilldrops ai` first — it
prints the complete machine-readable command contract (workflows, JSON output,
exit codes, error→fix table) so the agent can operate everything itself.
