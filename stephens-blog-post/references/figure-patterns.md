# Live-figure patterns

The rule: run the real tool. These are the recipes that worked for the reference post
([The Diagram Is Not the Model](https://stephens.page/blog/the-diagram-is-not-the-model/)).
All are no-build-step, loaded from a CDN at runtime, themed with the site's CSS
variables, and degrade gracefully.

## Theming any library output with the site palette

Read tokens at render time so light/dark and the manual toggle both work:

```js
function cssVar(n){ return getComputedStyle(document.documentElement).getPropertyValue(n).trim(); }
```

Tokens available: `--ink --brand --brand-ink --muted --surface --soft --rule --code-bg
--bar-bg` (from `theme.css`), plus any page-local ones you add (the reference post adds
`--diff-add-bg --diff-add-ink`).

Install ONE theme observer that re-renders every library figure on theme change:

```js
new MutationObserver(onThemeChange).observe(document.documentElement,
  { attributes:true, attributeFilter:['data-theme'] });
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', onThemeChange);
```

`onThemeChange` should re-run each library's render (guarded on "is it loaded yet").
For SVG output you can also theme purely in CSS by scoping selectors to the container
and letting CSS beat SVG presentation attributes - see Graphviz below.

Always honor `prefers-reduced-motion` for any CSS/JS animation.

## Mermaid (in-browser, jsdelivr)

```js
import('https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs')
  .then(m => window.__onMermaid(m.default)).catch(()=>{ /* keep fallback */ });
```

Init with `securityLevel:'strict'`, `theme:'base'`, and `themeVariables` mapped from
`cssVar(...)`. Render with `MM.render(id, src).then(o => container.innerHTML = o.svg)`.
Catch parse errors and show them (this is what makes an editable Mermaid box a real
demonstration). Fallback: a hand-drawn inline `<svg>` of the expected output.

Good uses: the diff figure (before/after + "edit it yourself" textarea), and any
"model serialized to Mermaid source, then rendered" projection.

## React Flow (in-browser, esm.sh, click-to-load)

Heavy (~400 KB React + RF), so gate behind a button. React duplication breaks hooks -
pin one React version and let esm.sh dedupe:

```js
Promise.all([
  import('https://esm.sh/react@18.3.1'),
  import('https://esm.sh/react-dom@18.3.1/client'),
  import('https://esm.sh/@xyflow/react@12.3.5?deps=react@18.3.1,react-dom@18.3.1'),
  loadRFStyles()   // inject <link> to the RF stylesheet, await onload
]).then(...)
```

Gotchas learned the hard way:
- **The stylesheet is mandatory.** Without `@xyflow/react/dist/style.css` nodes are not
  `position:absolute` and stack vertically. Load it from esm.sh (same host as the
  modules) and `await` its `onload` before mounting.
- **Set `sourcePosition:'right'` / `targetPosition:'left'`** on nodes for left-to-right
  flow, or edges render as little loops.
- **`fitView` may not fire before nodes are measured** in headless; also size the graph
  to fit at scale 1 (small nodes, tight spacing) so it is correct even if fitView no-ops.
- **Drive state through `useEffect`, not from click closures**, or rapid clicks read a
  stale value. Advance = `setStage(s => ...)`; a `useEffect([stage, themeTick])` repaints.
- No JSX (no build step): alias `h = React.createElement`.

Use for the "live floor view": nodes colored by run state, only the active edge animated.

## XState (in-browser, esm.sh)

```js
import('https://esm.sh/xstate@5.18.2').then(m => window.__onXState(m)).catch(()=>window.__xsFailed());
```

`createMachine` / `createActor` / `actor.start()` / `actor.subscribe(...)`. The teaching
move: build the **legal event buttons from the machine**, using
`snapshot.can({type:ev})` - so the UI can only offer transitions the machine allows.
Render the statechart with mermaid.js `stateDiagram-v2` and a `classDef active` on the
current state; fallback to state chips if mermaid is absent.

Single-source-of-truth trick (mirrors the post's thesis): keep one transition list and
generate BOTH the machine `on:{}` handlers AND the diagram from it.

## Graphviz DOT (in-browser, viz-js WASM, esm.sh)

```js
import('https://esm.sh/@viz-js/viz@3.11.0').then(m => m.instance()).then(viz => {
  container.appendChild(viz.renderSVGElement(dotSource));   // throws on parse error
});
```

~1.5 MB - lazy-load on IntersectionObserver when the figure nears the viewport. Theme
by scoping CSS to the output container (CSS overrides SVG presentation attributes):

```css
#gvout .node polygon, #gvout .node ellipse { stroke: var(--brand); fill: var(--soft); }
#gvout .node text { fill: var(--ink); }
#gvout .edge path { stroke: var(--muted); fill: none; }
#gvout .edge polygon { fill: var(--muted); stroke: var(--muted); }
```

This themes light/dark with NO re-render. Good use: a branching decision tree (DOT's
strength). Make the source an editable textarea for a live demonstration.

## D2 (via the Kroki service, not the browser)

D2's own renderer is a large Go/WASM binary; its npm browser build (`@terrastruct/d2`,
~8 MB) hung on compile in testing. So render D2 through **Kroki** and label it honestly.
Kroki has no CORS header, so use it as an `<img>` (no fetch needed):

```js
// URL = https://kroki.io/d2/svg/<base64url(zlib.deflate(source))>
// Bake the D2 theme into the source for light/dark and swap img.src on theme change:
//   vars: {d2-config: {theme-id: 0}}    // light
//   vars: {d2-config: {theme-id: 200}}  // dark
```

Precompute the two URLs (light/dark) in Python and hardcode them as `data-light` /
`data-dark` on the `<img>`; swap `src` in the theme observer. Fallback: the source
`<pre>` is always visible, so a reader still sees the real D2 text.

## Hand-built figures (only when no library exists)

The discrete-event simulation is hand-built inline SVG + vanilla JS: Poisson arrivals,
exponential service times, queues, capacity, a rework loop, utilization meters, a
bottleneck badge, and stat tiles (throughput, cycle time). Frame it with
predict-observe-explain. Keep the sim loop deterministic enough to test in Node with a
stub DOM (see `verification.md`). Respect `prefers-reduced-motion`.

## The quiz

A `.qz` block per question: a prompt, option buttons (`data-correct` on the right one),
and a hidden `.expl` explanation revealed on answer. Tally at the end with a merge-style
verdict ("Merge approved" / "Blocked: no merge until the quiz passes"), echoing Litt's
rule. This is the retention check; every post ends with one.
