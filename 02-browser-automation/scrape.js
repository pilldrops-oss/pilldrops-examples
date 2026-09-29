// Runs INSIDE the sandbox, where Playwright + Chromium are preinstalled.
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('https://news.ycombinator.com');
  const titles = await page.locator('.titleline > a').allInnerTexts();
  console.log(titles.slice(0, 10).join('\n'));
  await browser.close();
})();
