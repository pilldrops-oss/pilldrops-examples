// Browser automation: scrape Hacker News titles with Playwright.
// The `playwright` template has Chromium pre-baked — no 300 MB download,
// the browser is just there.
//
//   export PILLDROPS_API_KEY=sfc_...
//   npm install @pilldrops/sdk
//   node index.mjs
import { Sandbox } from '@pilldrops/sdk'

const sb = await Sandbox.create({ template: 'playwright' })
try {
  // upload paths are relative to the sandbox workspace
  await sb.upload('./scrape.js', 'scrape.js')
  const r = await sb.run('node scrape.js', '', 120)
  console.log(r.stdout)
} finally {
  await sb.kill()
}
