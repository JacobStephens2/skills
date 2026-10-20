# Explainer video: rules and gotchas

## Research to reuse

Six cited notes, written for the [thirdshift](https://github.com/JacobStephens2/thirdshift) videos, under [`docs/research/`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/). The first five apply to any product, and each ends in checkable rules:

- [`explainer-video-clarity.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-video-clarity.md):
  - narration at 160–185 wpm, spoken rather than printed as a script;
  - 2–3 word labels beside what they name;
  - one idea per beat, and terms before use;
  - one colour plus one shape per actor;
  - swimlanes, signalling with colour rather than arrows;
  - captions as a toggleable track.
- [`explainer-video-music.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-video-music.md): music only where there's no narration, or as a bed at least 20 dB below the voice; −16 LUFS, true peak −1 dBTP; ElevenLabs music terms.
- [`explainer-video-audiences.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-video-audiences.md): executive cuts versus engineer cuts. Executive cuts give the answer first, cite no speed numbers, speak one limit, end on a low-commitment call to action and keep claims FTC-safe.
- [`explainer-video-marketing.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-video-marketing.md): sound-off feeds with burned-in text, about 25 s, in 16:9 plus 4:5. YouTube files a square-or-taller video under 3 min as a Short.
- [`explainer-video-tutorial.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-video-tutorial.md): procedural video. Preview the end state, put chapters on sub-goals, show **real output** and end each chapter on a still output frame.
- [`explainer-newcomer-concepts.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-newcomer-concepts.md): thirdshift's own terms and misconceptions, as a model for the product-specific note a new video needs.

## Scenes and timing

- **Word-synced.** Scenes read `cues/NN.js` (`window.NARRATION`) and time everything with `cue('word', nth, offset)`. `cue()` throws on a missing word, which catches script edits. Cue words are normalised as in `gen_cues.py`, so a script change (e.g. "thirdshift" → "thirdshift's") breaks the scenes that cue on that word.
- **Pure render.** `render(t)` sets every property from `t` alone. `style.css` disables CSS transitions globally, and scenes use no timers or `Math.random`.
- **Retrofitting sync onto an un-cued scene:**
  - A piecewise time warp maps narration word times onto the scene's own beat times. A uniform stretch drifts, and viewers notice, for example when a dot reaches a step before the narrator names it.
  - A warp keeps the order of the beats, so first reorder the scene to match the script.
- **Real output** comes from real logs, published stderr, and read-only commands run now; terminal panels replay it with `term.js`.
  - If the typed command differs from the run that produced the output, caption the panel "real output from …".
  - Mark steps whose output wasn't captured "output not shown".
  - Strip personal data (emails, tokens) before capture.
- **Literal reading.** Read each visual literally: striking through "no daemon" says there *is* one, so strike through only "daemon". An arrow from A to C labelled "blocked by" reads as "A is blocked by C"; label the target instead ("C blocked by A, B").
- **Text sizes at 1080p:**
  - Labels: at least 28 px for executives and 24 px for engineers.
  - Terminal: 24 px mono, about 118 columns in 1700 px.
  - Contrast: at least 4.5:1. Receded elements dim to about 0.45–0.65 opacity, which keeps their text above that contrast.

## Narration (ElevenLabs)

- **Key:** `ELEVENLABS_API_KEY` stays in the environment, injected by a secrets wrapper where one exists; never print it. Secret managers sometimes return 503/504: retry up to 4 times with a 10 s sleep.
- **Starter tier** refuses `mp3_44100_192`; `tts.py` asks for `mp3_44100_128`. Check quota at `/v1/user/subscription`.
- **eleven_v4** largely ignores `voice_settings.speed`. The default voice, Matilda (`XrExE9yKIg1WjnnlVkGX`), reads at about 135–145 wpm, below the 160–185 the research suggests, and pauses at every colon. Plan length at 140 wpm, and cut words or colons to shorten.
- Write numbers and initialisms the way they should be spoken ("six sixty-three", "T D D"). Add each one to `build.py`'s `CAPTION_FIXES` so the captions show the written form, and add a spoken phrase whose full stop isn't a sentence end ("a.m. Eastern") to `NO_BREAK`.

## Assembly beyond `build.py`

For cuts that need their own ffmpeg, such as a marketing cut with a music bed:

- **ffmpeg concat** resolves list paths relative to the list file, so write absolute paths.
- **Dynamic volume:** `volume='if(lt(t,X),0.05,0.2)':eval=frame` takes linear gains, not dB strings.
- **Silent cuts:** add a silent AAC track (`anullsrc`); feeds handle it better than no audio track.
- **Captions:** Chrome loads a `<track>` only over http, so serve the folder (`python3 -m http.server`). A server from an earlier session may already hold the port and serve another folder: if a new file returns 404, serve on a fresh port.
- **Scrubbing:** libx264 puts a keyframe about every 8 s, so a local player scrubs in coarse jumps. For a scrub copy, re-encode with `-c:v libx264 -g 15 -keyint_min 15 -sc_threshold 0 -c:a copy`: a keyframe every 0.5 s, at about twice the size.
- **Exit codes:** in `cmd | grep`, the pipeline takes grep's exit code. Use `set -o pipefail`, or check that the output file exists.
- **zsh:** an unmatched glob is an error that aborts an `&&` chain (e.g. `rm -rf review/*` on an empty folder). Use `find dir -type f -delete`.
