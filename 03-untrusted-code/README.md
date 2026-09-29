# 03 — Untrusted user code

Your product runs code your users (or your model) wrote. A container is a
shared kernel with extra steps; a PillDrops sandbox is a microVM with its own
kernel — a hardware boundary per run. Caps on vCPU, memory, and wall-clock are
enforced server-side, so a hostile payload can burn its own box and nothing
else.

```bash
export PILLDROPS_API_KEY=sfc_...
python main.py
```

Expected output: `verdict: OK` and `sum of squares: 285`.

Full guide: `/guides/untrusted-code` on your PillDrops server
