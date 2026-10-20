// Render a scene with headless Chromium.
//   node render.mjs video 03          -> out/03.mp4 (1920x1080, 30 fps, H.264)
//   node render.mjs stills 03 [n]     -> stills/03-1.png .. 03-n.png, evenly spaced (default 5)
//   node render.mjs still 03 4.25     -> stills/03-at-4.25.png
import { chromium } from 'playwright';
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const FPS = 30;
const dir = path.dirname(fileURLToPath(import.meta.url));
const [mode, id, arg] = process.argv.slice(2);
if (!mode || !id) { console.error('usage: node render.mjs video|stills|still <NN> [n|t]'); process.exit(2); }

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1920, height: 1080 }, deviceScaleFactor: 1 });
const errors = [];
page.on('pageerror', e => errors.push(e.message));
page.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });
await page.goto('file://' + path.join(dir, 'scenes', `${id}.html`));
await page.waitForFunction(() => window.SCENE && window.SCENE.ready, null, { timeout: 20000 });
const duration = await page.evaluate(() => window.SCENE.duration);
const at = async t => { await page.evaluate(t => window.renderAt(t), t); return page.screenshot({ type: 'png' }); };
const fs = await import('node:fs');

if (mode === 'video' || mode === 'stretch' || mode === 'warp') {
  // stretch: `node render.mjs stretch 03 16.4 outdir` plays the scene's own timeline
  // slowed uniformly to last 16.4 s, written to <outdir>/03.mp4.
  // warp: `node render.mjs warp 03 warp.json outdir`, where warp.json is
  // {"length": 16.4, "anchors": [[real_t, scene_t], ...]} (increasing, from [0,0] to
  // [length, duration]); scene time is interpolated linearly between anchors.
  const w = mode === 'warp' ? JSON.parse(fs.readFileSync(arg, 'utf8')) : null;
  const target = mode === 'stretch' ? Number(arg) : w ? w.length : duration;
  const k = duration / target;
  const sceneTime = !w ? r => r * k : r => {
    const a = w.anchors;
    for (let i = 1; i < a.length; i++) if (r <= a[i][0]) return a[i - 1][1] + (a[i][1] - a[i - 1][1]) * (r - a[i - 1][0]) / (a[i][0] - a[i - 1][0]);
    return a[a.length - 1][1];
  };
  const outDir = mode === 'video' ? path.join(dir, 'out') : path.resolve(dir, process.argv[5] || 'out-slow');
  fs.mkdirSync(outDir, { recursive: true });
  const out = path.join(outDir, `${id}.mp4`);
  const ff = spawn('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-c:v', 'png', '-framerate', String(FPS), '-i', '-',
    '-c:v', 'libx264', '-preset', 'medium', '-crf', '18', '-pix_fmt', 'yuv420p', '-r', String(FPS), out], { stdio: ['pipe', 'inherit', 'inherit'] });
  const frames = Math.round(target * FPS);
  for (let f = 0; f < frames; f++) {
    const buf = await at(sceneTime(f / FPS));
    if (!ff.stdin.write(buf)) await new Promise(r => ff.stdin.once('drain', r));
  }
  ff.stdin.end();
  await new Promise((res, rej) => ff.on('close', c => (c === 0 ? res() : rej(new Error('ffmpeg exit ' + c)))));
  console.log(`${out} (${frames} frames, ${target}s)`);
} else if (mode === 'stills') {
  fs.mkdirSync(path.join(dir, 'stills'), { recursive: true });
  const n = Number(arg || 5);
  for (let i = 1; i <= n; i++) {
    const t = (duration * i) / (n + 1);
    const file = path.join(dir, 'stills', `${id}-${i}.png`);
    fs.writeFileSync(file, await at(t));
    console.log(`${file} t=${t.toFixed(2)}`);
  }
} else if (mode === 'still') {
  fs.mkdirSync(path.join(dir, 'stills'), { recursive: true });
  const t = Number(arg);
  const file = path.join(dir, 'stills', `${id}-at-${t}.png`);
  fs.writeFileSync(file, await at(t));
  console.log(file);
}
if (errors.length) console.error('PAGE ERRORS:\n' + errors.join('\n'));
await browser.close();
