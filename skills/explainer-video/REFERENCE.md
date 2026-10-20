# Explainer video: rules and gotchas

## Research to reuse

Six cited notes, written for the [thirdshift](https://github.com/JacobStephens2/thirdshift) videos, under [`docs/research/`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/). The first five apply to any product; each ends in checkable rules:

- [`explainer-video-clarity.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-video-clarity.md): narration at 160–185 wpm; narrate rather than print the script; 2–3 word labels beside what they name; one idea per beat; terms before use; one colour plus one shape per actor; swimlanes; signal with colour, not arrows; captions as a toggleable track.
- [`explainer-video-music.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-video-music.md): no music under narration, or a bed at least 20 dB below the voice; −16 LUFS, true peak −1 dBTP; ElevenLabs music terms.
- [`explainer-video-audiences.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-video-audiences.md): executive cuts (answer first, no speed numbers, one spoken limit, a low-commitment call to action, FTC-safe claims) versus engineer cuts.
- [`explainer-video-marketing.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-video-marketing.md): sound-off feeds (burned-in text, about 25 s, 16:9 plus 4:5; YouTube treats square-or-taller under 3 min as a Short).
- [`explainer-video-tutorial.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-video-tutorial.md): procedural video (preview the end state, chapters on sub-goals, real output only, end each chapter on a still output frame).
- [`explainer-newcomer-concepts.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-newcomer-concepts.md): thirdshift's own terms and misconceptions, as a model for the product-specific note a new video needs.

## Scenes and timing

- **Word-synced.** Scenes read `cues/NN.js` (`window.NARRATION`) and time everything with `cue('word', nth, offset)`. Its offset leads by at most 0.3 s; `cue()` throws on a missing word, which catches script edits. Cue words are normalised as in `gen_cues.py`, so a script change (e.g. "thirdshift" → "thirdshift's") breaks the scenes that cue on it.
- **Pure render.** `render(t)` sets every property from `t`: no CSS transitions, timers or `Math.random`. `style.css` disables transitions globally.
- **Retrofitting sync onto an un-cued scene:** a piecewise time warp maps narration word times onto the scene's own beat times. A uniform stretch drifts; users notice when, say, a dot reaches a step before the narrator names it. Order matters: a warp can't reorder beats, so reorder the scene to match the script.
- **Real output.** Terminal panels (`term.js`) print only captured output: real logs, published stderr, and read-only commands run now. If the typed command differs from the run that produced the output, caption the panel "real output from …". Mark steps whose output wasn't captured "output not shown". Strip personal data (emails, tokens) before capture.
- **Semantics.** Read each visual literally. Striking through "no daemon" says there *is* one; strike only "daemon".
- **Text sizes at 1080p:** labels at least 28 px for executives, 24 px for engineers; terminal 24 px mono (about 118 columns in 1700 px); contrast at least 4.5:1. Receded elements dim to about 0.45–0.65 opacity, not lower, or their text fails contrast.

## Narration (ElevenLabs)

- **Key:** `ELEVENLABS_API_KEY` stays in the environment, injected by a secrets wrapper where one exists; never print it. Secret managers sometimes return 503/504: retry up to 4 times with a 10 s sleep.
- **Starter tier:** `mp3_44100_192` is refused, so use `mp3_44100_128`. Check quota at `/v1/user/subscription`.
- **eleven_v4** largely ignores `voice_settings.speed`: change pace by editing words, not speed. Default voice: Matilda, `XrExE9yKIg1WjnnlVkGX`. `previous_text`/`next_text` keep intonation continuous across separately generated lines.
- Spell out numbers the way they should be spoken ("six sixty-three").

## Assembly

- **ffmpeg concat** resolves list paths relative to the list file: write absolute paths.
- **Mono narration** into a stereo mix: `pan=stereo|c0=c0|c1=c0`, then `adelay` both channels.
- **Dynamic volume in ffmpeg:** `volume='if(lt(t,X),0.05,0.2)':eval=frame` takes linear gains, not dB strings.
- **Captions:** Chrome won't load a `<track>` from `file://`, so serve the folder (`python3 -m http.server`). Captions are off by default: no `default` attribute.
- **Pipelines:** `cmd | grep` hides a failing exit code. Use `set -o pipefail`, or check the output file exists.
- **zsh:** an unmatched glob is an error that aborts an `&&` chain (e.g. `rm -rf review/*` on an empty folder). Use `find dir -type f -delete`.
- **Marketing cuts:** add a silent AAC track (`anullsrc`) when there's no audio; feeds handle that better than none. Use `-movflags +faststart` for the web.

## Working with the user

- **New version, not replacement:** keep every earlier version and present the newest first.
- **Honest claims:** no speed or productivity numbers without a source, and nothing "free" when usage costs money. A proof point should be a real, dated artifact (an issue → PR) the viewer can open.
- **Before delivering, list what was checked and what wasn't.** Review uses stills, so no one has watched the video end to end with sound; say so.
