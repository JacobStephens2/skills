// Shared drawing library for the clarity cut. A scene loads cues/NN.js (window.NARRATION, generated from
// the narration's word timings) and then this file, and calls scene({...}). The renderer calls
// window.renderAt(t) per frame, t in seconds from the scene's start. Everything visible must be a pure
// function of t: no timers, no Math.random.

const clamp = (x, a = 0, b = 1) => Math.min(b, Math.max(a, x));
const lerp = (a, b, p) => a + (b - a) * p;
const ease = {
  linear: p => p,
  out: p => 1 - Math.pow(1 - p, 3),
  inOut: p => (p < .5 ? 4 * p * p * p : 1 - Math.pow(-2 * p + 2, 3) / 2),
  back: p => { const c = 1.4; return 1 + (c + 1) * Math.pow(p - 1, 3) + c * Math.pow(p - 1, 2); },
};
// Eased progress of a segment that starts at `start` and lasts `dur` seconds.
const prog = (t, start, dur, fn = ease.out) => fn(clamp((t - start) / dur));

// Start time (scene seconds) of the nth occurrence of a narration word, matched lowercase without
// punctuation ("pull", "it's"). Add `offset` to lead it slightly (negative) — never land late.
function cue(word, nth = 1, offset = 0) {
  const hits = window.NARRATION.words.filter(w => w[0] === word.toLowerCase());
  if (hits.length < nth) throw new Error(`cue: "${word}" #${nth} not in narration ${window.NARRATION.scene}`);
  return hits[nth - 1][1] + offset;
}

const $ = sel => document.querySelector(sel);
const $$ = sel => [...document.querySelectorAll(sel)];

function fadeUp(el, p, dy = 24, dx = 0) {
  el.style.opacity = p;
  el.style.transform = `translate(${dx * (1 - p)}px, ${dy * (1 - p)}px)`;
}
function pop(el, p) {
  el.style.opacity = clamp(p * 3);
  el.style.transform = `scale(${lerp(.85, 1, ease.back(clamp(p)))})`;
}
function show(el, on) { el.style.opacity = on ? 1 : 0; }
function typeText(el, text, p, cursor = true) {
  const n = Math.round(text.length * clamp(p));
  el.textContent = text.slice(0, n);
  if (cursor && p > 0 && p < 1) el.insertAdjacentHTML('beforeend', '<span style="background:#E8EAEE;color:#0F1115">&nbsp;</span>');
}
function drawPath(el, p) {
  const len = el.getTotalLength();
  el.style.strokeDasharray = `${len} ${len}`;
  el.style.strokeDashoffset = len * (1 - clamp(p));
}
function along(el, p) { return el.getPointAtLength(el.getTotalLength() * clamp(p)); }
// Signal the active element: full colour and weight when on, receding grey when off (colour, not arrows).
function dimTo(el, p, min = .28) { el.style.opacity = lerp(min, 1, clamp(p)); }

function chrome({ index, total, eyebrow, kicker }) {
  document.getElementById('stage').insertAdjacentHTML('beforeend', `
    <div id="eyebrow">${kicker ? `<small>${kicker}</small>` : ''}${eyebrow}</div>
    <div id="brand">${window.BRAND || ''}<span>${index}/${total}</span></div>`);
}

// Register the scene. Duration comes from the narration (lead + voice + hold).
// Content fades in over 0.3 s and out over the last 0.25 s.
function scene({ index, total = window.TOTAL_SCENES || 1, eyebrow, kicker = '', setup = () => {}, render }) {
  const duration = window.NARRATION.length;
  window.SCENE = { duration, ready: false };
  document.fonts.ready.then(() => {
    chrome({ index, total, eyebrow, kicker });
    setup();
    window.renderAt = t => {
      const outP = 1 - prog(t, duration - .25, .25, ease.linear);
      document.getElementById('content').style.opacity = Math.min(prog(t, 0, .3), outP);
      render(t);
    };
    window.renderAt(0);
    window.SCENE.ready = true;
  });
}
