# Background music in a narrated explainer video

Research date: 2026-10-19. Researched for the [thirdshift](https://github.com/JacobStephens2/thirdshift) explainer videos, then generalised.

**Question.** Should a 60–120 s narrated animated explainer about a developer CLI use background music, and if so how loud, where, and generated how? Clarity is the top priority; narration comes from ElevenLabs TTS.

**Method.** Read directly: the Moreno & Mayer PDF (text via `pdftotext`), the EBU R 128 and R 128 s2 PDFs, W3C's WCAG 2.2 Understanding page, Apple's and Google's support pages, Crossref for citations, ElevenLabs' docs and `music-terms`. The ElevenLabs API was probed read-only (`GET /v1/user/subscription`, `GET /v1/models`) — no generation, no credits spent, key never printed.

**Out of scope.** Voice and script, composition aesthetics, captions, codec settings, the ElevenLabs Music Marketplace.

## TL;DR

- **Don't play music while the narration speaks.** A music loop over a narrated animation cut retention and transfer in both experiments of [Moreno & Mayer 2000](https://doi.org/10.1037/0022-0663.92.1.117); no condition in which it helped.
- **Sound effects differ from music.** Effects in one-to-one correspondence with a depicted event did no measurable harm; repetitive effects over unrelated events did (same paper).
- **If music appears, confine it to the non-narrated head and tail** — an inference from the auditory-overload mechanism, not a tested condition; I found no study comparing music *during* vs *between* narration.
- **Normative mix numbers exist** (§2, and the rules at the end). "YouTube normalizes to −14 LUFS" is **not** among them — it is absent from YouTube's own docs.
- **ElevenLabs generates instrumental music** (`POST /v1/music`, `force_instrumental: true`), but on Free through Pro plans the music terms grant commercial use "For Individual Use Only", and Free and Starter also bar streaming distribution — a licensing risk for a company video.

## 1. Learning-science evidence

### Moreno & Mayer 2000

Moreno, R., & Mayer, R. E. (2000). A coherence effect in multimedia learning: The case for minimizing irrelevant sounds in the design of multimedia instructional messages. *Journal of Educational Psychology, 92*(1), 117–125. [doi:10.1037/0022-0663.92.1.117](https://doi.org/10.1037/0022-0663.92.1.117). Two experiments, narrated animation (lightning; hydraulic brakes), four groups: narration only (N), + sounds (NS), + music (NM), + both (NSM).

**Experiment 1** (n = 75). Retention means N 11.05 (SD 2.78), NS 11.61 (3.88), NM 9.32 (3.20), NSM 6.26 (3.77); transfer 2.74 / 3.06 / 1.95 / 1.10. Music main effect: retention F(1,71) = 21.99, p < .0001 (7.65 vs 11.37); transfer F(1,71) = 17.65, p < .0001 (1.54 vs 2.84). Environmental sounds: **no** significant effect (p = .13, p = .43). Interaction p < .05, NSM worst.

**Experiment 2** (n = 78). Music *and* mechanical sounds both hurt: retention F(1,71) = 4.38 and 4.31; transfer F(1,71) = 4.09 and 6.84; all p < .05. Retention means N 3.95, NS 3.12, NM 3.11, NSM 2.45; transfer 5.55 / 3.06 / 3.33 / 3.40.

No Cohen's *d* is reported. **My own calculation** from Experiment 1: d ≈ 1.06 (retention), 0.95 (transfer) for music vs no music — derived, not published. (Also flagged: my PDF's OCR transposes the music/no-music means in the Experiment 2 text; the Table 2 group means above are the reliable read.)

**Boundary conditions.** Undergraduates with no domain knowledge, ~3-minute system-paced animations, no learner control or replay, music looping throughout. On the sounds difference: Experiment 1's seven natural sounds were "coordinated in one-to-one correspondence with a particular event or idea unit," while Experiment 2's two mechanical sounds repeated over unrelated events and "may have been too intrusive, arbitrary, and ambiguous." Conclusion: "the more relevant and integrated sounds are, the more they will help students' understanding."

### Later work

- Mayer's coherence principle generalizes it: exclude extraneous material. Handbook chapters reportedly give median effect sizes of d ≈ 0.97 (14 tests) and 1.32 (11 coherence tests) — **unverified**, secondary summaries only.
- Sundararajan, K., & Adesope, O. (2020). Keep it coherent: A meta-analysis of the seductive details effect. *Educational Psychology Review, 32*(3), 707–734. [doi:10.1007/s10648-020-09522-4](https://doi.org/10.1007/s10648-020-09522-4). Citation verified via Crossref; the overall **g ≈ −0.33** across 68 effects from 58 studies comes from a secondary summary (paywalled) — **unverified**. Music counts as a seductive detail.
- de la Mora Velasco, E., & Hirumi, A. (2020). The effects of background music on learning: A systematic review. *ETR&D, 68*(6), 2817–2837. [doi:10.1007/s11423-020-09783-4](https://doi.org/10.1007/s11423-020-09783-4). From the publisher's abstract: **30 studies, 2008–2018**, results "inconclusive," methods weak, "not all BM interventions are the same," few studies in *multimedia* learning. Circulating claims that it pins the harm on lyrics and volume are **not** in that abstract.

**Implication.** The direct evidence supports *no music under narration*; the review evidence is too inconclusive to license a "quiet bed is fine" exception. Intro/outro music is the defensible compromise, on mechanism rather than data.

## 2. Mixing practice from primary sources

- [**EBU R 128** (v5, Nov 2023)](https://tech.ebu.ch/docs/r/r128.pdf): target **−23.0 LUFS** (±1.0 LU where impractical, ±0.2 LU for QC), measured with an ITU-R BS.1770 meter including the equation (7) gating per Tech 3341; True Peak **must not exceed −1 dBTP** (±0.3 dB); measure "in its entirety, without emphasis on specific foreground elements such as speech, music or sound effects." Footnote 2: under **1 minute, Loudness Range (LRA) is not recommended**.
- [**EBU R 128 s2** (streaming)](https://tech.ebu.ch/docs/r/r128s2.pdf): stream unchanged at −23.0 LUFS, or, where adapted, a Distribution Loudness Level "in the range of **−20.0 to −16.0 LUFS**."
- [**Apple Podcasters audio requirements**](https://podcasters.apple.com/support/audio-requirements): "the overall loudness remains around **−16 dB LKFS**, with a +/− 1 dB tolerance" and "the true-peak value doesn't exceed **−1 dB FS**," per **ITU-R BS.1770-5**.
- [**YouTube upload encoding settings**](https://support.google.com/youtube/answer/1722171): AAC-LC/Opus, 48 kHz, 384 kbps stereo — **no loudness target anywhere on the page.** "−14 LUFS for YouTube" is folklore against YouTube's own docs (Spotify publishes −14 LUFS, for music).
- [**WCAG 2.2 SC 1.4.7**](https://www.w3.org/WAI/WCAG22/Understanding/low-or-no-background-audio.html) (AAA): "The background sounds are at least **20 decibels lower** than the foreground speech content," excepting "occasional sounds that last for only one or two seconds." Caveat: 1.4.7 covers prerecorded *audio-only* content, so it does not formally bind a video — but it is the only normative figure I found.
- **Ducking.** Torcoli, M., et al. (2019). *JAES, 67*(12), 1003–1011. [doi:10.17743/jaes.2019.0052](https://doi.org/10.17743/jaes.2019.0052). 22 listeners; minimum **10 LU** commentary-over-music, **15 LU** over ambience; non-experts wanted ~4 LU more than experts. **Flagged:** read from the abstract and repository summaries.
- **Folklore:** "music at −18 dB under voice," "duck by 6 dB," "−6 dB headroom" — none appear in the sources above.

## 3. ElevenLabs Music API and TTS sync

**Music** — [`POST https://api.elevenlabs.io/v1/music`](https://elevenlabs.io/docs/api-reference/music/compose). Body: `prompt` **or** `composition_plan` (mutually exclusive); `music_length_ms` 3000–600000 (prompt-only); `model_id` ∈ `music_v1` (API default) | `music_v2` | `music_v2_5`; **`force_instrumental`** (default false, prompt-only — "the song is guaranteed to be instrumental"); `seed` (plan-only); `sign_with_c2pa` (MP3 only). Query `output_format` defaults to `auto` → `mp3_44100_128` (v1) or `mp3_48000_192` (v2); PCM 8–48 kHz and Opus 48 kHz also offered; plan sections/chunks 3000–120000 ms each. **Discrepancy flagged:** the [capabilities page](https://elevenlabs.io/docs/capabilities/music) says "3 seconds to 5 minutes," MP3/WAV only, while the API reference allows 10 minutes and PCM/Opus.

**Licensing** — terms at [`elevenlabs.io/music-terms`](https://elevenlabs.io/music-terms), linked from `/service-specific-terms` (`/terms-of-use/music` 404s). Exhibit A: Free/Starter/Creator/Pro permit commercial use but "For Individual Use Only"; Scale caps at under 10 employees, Business under 50; media rights read "All online and offline commercial use permitted, except film, TV, radio, and Studio Games." Streaming distribution is prohibited on Free and Starter. Free requires attribution, other plans none. §2.2: "you retain any and all rights in and to your Input and Output"; §3.1 puts clearance on you; §2.1 bars prompts naming real artists/songs/labels. [Terms of Use](https://elevenlabs.io/terms-of-use) §1(c) restricts free accounts to non-commercial use.

**The account researched (read-only probe).** `GET /v1/user/subscription` → 200, `tier: "starter"`. `GET /v1/models` → 200, eleven TTS/STS models; `music_*` models are **not** listed there, yet music generation is available. On Starter that means "individual use only" terms — an awkward fit for a company product video. Check the tier the same way, and flag it for a human decision.

**Sync** — [`POST /v1/text-to-speech/{voice_id}/with-timestamps`](https://elevenlabs.io/docs/api-reference/text-to-speech/convert-with-timestamps) returns `audio_base64` plus `alignment` and `normalized_alignment`, each with equal-length `characters`, `character_start_times_seconds`, `character_end_times_seconds` — enough to drive animation cues off narration. Stitching: `previous_text`/`next_text` and `previous_request_ids`/`next_request_ids` (max 3 each; text fields ignored when the matching ids are sent). `enable_logging: false` disables request stitching (enterprise only); `seed` is best-effort.

## 4. The quiet code-generated sine/triangle chord loop

Better when licensing must be unambiguous (no plan tier, no individual-use question, no attribution, no C2PA), the build must be deterministic in CI, and level/fade/gating are set in code — so it is trivially silent under narration and rendered at a known loudness. Worse when audible for long: a synthetic drone sounds amateurish and, by the coherence mechanism, is as extraneous as produced music; it gives no arc for an intro sting, and naively summed oscillators risk beating and aliasing. Verdict: with music only in head and tail, the code loop is lower-risk; generated music pays off only if someone wants a real hook. **Flagged:** no study found comparing a synthesized drone against produced music.

## Rules for an explainer's audio

1. **No music and no sound effects while the narration is speaking** ([Moreno & Mayer 2000](https://doi.org/10.1037/0022-0663.92.1.117)).
2. **Music only in the non-narrated head and tail, ≤5 s total**, fully faded before the first narrated word.
3. **If a bed under narration survives review: ≥20 dB below the narration** ([WCAG 1.4.7](https://www.w3.org/WAI/WCAG22/Understanding/low-or-no-background-audio.html)) **and ≥10 LU below in loudness** ([Torcoli et al. 2019](https://doi.org/10.17743/jaes.2019.0052)) — never a "−6 dB" duck.
4. **Integrated loudness −16 LUFS ±1 LU**, gated per ITU-R BS.1770 ([Apple](https://podcasters.apple.com/support/audio-requirements); inside R 128 s2's −20…−16 streaming range).
5. **True peak ≤ −1 dBTP** ([EBU R 128](https://tech.ebu.ch/docs/r/r128.pdf)); verify with `ffmpeg -i out.wav -af ebur128=peak=true -f null -`.
6. **Don't gate on Loudness Range** — R 128 footnote 2: LRA is not recommended under 1 minute.
7. **A sound effect ships only in one-to-one correspondence with an on-screen event** (one tick per depicted keypress); no repeated UI stings, no transition whooshes (Moreno & Mayer, Exp 1 vs Exp 2).
8. **If generating music:** `POST /v1/music` with `force_instrumental: true`, `model_id: "music_v2_5"`, an exact `music_length_ms`, `output_format` `mp3_48000_192` or PCM — never leave lyrics possible.
9. **Clear the licence first:** check the tier (`GET /v1/user/subscription`); Free through Pro permit commercial use "For Individual Use Only", and Free and Starter bar streaming distribution ([music-terms](https://elevenlabs.io/music-terms)); confirm eligibility in writing or ship the code-generated loop.
10. **Render narration via `/with-timestamps`** and drive every visual cue from `character_end_times_seconds`; stitch segments with `previous_text`/`previous_request_ids` so joins don't drift.
