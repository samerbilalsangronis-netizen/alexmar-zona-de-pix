const { chromium } = require('playwright');
(async () => { const b = await chromium.launch(); const p = await b.newPage({ deviceScaleFactor: 2 });
  const fs = require('fs'); const svg = fs.readFileSync(process.argv[2], 'utf8');
  const m = svg.match(/width="(\d+)" height="(\d+)"/); const w = +m[1], h = +m[2];
  await p.setViewportSize({ width: w, height: h }); await p.setContent(`<html><body style="margin:0">${svg}</body></html>`);
  await p.screenshot({ path: process.argv[3], omitBackground: false }); await b.close(); })();
