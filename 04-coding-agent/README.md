# 04 — Coding agent on a disposable machine

Coding agents want to install packages, run tests, and execute what they just
wrote. Give them a real computer that isn't yours: clone the repo into a
sandbox, let the agent work with a long timeout, pull the result back, and
review the diff before anything merges.

```bash
bash run.sh
```

Point it anywhere:

```bash
REPO=https://github.com/you/your-repo TASK="fix the failing tests" bash run.sh
```

## Credentials

Resolved from the environment first, then from files in your home directory —
never stored in this repo:

| What | Env var | Fallback file |
|---|---|---|
| Anthropic key (required) | `ANTHROPIC_API_KEY` | `~/.anthropic-key` |
| Anthropic gateway (optional) | `ANTHROPIC_BASE_URL` | `~/.anthropic-url` |
| PillDrops | `PILLDROPS_API_KEY` | `pilldrops login` |

The script prints only a masked confirmation (length + first 6 chars), and the
Anthropic credential travels to the microVM via `env=` on sandbox create — it
is never written to a file or baked into an image.

## Why `--dangerously-skip-permissions` is fine here

That flag lets the agent act without prompting for each write. Normally that's
a bad idea — but the sandbox *is* the blast radius: a disposable microVM with
its own kernel and filesystem, holding a shallow clone and nothing else. That
is the entire reason to run agents this way.

Other agent templates: `codex`, `opencode`, `amp`.

Full guide: `/guides/coding-agents` on your PillDrops server
