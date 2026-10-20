---
name: explainer-video
description: Make narrated, animated explainer videos (product, architecture, tutorial, executive or marketing cuts) as HTML scenes rendered to MP4, with every animation synced to the narration's words. Use when the user wants an explainer, demo, walkthrough or promo video, or a new version of one.
---

# Explainer video

A local version of Anthropic's Explainer video maker template (`/claude-api managed-agents-onboard explainer-video-maker`), extended with narration. Scenes are HTML pages whose `render(t)` is a pure function of time. Headless Chromium screenshots each frame, and ffmpeg joins the frames, narration and music. Copy `templates/` into a fresh project directory (the scratchpad unless the user names one). The gotchas and rules referred to below are in [REFERENCE.md](REFERENCE.md).

Leading words: **sourced** (every claim traces to a line in the product's docs or code), **word-synced** (each element appears on the word that names it, or up to 0.3 s early), **real output** (terminal text is captured, never written by hand), and **new version** (a change is a copy, `vN` → `vN+1`; earlier versions stay).

## Steps

1. **Ground.** Read the source of truth: README, guide, site pages and code. List the claims the video will make, each with its file:line. *Done when* every planned claim has a source line, and the user has picked the audience (engineers, executives, new users, public).
2. **Research the audience** with the `research` skill, unless a matching note exists already (see REFERENCE.md, "Research to reuse"). *Done when* the note ends in checkable rules and a beat outline.
3. **Script** `narration.json`: one scene per idea, conversational, every on-screen label spoken. Re-check each sentence against its source; overclaiming hides in words like "never", "free" and "only". *Done when* each sentence is sourced and the total length fits the audience.
4. **Voice.** Generate per-scene audio with timestamps (`templates/tts.py`, with `ELEVENLABS_API_KEY` in the environment). Audition voices with the user on a new project. Then run `gen_cues.py` for `cues/NN.js` and `plan.json`. *Done when* every scene has audio, cues and a planned length.
5. **Harness.** Write `storyboard.md` (the rules plus a direction per scene) and adapt `style.css` and `lib.js` to the look (set `window.BRAND` for the corner wordmark). Render one throwaway scene to prove fonts, captions and timing. *Done when* a test still looks right.
6. **Build scenes** with background subagents: one per scene, or one per group sharing a continuous diagram. Each gets the storyboard, its cues, and the rule to render stills and check them with Read before rendering video. *Done when* every `out/NN.mp4` matches `plan.json` within 0.05 s.
7. **Review.** An independent subagent that hasn't seen the code judges stills of every scene against the source, and names at most one scene to fix plus any factual errors. Also check a frame of each new scene yourself. *Done when* the flagged fixes are made and no claim fails its source.
8. **Assemble** with `build.py`: concat, narration at each scene's lead, music only in the unnarrated head and tail, loudnorm to −16 LUFS, a WebVTT caption file, and a player page. Make a poster from the strongest frame. *Done when* loudness reads −16 ±1 LUFS and the player loads its captions over http.
9. **Present** the video in a served index page (one card per video, newest version first, captions off by default) and open it in the user's browser.

For a change to a finished video, make a **new version**: copy the project directory, change only what was asked, re-voice only the changed lines, and re-render the scenes whose cues or counters changed.
