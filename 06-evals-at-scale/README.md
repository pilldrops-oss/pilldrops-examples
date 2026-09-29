# 06 — Evals & RL rollouts at scale

Shared machines make evals lie: leftover files, cached deps, one rollout
poisoning the next. One sandbox per rollout fixes that — every run starts from
the same clean template, and usage is metered per second, so 100 short boxes
use about what 1 long one does.

```bash
export PILLDROPS_API_KEY=sfc_...
python main.py
```

Expected output: 8 scores and their mean. Turn `ROLLOUTS`/`WORKERS` up as far
as your plan's concurrency allows.

Full guide: `/guides/evals` on your PillDrops server
