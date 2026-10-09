// Writes the icon SVGs and renders them to PNG with headless Chrome.
// Usage: node make.js <outDir> [webDir]   (needs Chrome on port 9222)
// With webDir, also writes the website icons and favicon there.
const fs = require('fs');
const path = require('path');
const mosque = require('./mosque.js');
const out = process.argv[2];
const webDir = process.argv[3];
const green = '#00695C';
const svg = (body, bg) => `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">${bg ? `<rect width="1024" height="1024" fill="${bg}"/>` : ''}${body}</svg>`;
const files = {
  // Full square: iOS, web, old Android. Mark fills ~70%.
  'icon.svg': svg(mosque('#FFFFFF', 1.05), green),
  // Android adaptive foreground (the generator insets it 16%), and web
  // maskable (mark inside the safe circle).
  'icon-foreground.svg': svg(mosque('#FFFFFF', 1.05)),
  'icon-maskable.svg': svg(mosque('#FFFFFF', 0.74), green),
  // Splash: green mark on white.
  'splash.svg': svg(mosque(green, 0.9)),
};
for (const [name, body] of Object.entries(files)) fs.writeFileSync(path.join(out, name), body);

async function open(url) {
  const t = await (await fetch('http://127.0.0.1:9222/json/new?' + encodeURIComponent(url), { method: 'PUT' })).json();
  const ws = new WebSocket(t.webSocketDebuggerUrl);
  await new Promise((r) => ws.addEventListener('open', r, { once: true }));
  let id = 0; const pending = new Map();
  ws.addEventListener('message', (e) => { const m = JSON.parse(e.data); if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); } });
  const send = (method, params = {}) => new Promise((r) => { const n = ++id; pending.set(n, r); ws.send(JSON.stringify({ id: n, method, params })); });
  return { send, close: async () => { ws.close(); await fetch('http://127.0.0.1:9222/json/close/' + t.id); } };
}
(async () => {
  // [svg, png, size]
  const jobs = Object.keys(files).map((name) => [name, path.join(out, name.replace(".svg", ".png")), 1024]);
  if (webDir) {
    for (const size of [192, 512]) {
      jobs.push(["icon.svg", path.join(webDir, "icons", "Icon-" + size + ".png"), size]);
      jobs.push(["icon-maskable.svg", path.join(webDir, "icons", "Icon-maskable-" + size + ".png"), size]);
    }
    jobs.push(["icon.svg", path.join(webDir, "favicon.png"), 64]);
  }
  for (const [name, png, size] of jobs) {
    const file = "file:///" + path.resolve(out, name).split(path.sep).join("/");
    const tab = await open("about:blank");
    await tab.send("Emulation.setDeviceMetricsOverride", { width: 1024, height: 1024, deviceScaleFactor: 1, mobile: false });
    await tab.send("Emulation.setDefaultBackgroundColorOverride", { color: { r: 0, g: 0, b: 0, a: 0 } });
    await tab.send("Page.enable");
    await tab.send("Page.navigate", { url: file });
    await new Promise((r) => setTimeout(r, 800));
    const shot = await tab.send("Page.captureScreenshot", { format: "png", clip: { x: 0, y: 0, width: 1024, height: 1024, scale: size / 1024 } });
    fs.writeFileSync(png, Buffer.from(shot.result.data, "base64"));
    await tab.close();
    console.log("rendered", png, size);
  }
})();
