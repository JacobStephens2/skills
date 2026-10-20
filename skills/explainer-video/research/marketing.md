# A short marketing / launch video for thirdshift

Research date: 2026-10-19.

**Question.** How should a short, general marketing video for thirdshift be made for X, LinkedIn, YouTube and the website hero: what do the platforms require, how long should it be, how should it behave with sound off, and what can it truthfully claim?

**Method.** Platform specs are from each vendor's own docs, fetched directly: `docs.x.com`, `linkedin.com/help`, `support.google.com/youtube`, `developer.chrome.com`, `webkit.org`. **`help.x.com` and `business.x.com` return 403 to a non-browser client**, so X's consumer-side numbers are search-engine extracts of X-owned pages rather than pages read — marked **[unread-X]**, worth one human spot-check. Retention data is vendor-measured except Guo, Kim & Rubin 2014, read from the PDF; sentiment is from `survey.stackoverflow.co`. Product claims come only from this repository, read-only. **[vendor]** marks seller-funded data; **[inference]** marks my judgment.

**Out of scope.** Script wording, storyboard, render tooling, paid ad buying, thumbnails; the FTC substantiation analysis (reuse `explainer-video-audiences.md` §3 — not redone here); audio mixing numbers (`explainer-video-music.md`); the learning-science basis for narration and on-screen text (`explainer-video-clarity.md`).

## TL;DR

- **One 16:9 master plus one 4:5 covers everything.** LinkedIn organic accepts 1:2.4–2.4:1 and X 1:3–3:1, so a single 4:5 file is legal native video on both feeds; 16:9 serves the site and YouTube. 9:16 only pays if Shorts will be fed — and a square-or-taller YouTube upload is *automatically* reclassified as a Short.
- **Burn captions into the feed cuts; closed track on the site.** Both feeds take an SRT sidecar, but it is desktop-only on LinkedIn and an API-only two-step on X, and neither shows during muted autoplay.
- **The redundancy warning in `explainer-video-clarity.md` does not bind a muted cut**: with sound off, on-screen text is not a duplicate of a spoken channel, it *is* the only verbal channel — a boundary Mayer states, not a contradiction. **[inference]**
- **A "view" means nothing**: LinkedIn counts one at 2 s at 50% on screen, X the same **[unread-X]**, YouTube since 2026-08-24 at playback start. The decision window is Wistia's "nose", the first 2% of runtime **[vendor]**.
- **Lead with the overnight Run, not a capability claim.** `site/index.html:105` holds the only repo proof with two real numbers: issue #663 taken 00:21, pull request #665 merged 01:22, 12 October 2026.
- **Don't narrate the feed cut.** At 25 s with sound off narration buys nothing, and dropping it removes the music question entirely.

## 1. Platform specs for native video

| | Aspect ratio | Max length | Resolution / encode | Captions | Muted autoplay |
|---|---|---|---|---|---|
| **X** | hard 1:3–3:1; **[unread-X]** help page says 1:2.39–2.39:1 | API page 20 min; **[unread-X]** help page 140 s / 512 MB non-Premium | 32×32–1280×1024, ≤60 fps (help page ≤40), H.264 High, YUV 4:2:0 only, AAC-LC, progressive, no open GOP; rec. 1280×720 / 720×1280 / 720×720 at ≥5,000 kbps | SRT, API only: upload as `media_type: text/srt` + `media_category: subtitles`, then `POST /2/media/subtitles` | **unverified** — no X page I could read states it |
| **LinkedIn** | 1:2.4–2.4:1 (organic) | 15 min, min 3 s desktop, 5 GB | 256×144–4096×2304, 10–60 fps, 192 Kbps–30 Mbps | SRT sidecar required before posting, **desktop only** | **confirmed**: videos "may play automatically without sound as you scroll through your feed" |
| **YouTube** | "standard … on a computer is 16:9"; don't pre-pad vertical | 15 min default | 1080p = 1920×1080; MP4, H.264 High, closed GOP of half the frame rate, 4:2:0, AAC-LC 48 kHz, 8 Mbps at 1080p24–30 | SRT among accepted formats | n/a (not a feed) |
| **Shorts** | square or vertical | 3 min | 1080p max | same as YouTube | n/a |

Sources: X [best practices](https://docs.x.com/x-api/media/quickstart/best-practices), [initialize](https://docs.x.com/x-api/media/initialize-media-upload), [create subtitles](https://docs.x.com/x-api/media/create-media-subtitles); LinkedIn [a548372](https://www.linkedin.com/help/linkedin/answer/a548372), [a552177](https://www.linkedin.com/help/linkedin/answer/a552177/add-closed-captions-to-videos-on-linkedin), [a565326](https://www.linkedin.com/help/linkedin/answer/a565326) (its *ads* specs differ sharply and must not be mixed in, [a424737](https://www.linkedin.com/help/linkedin/answer/a424737)); YouTube [6375112](https://support.google.com/youtube/answer/6375112), [1722171](https://support.google.com/youtube/answer/1722171), [2734698](https://support.google.com/youtube/answer/2734698), [71673](https://support.google.com/youtube/answer/71673), [15424877](https://support.google.com/youtube/answer/15424877).

**Shorts classification is automatic and irreversible at upload**: for standard channels, anything uploaded on or after 15 October 2024 "with a square or vertical aspect ratio up to three minutes in length will be categorized as Shorts," and to avoid it you "use a wider aspect ratio such as 16:9" ([15424877](https://support.google.com/youtube/answer/15424877)). So the 4:5 feed cut must never be the canonical YouTube upload.

**Website hero.** Chrome: "Muted autoplay is always allowed"; sound-on needs a gesture, a high Media Engagement Index on desktop, or an installed PWA, and a gesture-less `play()` otherwise rejects with `NotAllowedError` ([autoplay policy](https://developer.chrome.com/blog/autoplay)). `playsinline` is an iOS rule, not a Chrome one: "On iPhone, `<video playsinline>` elements will now be allowed to play inline", "`<video muted>` elements will also be allowed to autoplay without a user gesture", and "`<video autoplay>` elements will pause if they become non-visible" ([WebKit iOS 10](https://webkit.org/blog/6784/new-video-policies-for-ios/)). macOS Safari blocks audible autoplay via "an automatic inference engine" and "prevents silent videos from auto-playing when either hidden in a background tab or otherwise off-screen" ([WebKit macOS](https://webkit.org/blog/7734/auto-play-policy-changes-for-macos/)), publishing no threshold. Hence `<video autoplay muted loop playsinline poster=…>` with real controls, and WebKit's own advice — "Websites should assume any use of `<video>` or `<audio>` requires a user gesture click to play" — so the poster frame must carry the message alone.

## 2. Length and the hook

Non-vendor evidence gives a ceiling, not an optimum. Guo, Kim & Rubin's 6.9M edX sessions: "median engagement time is at most 6 minutes, regardless of total video length," and in the 0–3 minute bucket "75% of sessions lasted over three quarters of the video length" ([PDF](https://up.csail.mit.edu/other-pubs/las2014-pguo-engagement.pdf)). That is lecture video, so it bounds the problem rather than solving it. **[inference]**

Finer data is all vendor data. Vidyard, 943,305 videos: under 1 minute "65% of viewers stay engaged all the way to the end" versus "only 20%" over 20 minutes, and "The highest level of viewer engagement occurs within the first quarter of a video's runtime" ([benchmarks](https://www.vidyard.com/business-video-benchmarks/)) **[vendor]**. Wistia, 13M videos: "The shorter the video, the higher the engagement rate," under-a-minute videos averaging 52% engagement ([length guide](https://wistia.com/blog/optimal-video-length)) **[vendor]**. Its most useful figure concerns openings: it calls the first 2% of a video the "nose," where "the average engagement drop in the nose is 4.9%" for 1–2 minute videos, rising "to 17.3%" for 5–10 minute ones ([audience retention](https://wistia.com/learn/marketing/understanding-audience-retention)) **[vendor]**. On a 25-second cut, 2% is half a second.

Hook guidance is vendor marketing. TikTok's ads help is most specific: "Prioritize your hook in the first 6 seconds", "Introduce your content proposition in the first 3 seconds", "We recommend displaying 5-10 words per second when using text" ([creative best practices](https://ads.tiktok.com/help/article/creative-best-practices)) **[vendor]**. YouTube's analytics help is first-party and non-promotional: "Intro tells you what percentage of your audience still watched your video after the first 30 seconds" ([9314415](https://support.google.com/youtube/answer/9314415)). Meta's much-quoted "65% who watch three seconds watch ten" is undated marketing citing an unnamed study, and its companion 47%/74% figures measure *brand-lift value* — **neither is a retention figure**.

View counts do not help: LinkedIn counts one at "Two or more continuous seconds of playback while the video is at least 50% on screen" ([85305](https://www.linkedin.com/help/linkedin/answer/85305)), X reportedly at the same 2 s / 50% test **[unread-X]**, YouTube since 24 August 2026 "the moment a video starts to play across all formats" ([2991785](https://support.google.com/youtube/answer/2991785)) — all satisfied long before the viewer decides anything.

A first-3-second hook for developers is therefore an artefact, not a claim: a real terminal, a real command, a real URL, legible at feed size in half a second. **[inference]** The canonical dev-tool demos open that way — Hykes' 5:21 first public Docker demo ([wW9CAH9nSLs](https://www.youtube.com/watch?v=wW9CAH9nSLs)) and DHH's 16:12 Rails "blog in 15 minutes" screencast ([Gzj723LkRJY](https://www.youtube.com/watch?v=Gzj723LkRJY)) — but both are long, neither is a marketing cut, and **their internal beats are unverified: neither page carries chapter markers and I did not watch them.** The nearest modern official comparison is Zed's 2:12 launch film ([c6Bns1T77HM](https://www.youtube.com/watch?v=c6Bns1T77HM)), whose own description leads with limits: "1.0 doesn't mean done, and it doesn't mean perfect."

## 3. Sound-off viewing and captions

The two figures everyone quotes do not survive tracing. "85% of Facebook video is watched without sound" is a [May 2016 Digiday article](https://digiday.com/media/silent-world-facebook-video/) reporting *publishers' self-reported* numbers that actually range 50–90%; Meta never published it. The Verizon Media / Publicis Media 2019 survey (5,616 US adults, 18–54) found ~80% say captions make them **more likely** to finish a video — a stated preference routinely mis-cited as a measured completion lift, and reached here only through secondary write-ups. Its durable findings: 69% watch sound-off in public, and 80% of caption users are not hearing-impaired.

The strong argument is conformance, not statistics. WCAG 2.2 SC 1.2.2 (Level A): "Captions are provided for all prerecorded audio content in synchronized media, except when the media is a media alternative for text and is clearly labeled as such" ([WCAG 2.2](https://www.w3.org/TR/WCAG22/)). SC 1.4.2 also applies if anything autoplays audibly for over 3 seconds.

**How this sits with the redundancy principle.** `explainer-video-clarity.md` establishes that graphics + narration + full on-screen text costs retention (16/16 tests, *d* = 0.86), reversed by short anchored keywords. Neither finding binds a muted cut, because of the mechanism: redundancy is an overload of the auditory channel by a visual duplicate of it. With sound off there is no auditory channel to overload, so burned-in text is not redundant — it is the sole verbal channel, which is Mayer's own stated boundary (short on-screen text, experienced learners). **[inference]** So the feed cut carries its message in burned-in text and needs no voice track, while the hero keeps the closed `<track kind="captions">` that doc recommends, since a viewer may unmute and then have both channels. The two artefacts differ by design; they do not disagree.

## 4. What resonates with developers rather than hype

Stack Overflow 2025 (49,000+ responses, self-selected) reads the audience's priors. Trust in accuracy (n=33,244): 3.1% highly trust, 29.6% somewhat trust, 26.1% somewhat distrust, 19.6% highly distrust — its own summary: "More developers actively distrust the accuracy of AI tools (46%) than trust it (33%)" ([2025/ai](https://survey.stackoverflow.co/2025/ai)). Favourable sentiment fell from "70%+ in 2023 and 2024" to "just 60% this year" while daily use rose to 47.1%. In 2024 highly-distrust was 7.9% and somewhat-trust 40.3% ([2024/ai](https://survey.stackoverflow.co/2024/ai)) — distrust roughly 2.5×'d in a year. The decisive item is the frustration list (n=31,476): **"AI solutions that are almost right, but not quite" at 66%**, with debugging AI-generated code at 45.2%. (Two 2025 figures contradict that page's own charts and are not used.)

The implication is narrow: a video selling capability argues against 66% of its audience's experience, while one selling *what happens to work that is almost right* argues with it — and that mechanism, not throughput, is thirdshift's substantiated differentiator. I found **no first-party developer-marketing guidance** worth citing; that gap is real, not omitted. Honest-claims constraints are settled in `explainer-video-audiences.md` §3 and adopted unchanged.

## 5. Recommendation

**Three renders from one 25-second timeline.** 16:9 1920×1080 for the hero and YouTube; 4:5 1080×1350 for X and LinkedIn (legal on both, and the tallest ratio YouTube will not auto-classify); 9:16 1080×1920 only if Shorts will actually be fed — otherwise skip it, since 4:5 already fills more feed height than 1:1. Burn captions into the feed renders; ship the 16:9 with a WebVTT `<track>` plus an SRT sidecar. One encode — H.264 High Profile, 4:2:0, 30 fps, AAC-LC — satisfies X's hard list, LinkedIn's ranges and YouTube's recommendation at once.

**25 seconds, no narration, no music.** At that length every vendor curve is in its flattest region and the nose is half a second. The hero loops silently; YouTube gets the same file with captions and a link-bearing description.

**The claim to lead with** is the overnight Run — the only repo proof with two real numbers and public artefacts: "A scheduled Pickup run took issue #663 at 00:21, and its Merge run merged pull request #665 at 01:22" (`site/index.html:105`, stderr at `:207`, `:301`). One caution: that Run's own log says "sessions run on codex · gpt-6.1-sol · high" (`site/index.html:207`), so **the proof beat must not be captioned as Claude Code**.

## Marketing cut: rules and outline

1. Runtime 22–28 s; no beat over 5 s; first legible frame within 0.5 s (Wistia nose, §2) **[vendor]**.
2. Three renders only: 16:9 1920×1080, 4:5 1080×1350, 9:16 only if Shorts will be fed. Nothing square-or-taller is the canonical YouTube upload ([15424877](https://support.google.com/youtube/answer/15424877)).
3. One encode for all: MP4, H.264 High Profile, 4:2:0, 30 fps, ≥5,000 kbps, AAC-LC 48 kHz (§1).
4. Captions burned into the feed renders; closed `<track kind="captions">` on the hero, SRT sidecar for YouTube and LinkedIn. WCAG 2.2 SC 1.2.2 is Level A (§3).
5. No voice, music or sound effects in the feed cut — no audio channel to overload, nothing to mix (§3; `explainer-video-music.md`).
6. On-screen text ≤7 words per card at ≤8 words/second, never a transcript — under TikTok's 5–10 words/second ceiling **[vendor]**.
7. Every terminal frame is real, unretouched stderr from the Run in `site/index.html`: no mocked timestamps, no invented PR numbers.
8. The hero is `<video autoplay muted loop playsinline poster=…>` with visible controls, a poster frame that carries the claim alone, and tolerance for Safari pausing it off-screen ([WebKit macOS](https://webkit.org/blog/7734/auto-play-policy-changes-for-macos/)).
9. The proof beat names the date and both numbers (#663 → #665, 12 Oct 2026) or does not run — and never attributes that Run to Claude Code (§5).
10. No number for speed, throughput, output volume, time saved or cost; no comparison to another tool (`explainer-video-audiences.md` §3).
11. One limit is on screen, not in a description: sessions run unattended as your user, and a checkout is not a sandbox (ADR 0013, `site/how-it-works/index.html:91`).
12. "Worktree", "Harness", "Repair", "Claim", "Self-merge" and "Ticket" do not appear; "MIT, open source, a personal project" does.

| # | ~s | On-screen text | Narration | Repo source |
|---|---|---|---|---|
| 1 | 0–4 | `$ thirdshift https://github.com/acme/widgets/issues/7` typing into a real terminal; below it **"Give it an issue."** | none | `README.md:33` |
| 2 | 4–8 | **"Get a pull request ready for review."** over `PR …/pull/665 is ready for review` | none | `README.md:3`, `docs/guide.md:315` |
| 3 | 8–13 | Four units label up — **"Prepare · Implement · Review · Finish"** — with **"reviewed on two axes, then Git and CI"** anchored beside unit 3 | none | `docs/guide.md:38`, `:39`, ADR 0004 |
| 4 | 13–17 | **"Ready only when the factory stands behind it."** / smaller: *"otherwise the work is pushed and the PR goes back to draft"* | none | `README.md:5`, `docs/guide.md:7`, `:730–731` |
| 5 | 17–21 | Real stderr, timestamps visible: `00:21:05 taking Ready issue #663` → `01:22:56 PR …/pull/665 is merged`, with **"Overnight, 12 Oct 2026"** | none | `site/index.html:105`, `:207`, `:301` |
| 6 | 21–24 | **"Sessions run unattended as your user. A checkout is not a sandbox."** | none | ADR 0013, `site/how-it-works/index.html:91` |
| 7 | 24–27 | **"thirdshift.app — MIT, open source, a personal project. Point it at one issue in a repo you own."** | none | `README.md` install + license |
