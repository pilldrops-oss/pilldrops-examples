"""Evals at scale: one sandbox per rollout — clean state every time.

No leaked files, no poisoned environment between runs: each rollout gets a
fresh microVM and throws it away. PillDrops is stress-tested at 1000
concurrent sandboxes; `pilldrops history` shows each run's duration and usage.

    export PILLDROPS_API_KEY=sfc_...
    python main.py
"""
from concurrent.futures import ThreadPoolExecutor
from pilldrops import Sandbox

ROLLOUTS = 8          # turn this up; 1000 concurrent is tested
WORKERS = 4

# A stand-in for your real eval: seed in, score out.
EVAL = """
import random, sys
random.seed({seed})
score = sum(random.random() for _ in range(1000)) / 1000
print(f"{{score:.4f}}")
"""


def rollout(seed: int) -> float:
    with Sandbox.create(template="python-3.11", timeout=120) as sb:
        r = sb.run(f"python - <<'EOF'\n{EVAL.format(seed=seed)}\nEOF", timeout=60)
        r.check()
        return float(r.stdout.strip())


with ThreadPoolExecutor(WORKERS) as ex:
    scores = list(ex.map(rollout, range(ROLLOUTS)))

print(f"rollouts: {len(scores)}")
print(f"mean score: {sum(scores) / len(scores):.4f}")
print("per-run usage: `pilldrops history` or the dashboard History page")
