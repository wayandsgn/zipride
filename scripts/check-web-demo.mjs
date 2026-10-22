import assert from 'node:assert/strict';
import { mkdir, writeFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';

// The browser dependency is installed in the runner's temporary directory.
const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const base = process.env.DEMO_URL || 'http://127.0.0.1:8080/zipride/';
const output = 'app/screenshots/web';
await mkdir(output, { recursive: true });
const browser = await chromium.launch({ channel: 'chrome' });
const errors = [];
const page = await browser.newPage({ viewport: { width: 1440, height: 1000 }, reducedMotion: 'reduce' });
page.on('pageerror', error => errors.push(error.message));
page.setDefaultTimeout(45000);

async function readyApp() {
  const app = page.frameLocator('#app-frame');
  await app.locator('flutter-view').waitFor();
  await app.locator('#loading').waitFor({ state: 'detached' });
  const accessibility = app.locator('flt-semantics-placeholder');
  if (await accessibility.count()) await accessibility.evaluate(node => node.click());
  await app.getByRole('button', { name: 'Para onde?', exact: true }).waitFor();
  return app;
}

try {
  await page.goto(base);
  let app = await readyApp();
  assert.equal(await page.title(), 'Zipride — Demonstração interativa');
  await page.screenshot({ path: `${output}/01-desktop.png`, fullPage: true });

  await app.getByRole('button', { name: 'Para onde?', exact: true }).click();
  await app.getByRole('textbox').fill('rodoviaria');
  await app.getByRole('button', { name: /Rodoviária/ }).first().click();
  await app.getByRole('button', { name: /Escolher Zipride/ }).waitFor();
  await page.screenshot({ path: `${output}/02-destino.png`, fullPage: true });

  await page.getByRole('button', { name: 'Reiniciar', exact: true }).click();
  app = await readyApp();
  assert.equal(await app.getByRole('button', { name: /Escolher Zipride/ }).count(), 0);

  // A clipboard-denied browser must still expose a usable share link.
  await page.context().clearPermissions();
  await page.getByRole('button', { name: /Copiar link/ }).click();
  const copied = await page.locator('#feedback').textContent();
  if (!copied.includes('Link copiado')) {
    await page.getByRole('dialog').waitFor();
    assert.equal(await page.locator('#share-url').inputValue(), base);
    await page.getByRole('button', { name: 'Fechar', exact: true }).click();
  }

  for (const [width, height] of [[375, 812], [768, 1024], [1024, 768]]) {
    await page.setViewportSize({ width, height });
    await page.getByRole('link', { name: /Experimentar agora/ }).click();
    await page.locator('#app-frame').scrollIntoViewIfNeeded();
    await app.getByRole('button', { name: 'Para onde?', exact: true }).waitFor();
    assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), `Horizontal overflow at ${width}px`);
    await page.screenshot({ path: `${output}/03-width-${width}.png`, fullPage: true });
  }
  assert.deepEqual(errors, [], 'Unhandled browser errors');
  console.log('Web demo passed: release app, destination search, ride selection, reset, sharing, and 4 viewport sizes.');
} catch (error) {
  await page.screenshot({ path: `${output}/failure.png`, fullPage: true });
  await writeFile(`${output}/failure-dom.html`, await page.content());
  const appFrame = page.frames().find(frame => frame.url().includes('/app/'));
  if (appFrame) await writeFile(`${output}/failure-app.html`, await appFrame.content());
  throw error;
} finally {
  await browser.close();
}
