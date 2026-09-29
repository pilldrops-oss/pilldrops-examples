# 01 — Code interpreter

The classic loop behind ChatGPT-style data analysis: your model writes pandas,
PillDrops runs it in an isolated microVM, you pull the chart back out. Nothing
the model writes ever touches your servers.

```bash
export PILLDROPS_API_KEY=sfc_...
python main.py
```

Expected output: a stats table, then `→ ./results/chart.png`.

Resources: 2 vCPU · 1 GB, well under a minute. Full guide: `/guides/code-interpreter` on your PillDrops server
