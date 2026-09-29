# 02 — Browser automation

Agents that browse need Chromium, and Chromium needs a machine. The
`playwright` template boots with the browser and drivers installed — upload a
script, run it, read the result. Works the same when the script is written by
a model instead of committed to disk.

```bash
export PILLDROPS_API_KEY=sfc_...
npm install @pilldrops/sdk
node index.mjs
```

Expected output: the current top-10 Hacker News titles.

Full guide: `/guides/browser-automation` on your PillDrops server
