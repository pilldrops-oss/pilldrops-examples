"""Untrusted code: run user-submitted code behind a hardware boundary.

Caps are enforced server-side (vCPU, memory, wall-clock). The context manager
destroys the sandbox on exit — nothing to clean up, nothing left behind.

    export PILLDROPS_API_KEY=sfc_...
    python main.py
"""
from pilldrops import Sandbox

# Imagine this arrived from your product's users. It could do anything.
USER_SUBMITTED = """
total = sum(i * i for i in range(10))
print("sum of squares:", total)
"""

with Sandbox.create(template="python-3.11",
                    vcpu=1, mem_mb=1024, timeout=60) as sb:
    sb.run("mkdir -p /work").check()
    r = sb.run(f"python - <<'EOF'\n{USER_SUBMITTED}\nEOF", timeout=30)

    if r.ok:
        print("verdict: OK")
        print(r.stdout)
    else:
        print(f"verdict: FAILED (exit {r.exit_code})")
        print(r.stderr)
# sandbox destroyed here — the microVM and everything in it is gone
