const { chromium } = require('playwright');
(async () => { const b = await chromium.launch(); const p = await b.newPage();
  const svg = require('fs').readFileSync(process.argv[2], 'utf8').replace(/width="[\d.]+cm" height="[\d.]+cm"/, 'width="4800" height="640"');
  await p.setViewportSize({ width: 4800, height: 640 }); await p.setContent(`<html><body style="margin:0">${svg}</body></html>`);
  await p.screenshot({ path: process.argv[3] }); await b.close(); })();
