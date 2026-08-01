# Verification protocol

Honest verification is required; Jacob will ask how you checked. The bar for a post
with live figures: **rendered and driven in a real browser engine, light and dark,
zero console errors, fallbacks tested.** "It should work" is not verification.

Use headless Chrome (`google-chrome` or `chromium`) where available. Put all temp
files in a session scratchpad, never in the site repo.

## 1. Static checks

```bash
# Extract the main inline <script> and syntax-check it
python3 -c "import re;open('fig.js','w').write(re.findall(r'<script>(.*?)</script>', open('index.html').read(), re.S)[-1])"
node --check fig.js

# Em-dash guard - MUST be 0
python3 -c "print('EM DASH:', open('index.html').read().count(chr(8212)))"

# Figure numbering is sequential and cross-refs match
grep -oE 'Fig\. [0-9]' index.html | sort -u
```

## 2. Render both themes, screenshot, and LOOK

Prefer serving the post over `http://127.0.0.1` so `/theme.css` and site assets resolve.
`file://` works for a first pass if you pass absolute paths carefully.

```bash
# From the post directory, or use the absolute path to index.html
google-chrome --headless=new --disable-gpu --no-sandbox --window-size=800,13000 \
  --screenshot=out.png --hide-scrollbars --virtual-time-budget=12000 \
  "http://127.0.0.1:8000/blog/<slug>/"
# Or, on the production checkout:
# "file:///var/www/stephens.page/blog/<slug>/index.html"
```

Dark mode: load with `data-theme="dark"` on `<html>` (local override or a small test
copy). Crop regions with PIL and actually read the screenshots - the validator catches
color, your eyes catch collisions, overflow, and diagonal layouts. (A real bug found
this way: React Flow nodes stacked vertically because its stylesheet was missing.)

## 3. Drive every interaction and assert

Append a harness `<script>` before `</body>` that clicks buttons / dispatches `input`
events / fires the sim, then writes results into a `<pre>` as JSON. Read it back with
`--dump-dom` and grep the JSON opening brace (`grep -oE 'OUT:\{[^<]*'`) - anchoring on
`{` avoids matching the harness source that the DOM dump also contains.

Assert the things that would silently be wrong:
- React Flow: node count, exactly one animated edge after N advances, rightmost node
  within the container (no overflow), `errors:[]`.
- XState: drive a legal path, confirm `snapshot.value` and that only legal buttons show.
- Graphviz: `#gvout svg` present, node count, no error text.
- D2 `<img>`: `naturalWidth > 0` (it actually loaded), src swaps on theme.

## 4. Test the CDN-outage fallbacks

Block a host with Chrome's resolver rules and confirm the figure degrades, not breaks:

```bash
google-chrome --headless=new --host-resolver-rules="MAP esm.sh ~NOTFOUND" ...   # RF/XState fall back
google-chrome --headless=new --host-resolver-rules="MAP cdn.jsdelivr.net ~NOTFOUND" ...   # mermaid falls back
```

Expect: hand-drawn SVG / state chips / message-plus-link, and still `errors:[]`.

## 5. Test pure logic in Node with a stub DOM

For a hand-built simulation, extract the script and `eval` it under a minimal stub
`document` / `requestAnimationFrame` / `performance` / `MutationObserver` /
`getComputedStyle`, then pump frames and assert steady-state numbers (throughput,
bottleneck, queue depth) against the closed-form arithmetic in the prose. This catches
model bugs far faster than the browser and lets you prove the figure matches the math.

## Notes / gotchas

- `--virtual-time-budget` pauses on pending network fetches; give big-download figures
  (React Flow ~400 KB, viz-js ~1.5 MB, D2 ~8 MB) generous budgets, or lazy/click-load.
- `--dump-dom` includes `<script>` source, so unique markers you emit will also appear
  as source text. Anchor greps on output-only substrings (a `{`, a digit).
- Bind any local http server to `127.0.0.1` only.
- Do not re-read a file immediately after editing just to confirm the edit; the tools
  error on failure. Re-read only to re-derive line numbers.
