// A terminal that replays real CLI output, line by line, on narration cues.
// Every output line must be copied from captured/ (real output); never write output by hand.
//
//   const term = makeTerm(el, { rows: 14 });
//   const lines = [
//     { kind: 'cmd', text: 'thirdshift status', at: cue('status'), dur: 0.9 },   // typed after "$ " over dur s
//     { kind: 'out', text: 'build-host'     , at: cue('lists') },               // printed at once
//     { kind: 'cut', text: '··· 20 lines cut: waiting on CI', at: cue('watches') }, // a visible time jump
//     { kind: 'hl',  text: 'thirdshift: 01:22:56 PR … is merged', at: cue('merged') }, // printed and highlighted
//   ];
//   term.render(t, lines);   // in render(t): shows lines whose `at` <= t, newest at the bottom
//
// Lines longer than the terminal clip with an ellipsis, as the real stderr already does.
function makeTerm(el, { rows = 14, title = '' } = {}) {
  el.classList.add('tt');
  el.innerHTML = `${title ? `<div class="tt-bar"><i></i><i></i><i></i><span>${title}</span></div>` : ''}<div class="tt-body"></div>`;
  const body = el.querySelector('.tt-body');
  const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  return {
    render(t, lines) {
      const shown = [];
      for (const l of lines) {
        if (t < l.at) continue;
        if (l.kind === 'cmd') {
          const p = clamp((t - l.at) / (l.dur || 0.9));
          const n = Math.round(l.text.length * p);
          const cursor = p < 1 ? '<span class="tt-cur">&nbsp;</span>' : '';
          shown.push(`<div class="tt-l tt-cmd"><span class="tt-p">$</span> ${esc(l.text.slice(0, n))}${cursor}</div>`);
        } else {
          const age = clamp((t - l.at) / 0.25);
          shown.push(`<div class="tt-l tt-${l.kind}" style="opacity:${(0.3 + 0.7 * age).toFixed(2)}">${esc(l.text)}</div>`);
        }
      }
      body.innerHTML = shown.slice(-rows).join('');
    },
  };
}

document.head.insertAdjacentHTML('beforeend', `<style>
.tt { position: absolute; background: #0F1115; color: #E3E6EC; border-radius: 12px; overflow: hidden;
  box-shadow: 0 2px 6px rgba(0,0,0,.12), 0 12px 32px rgba(0,0,0,.10); }
.tt-bar { height: 44px; background: #1A1D23; display: flex; align-items: center; gap: 9px; padding: 0 18px;
  font: 500 20px/1 var(--f-mono); color: #8B93A3; }
.tt-bar i { width: 13px; height: 13px; border-radius: 50%; background: #3A3F4A; display: inline-block; }
.tt-bar span { margin-left: 12px; }
.tt-body { padding: 18px 24px; }
.tt-l { font: 400 24px/1.55 var(--f-mono); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.tt-cmd { color: #FFFFFF; font-weight: 600; }
.tt-p { color: #7FA7FF; }
.tt-out { color: #C9CED8; }
.tt-cut { color: #7D8594; font-style: italic; }
.tt-hl { color: #9BE9A8; font-weight: 600; }
.tt-cur { background: #E3E6EC; }
</style>`);
