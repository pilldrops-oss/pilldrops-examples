# PillDrops examples

Runnable examples for [PillDrops](https://github.com/pilldrops-oss/pilldrops),
the self-hosted engine for disposable computers for AI agents. Every sandbox is
a hardware-isolated microVM (own kernel, filesystem, network) that boots in
about a second and can host apps on a preview URL.

## Setup (once)

```bash
# Your PillDrops server and its key (see the engine's README, Quick start)
export PILLDROPS_API_URL=http://localhost:8080
export PILLDROPS_API_KEY=$(cat /var/lib/sandboxd/bootstrap.key)

# Python examples
pip install pilldrops

# JavaScript examples
npm install @pilldrops/sdk
```

Already using the CLI? `pilldrops login` stores a credential that the SDKs
pick up automatically — no env var needed.

## Examples

| # | Example | Shows | Run |
|---|---------|-------|-----|
| 01 | [Code interpreter](01-code-interpreter/) | Upload a CSV, run model-written pandas, download the chart | `python main.py` |
| 02 | [Browser automation](02-browser-automation/) | Scrape a page with Playwright — Chromium pre-baked in the template | `node index.mjs` |
| 03 | [Untrusted code](03-untrusted-code/) | Run user-submitted code behind a hardware boundary with CPU/RAM/time caps | `python main.py` |
| 04 | [Coding agent](04-coding-agent/) | Give Claude Code a real machine: clone a repo, let it work, pull the diff | `python main.py` |
| 05 | [App preview](05-app-preview/) | Boot a Next.js dev server and get a public, shareable URL | `python main.py` |
| 06 | [Evals at scale](06-evals-at-scale/) | Fan out one sandbox per rollout — clean state every time | `python main.py` |
| 07 | [MCP for agents](07-mcp-for-agents/) | Let Claude / Cursor drive sandboxes directly — one line | README |
| 08 | [CLI tour](08-cli-tour/) | The whole journey from the terminal: create → exec → preview → history | `bash tour.sh` |

## The 30-second version

```python
from pilldrops import Sandbox

with Sandbox.create(template="python-3.11") as sb:
    print(sb.run("python -c 'print(2 + 2)'").stdout)   # 4
```

## Links

- [The engine](https://github.com/pilldrops-oss/pilldrops) — run your own server
- `/docs` on your server — the interactive API reference, every endpoint runnable in the browser
- `/guides` on your server — step-by-step walkthroughs, one per use case
- SDKs: [Python](https://github.com/pilldrops-oss/pilldrops-python) ·
  [JavaScript/TypeScript](https://github.com/pilldrops-oss/pilldrops-js) ·
  [CLI](https://github.com/pilldrops-oss/pilldrops-cli)

## License

MIT — use these however you like.
