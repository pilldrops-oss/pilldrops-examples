"""Code interpreter: upload a CSV, run model-written pandas, download the chart.

The code-interpreter-v1 template ships Python 3.11 with pandas, numpy, and
matplotlib preinstalled — nothing to install at runtime.

    export PILLDROPS_API_KEY=sfc_...   (or `pilldrops login` once)
    python main.py
"""
from pilldrops import Sandbox

# In a real app this string comes from your LLM ("write pandas code that…").
# Paths are relative to the sandbox workspace (commands run in /workspace).
ANALYSIS = """
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

df = pd.read_csv("data/sales.csv")
print(df.describe())

monthly = df.groupby("month", sort=False)["revenue"].sum()
monthly.plot(kind="bar", title="Monthly revenue")
plt.tight_layout()
plt.savefig("out/chart.png")
print("chart saved")
"""

with Sandbox.create(template="code-interpreter-v1", timeout=600) as sb:
    sb.run("mkdir -p out").check()
    sb.upload("./sales.csv", "data/sales.csv")

    r = sb.run(f"python - <<'EOF'\n{ANALYSIS}\nEOF", timeout=120)
    print(r.stdout)
    if not r.ok:
        raise SystemExit(f"analysis failed:\n{r.stderr}")

    sb.download("out", "./results")
    print("→ ./results/chart.png")
