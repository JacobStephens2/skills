# What makes a short narrated animated explainer maximally clear

Research date: 2026-10-19. Researched for the [thirdshift](https://github.com/JacobStephens2/thirdshift) explainer videos, then generalised.

**Question.** For a 60–120 s narrated animated explainer aimed at developers meeting a product for the first time, what does the primary literature establish about multimedia design, narration pace, captions, diagram conventions and accessibility?

**Method.** Instructional claims come from Mayer's own chapters, read in full text: [ch. 12](https://edtechuvic.ca/wp-content/uploads/sites/11/2022/09/principles-for-reducing-extraneous-processing-in-multimedia-learning-coherence-signaling-redundancy-spatial-contiguity-and-temporal-contiguity-principles.pdf) and [ch. 13](https://edtechuvic.ca/edci337/wp-content/uploads/sites/11/2022/09/principles-for-managing-essential-processing-in-multimedia-learning-segmenting-pre-training-and-modality-principles.pdf) of the 2014 *Cambridge Handbook of Multimedia Learning*. Wiley, Springer and APA PsycNet returned 403, so a few magnitudes come from Mayer's later restatement or publisher abstracts at Crossref; that is said inline. Pacing is from the [Guo, Kim & Rubin 2014](https://up.csail.mit.edu/other-pubs/las2014-pguo-engagement.pdf) PDF ([DOI](https://doi.org/10.1145/2556325.2566239)). Accessibility text is verbatim from [WCAG 2.2](https://www.w3.org/TR/WCAG22/) (2024-12-12), its Understanding notes, the [WebVTT spec](https://www.w3.org/TR/webvtt1/) and [MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/track); diagram claims from [Tversky et al. 2002](https://doi.org/10.1006/ijhc.1017) (IJHCS 57, 247–262) and [OMG BPMN 2.0.2](https://www.omg.org/spec/BPMN/2.0.2/PDF).

**Out of scope.** The script and storyboard themselves; render tooling; A/B testing; localisation; live media.

## TL;DR

- Narrate, don't print the script: modality holds in 53/61 tests (*d* = 0.76), while graphics + narration + full on-screen text costs 16/16 tests (*d* = 0.86). But **2–3 words beside the part of the graphic they name reverse that penalty** (retention *d* = 0.47, 0.70).
- Captions are a legal requirement and not what redundancy warns about: a toggleable `<track kind="captions">` satisfies WCAG and stays out of hearing viewers' way.
- ~160–185 wpm. Guo measured 48–254 wpm over 862 edX videos (mean 156, sd 31), engagement rising with rate; BBC caps comfortable caption reading at 160–180.
- One idea per beat, 8–10 s of speech — Mayer's own segment size. His *d* = 0.79 is for **learner-paced** segments, so a linear video doesn't inherit it: scrub bar, no autoplay.
- Spreading colour along the flow beats arrows (*d* = 0.75 vs −0.03, same study); over-signalling measured *d* = −0.03. Keep motion schematic (Tversky).

## 1. Mayer's principles, with numbers

Mayer publishes two conflicting sets. The per-principle evidence tables in the 2014 Handbook are used here; the one-sentence list in [Mayer 2017](https://api.crossref.org/works/10.1111/jcal.12197) gives spatial contiguity *d* = 0.79 where the tables give 1.10, so don't mix them.

[Ch. 12](https://edtechuvic.ca/wp-content/uploads/sites/11/2022/09/principles-for-reducing-extraneous-processing-in-multimedia-learning-coherence-signaling-redundancy-spatial-contiguity-and-temporal-contiguity-principles.pdf): coherence 23/23, *d* = 0.86; signaling 24/28, *d* = 0.41 (verbal 0.50, visual 0.36); redundancy 16/16, *d* = 0.86; spatial contiguity 22/22, *d* = 1.10; temporal contiguity 9/9, *d* = 1.22. [Ch. 13](https://edtechuvic.ca/edci337/wp-content/uploads/sites/11/2022/09/principles-for-managing-essential-processing-in-multimedia-learning-segmenting-pre-training-and-modality-principles.pdf): segmenting 10/10, *d* = 0.79; pre-training 13/16, *d* = 0.75; modality 53/61, *d* = 0.76. [Ch. 14](https://www.cambridge.org/core/product/3841340D8AD820C26DBCD39AE664BCEC) (social cues; from the publisher abstract, not the chapter body): personalization 14/17, *d* = 0.79; voice 5/6, *d* = 0.74; image *d* = 0.20.

**Segment size.** Mayer breaks "the 140-second narrated animation on lightning into 16 segments, each lasting about 10 seconds", prescribing that "each verbal segment be short – involving 8–10 seconds of speech concerning one main event" (ch. 13). All 10 rows of his table used click-to-continue, and he says "further research is needed to disentangle" pacing from chunking — so a linear video borrows the beat, not the *d*.

**Pre-training** is knowing "the names and characteristics of the main concepts" first: name the product's core nouns before explaining them.

**Signaling.** Boucheix & Lowe (2010): "spreading-color cues aided performance across a variety of transfer tests (*d* = 0.75) but arrow cues did not (*d* = −0.03)". Boucheix et al. (2013): cues emphasising "a progressive path" beat cues highlighting "a sequence of individual entities" (*d* = 1.42 vs 0.21). Transient label recolouring worked (*d* = 0.74); arrows and spotlighting were erratic (0.24, 0.04, −0.07). Signaling helps low-knowledge learners and complex displays, and works "sparingly rather than excessively" (all ch. 12).

### When redundancy does NOT apply

Mayer states it outright: "the redundancy effect can be eliminated or even reversed when the learners are experienced, the on-screen text is short, or the material lacks graphics" (ch. 12).

- **Short anchored keywords.** [Mayer & Johnson 2008](https://doi.org/10.1037/0022-0663.100.2.380) printed "a key word or phrase printed next to the corresponding part of the graphic"; the redundant group won on retention (*d* = 0.47, 0.70) with no transfer difference (0.04, 0.15). Design detail — 16 slides, ~8–10 s each, 2–3 words — via [ERIC EJ796353](https://eric.ed.gov/?id=EJ796353); magnitudes from ch. 12, not the article.
- **No graphics.** Adesope & Nesbit's meta-analysis, as reported by Mayer: *d* = 0.24 without graphics, *d* = 0.06 with a concurrent animation.
- **Non-native speakers.** [Lee & Mayer 2018](https://api.crossref.org/works/10.1002/acp.3436): subtitles beat narration alone on a 16-min English lesson, "in contrast to the *redundancy effect*"; Mayer now names a subtitle principle ([2020](https://doi.org/10.1007/s11423-020-09749-6) — search snippets only, **flagged**). But in [Mayer, Lee & Peebles 2014](https://api.crossref.org/works/10.1002/acp.3050) captions on a *fast-paced* 9-min lesson "did not improve performance by non-native English speakers". So subtitles help at a moderate pace; the 2018 magnitudes aren't public.
- **Learner-paced or slow presentation.** Established for *modality*, not redundancy — that effect vanished when self-paced (Tabbers et al. 2004) and reversed for long verbal segments (ch. 13). **Flagged as extrapolation.**
- **Expertise.** "Low-experience learners produced a redundancy effect but high-experience learners did not" (Kalyuga et al., via ch. 12). Developers are domain-expert but product-novice, so assume it applies.
- **Deaf and hard-of-hearing viewers.** **No primary source found.** Captions for DHH viewers rest on WCAG, not on Mayer.

## 2. Narration and scene pace

[Guo et al. 2014](https://up.csail.mit.edu/other-pubs/las2014-pguo-engagement.pdf) analysed 6,902,358 sessions over 862 videos and 127,839 students. "Median engagement time is at most 6 minutes, regardless of total video length", and sessions followed by a problem attempt fell 56% / 48% / 43% / 41% / 31% across the 0–3, 3–6, 6–9, 9–12 and 12–40 min buckets. Rate, measured from subtitles: "Speaking rates range from 48 to 254 words per minute (mean = 156 wpm, sd = 31 wpm)", and "within a particular length range, engagement usually increases (up to 2x) with speaking rate". **No correlation coefficient or p-value is reported for rate** — citing "a correlation" over-claims. They reject the 160-wpm folk rule as a 1967 recommendation for live lectures, warn rate "is merely a surface feature that correlates with enthusiasm", and advise cutting filler words "because students can always pause the video".

The ceiling comes from caption reading: [BBC Subtitle Guidelines 1.2.5](https://www.bbc.co.uk/accessibility/forproducts/guides/subtitles/) §4.1 cites "the recommended rate of 160-180 words per minute", and [BBC R&D's 24-video study](https://www.bbc.co.uk/rd/blog/2015-09-how-fast-should-subtitles-be) across 90–230 wpm found "230WPM being 'too fast', 115WPM 'too slow' and 175WPM about right". Measured conversation is faster — 196 wpm overall, 164 turn-wise ([Yuan, Liberman & Cieri 2006](https://www.ldc.upenn.edu/sites/default/files/interspeech2006-towards-integrated-understanding.pdf)) — so **the familiar "150 wpm conversational" figure is unverified folklore**. No standards body publishes an optimal narration wpm.

**Scene pacing: no primary research establishes seconds per idea or hold-after-motion** (flagged); pause length has never been the manipulated variable in segmenting studies. The nearest hard numbers are caption dwell floors — BBC's "minimum period of around 0.3 seconds per word (e.g. 1.2 seconds for a 4-word subtitle)" and a 1 s inter-cue gap; [Netflix](https://partnerhelp.netflixstudios.com/hc/en-us/articles/215758617) sets 5/6 s minimum and 7 s maximum per cue.

## 3. Captions alongside narration

The concerns separate because WCAG counts both forms: "Closed Captions are equivalents that can be turned on and off with some players"; "Open Captions are any captions that cannot be turned off"; "Captions should not obscure or obstruct relevant information in the video" ([glossary](https://www.w3.org/TR/WCAG22/#dfn-captions)). [W3C WAI](https://www.w3.org/WAI/media/av/captions/) recommends neither, noting only that "most are 'closed captions'", and warns that "automatically-generated captions do not meet user needs or accessibility requirements, unless they are confirmed to be fully accurate".

A closed WebVTT track is therefore off by default for hearing viewers (no redundancy penalty), restylable, and available to DHH and second-language viewers (§1). Mayer & Johnson's short burned-in words are a different artefact — diagram labels, not the transcript — so both coexist. Burning in the transcript would combine the full redundancy penalty with that obstruction risk.

## 4. Diagram conventions

[Tversky et al. 2002](https://doi.org/10.1006/ijhc.1017) is the sceptical primary source:

> **Congruence Principle:** The structure and content of the external representation should correspond to the desired structure and content of the internal representation.
> **Apprehension Principle:** The structure and content of the external representation should be readily and accurately perceived and comprehended.

Their verdict: "the research on the efficacy of animated over static graphics is not encouraging". Prescriptions, verbatim: "animations must be slow and clear enough for observers to perceive movements, changes, and their timing"; "animations should lean toward the schematic and away from the realistic, an inclination that does not come naturally to many programmers, who delight in graphic richness and realism"; "It also may mean annotation, using arrows or highlighting or other devices to direct attention to the critical changes". Since "animations are fleeting, they disappear", viewer control matters: "Stopping, starting and replaying an animation can allow reinspection."

Swimlanes have a normative owner but no experiment cited here (**flagged**): [BPMN 2.0.2](https://www.omg.org/spec/BPMN/2.0.2/PDF) defines "A Swimlane is a graphical container for partitioning a set of activities from other activities" — one lane per actor, such as user / product / agent / GitHub. Colour per actor is constrained by [WCAG 1.4.1 Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html) (A): "Color is not used as the only visual means of conveying information… or distinguishing a visual element", so each actor needs a shape or word as well as a hue. On legends, spatial contiguity (*d* = 1.10) argues for labelling parts in place rather than making the viewer span to a key.

## 5. Accessibility

Verbatim from [WCAG 2.2](https://www.w3.org/TR/WCAG22/).

- **1.2.2 Captions (Prerecorded), A:** "Captions are provided for all prerecorded audio content in synchronized media, except when the media is a media alternative for text and is clearly labeled as such." The exception needs the page to already carry the whole content in text, so an explainer that adds anything needs captions. **1.2.1** doesn't apply: a narrated animation is synchronized media.
- **1.2.3, A** (alternative for time-based media *or* audio description) and **1.2.5, AA** ("Audio description is provided for all prerecorded video content in synchronized media"). The lever is glossary Note 3 — "Where all of the video information is already provided in existing audio, no additional audio description is necessary" — while Note 1 includes on-screen text in what description must cover. A script that speaks every label and state change satisfies both with no AD track; "as you can see here" fails.
- **1.4.3 Contrast (Minimum), AA:** 4.5:1 for text, 3:1 for large scale, "at least 18 point or 14 point bold", which Understanding converts to "approximately 18.5px and 24px". **Flagged:** Understanding 1.4.3 never mentions video, so applying it to burned-in labels via the *image of text* definition is inference. Same flag for **1.4.11** (3:1 for "parts of graphics required to understand the content"). Native `<video controls>` falls under the user-agent exception.
- **2.3.1 Three Flashes, A:** nothing may flash "more than three times in any one second period, or the flash is below the general flash and red flash thresholds". Non-interference: failing it breaks the whole page.
- **2.2.2 Pause, Stop, Hide, A:** a mechanism is needed for motion that "(1) starts automatically, (2) lasts more than five seconds, and (3) is presented in parallel with other content". The conditions are conjunctive, and Understanding glosses "starts automatically" as "not the direct result of a user's intentional activation", so click-to-play sidesteps it. **1.4.2** bites at 3 s of autoplaying audio; not autoplaying clears both. **1.4.7** is audio-only in scope, **2.3.3** page-interaction animation only.

**WebVTT** ([CR Draft, 2026-05-20](https://www.w3.org/TR/webvtt1/) — re-verify before citing the date): a `WEBVTT` header, blank-line-separated blocks, timings `hh:mm:ss.ttt --> hh:mm:ss.ttt` with three millisecond digits and non-decreasing starts, optional `line`/`position`/`align`/`size` settings, payload markup (`<v Name>`, `<c.class>`, `<b>/<i>/<u>`), and `STYLE` blocks of `::cue` CSS before the first cue:

```
WEBVTT

00:01.000 --> 00:04.000
Never drink liquid nitrogen.
```

**`<track>`** ([MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/track)): `kind` takes `subtitles` (the default; "sound is available but not understood"), `captions` ("sound is unavailable or not clearly audible", including sound effects and speaker identification), `descriptions`, `chapters`, `metadata`. `srclang` must be a BCP 47 tag, `label` is what the browser lists, `default` goes on one track only. A same-language explainer wants `kind="captions"`.

## Rules for a 60–120 s explainer

1. **Narration at 160–185 wpm** (words ÷ speaking time) — Guo's engagement-rising range, BBC's 160–180 band, BBC R&D's "about right" of 175 (§2).
2. **Narrate; never put the script on screen.** Modality *d* = 0.76; redundancy *d* = 0.86 (§1).
3. **On-screen text is 2–3 words anchored beside the thing it names**, never a transcript. Retention *d* = 0.47/0.70; spatial contiguity *d* = 1.10 (§1).
4. **One idea per beat, 8–10 s of speech each** — 7–14 beats at 60–120 s (§1).
5. **Hold the frame still after each motion, then cut.** No measured hold exists (flagged); use ~0.3 s per word, minimum 1.2 s, no label under 5/6 s (§2).
6. **Introduce every term on screen and in narration before the narration uses it** — the product's core nouns. Pre-training *d* = 0.75 (§1).
7. **One colour *plus* one shape or word per actor**, labelled in place on first appearance rather than in a legend. WCAG 1.4.1; *d* = 1.10 (§4, §1).
8. **Lay the flow out in swimlanes, one per actor, with numbered steps.** BPMN 2.0.2; convention, not measured (§4).
9. **Signal the active element by spreading colour along the path, not arrows**, one at a time. *d* = 0.75 vs −0.03 (§1).
10. **Draw schematic, not realistic, and cut every decorative element.** Apprehension principle; coherence *d* = 0.86 (§1, §4).
11. **Write conversationally, in a human voice, not a synthetic one.** Personalization *d* = 0.79; voice *d* = 0.74 (§1).
12. **Script the narration to speak every on-screen label, number and state change.** Satisfies 1.2.3/1.2.5 with no audio-description track (§5).
13. **Ship a hand-corrected `<track kind="captions" srclang="en" label="English">`, not burned-in captions** (§3, §5).
14. **Do not autoplay; use `<video controls>` with a scrub bar.** Clears 2.2.2 and 1.4.2, and gives the stop/replay control Tversky and learner-paced segmenting ask for (§1, §4, §5).
15. **Check contrast and flash before shipping:** 4.5:1 for small labels, 3:1 at ≥24px (or ≥18.5px bold) and for meaningful graphics, no more than three flashes per second (§5).
