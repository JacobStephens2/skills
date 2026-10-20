# Tailoring an explainer to executives and to engineers

Research date: 2026-10-19. Researched for the [thirdshift](https://github.com/JacobStephens2/thirdshift) explainer videos, then generalised. thirdshift's own claims and beat outline stay in its [`explainer-video-audiences.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-video-audiences.md), a worked example of the product-specific half.

**Question.** How should a product explainer video differ between a short cut for technical executives (CTO, VP Engineering, engineering director deciding whether to adopt an AI coding-agent tool) and a longer how-it-works cut for engineers? What can such a product truthfully claim to each?

**Method.** thirdshift's product claims were grounded only in its own repository, read-only: `README.md`, `docs/guide.md`, `CONTEXT.md`, `docs/adr/`, `site/`. External claims come from primary pages fetched directly, except `ftc.gov`, `gartner.com` and `apiiro.com`, which refuse non-browser clients: those were read from Internet Archive **raw** snapshots (`web.archive.org/.../id_/<url>`) of the canonical URLs, so the words are the publisher's but the path was the archive — **worth one human spot-check**. **[vendor]** marks seller-funded data; **[inference]** marks my judgment.

**Out of scope.** Multimedia design, narration pace, captions, accessibility ([clarity.md](clarity.md)); music and mixing ([music.md](music.md)); terms to pre-teach and misconceptions to correct, which are product-specific (thirdshift's [`explainer-newcomer-concepts.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-newcomer-concepts.md) is a model). Script, storyboard, render tooling, distribution, A/B testing.

## TL;DR

- **The executive cut cannot carry a productivity number.** METR has superseded its own famous result; its durable finding is that self-reports are unreliable — in early 2025 "people overestimated AI's effect on their time spent on tasks by 40 percentage points on average" ([METR 2026-05-11](https://metr.org/blog/2026-05-11-ai-usage-survey/)).
- **The risk this audience already believes in is review burden and delivery instability, not capability.** DORA 2025: AI "continues its detrimental relationship with software delivery stability." Stack Overflow 2025: 66% name work "almost right, but not quite" as their top frustration. A pitch that attacks exactly that gap, with each step substantiated in the product's docs, argues with the audience's experience rather than against it.
- **All length evidence is vendor-measured and directional.** 45–75 s is a judgment from that data, not a measured optimum. **[inference]**
- **"Answer first" is sourced; the five-beat marketing funnel is not.** Minto's own site is quotable and AR 25-50 mandates bottom-line-up-front, but no study tests problem → outcome → proof → how → CTA as a sequence.
- **FTC's substantiation rule binds:** making an objective claim is itself a representation that you already hold evidence for it. §3 lists the claims an AI coding tool usually cannot substantiate.

## 1. What a technical executive needs to see

**Value.** The number everyone quotes is dead by its author's hand. METR's July 2025 RCT (16 experienced developers, 246 real issues in repos "averaging 22k+ stars and 1M+ lines of code") found developers "take 19% longer to complete issues" while they "expected AI to speed them up by 24%" ([metr.org](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/), [arXiv 2507.09089](https://arxiv.org/abs/2507.09089)). That page now reads "These results are out of date." The [Feb 2026 continuation](https://metr.org/blog/2026-02-24-uplift-update/) (57 developers) estimates "a speedup of -18% with a confidence interval between -38% and +9%" for returning developers and "-4% … between -15% and +9%" for new ones — both crossing zero, because "30% to 50% of developers told us that they were choosing not to submit some tasks because they did not want to do them without AI." METR's durable finding is the perception gap: self-reports overstated AI's time effect "by 40 percentage points on average" ([2026-05-11](https://metr.org/blog/2026-05-11-ai-usage-survey/)). **The effect is unsettled in both directions, and nobody's self-report is evidence.**

**Risk and control.** [DORA 2024](https://dora.dev/research/2024/dora-report/) (~3,000 professionals, 104 countries) measured "an estimated 7.2% reduction [in delivery stability] for every 25% increase in AI adoption," blaming teams that "forget … the importance of small batch sizes"; [DORA 2025](https://dora.dev/research/2025/dora-report/) (nearly 5,000 respondents) reverses the throughput finding but not that one, and gives this audience's best line: "AI's primary role in software development is that of an amplifier." **[vendor-adjacent:** Google Cloud, with GitHub and GitLab as partners.**]** [Apiiro](https://apiiro.com/blog/4x-velocity-10x-vulnerabilities-ai-coding-assistants-are-shipping-more-risks/) corroborates the mechanism — "fewer PRs overall – each one significantly larger in scope" **[vendor, thin method]**.

**Trust is conditional, and that is the sale.** [Stack Overflow 2026](https://survey.stackoverflow.co/2026/ai) (30,903 responses): "48% trust AI when they can easily verify it, while only 7% trust it with important decisions … That's why human-in-the-loop is the dominant mode." The [2025 edition](https://survey.stackoverflow.co/2025/ai) (49,009 responses) names the pain: 66% cite work "almost right, but not quite." Both are recruited from Stack Overflow's own highly-engaged users. **An executive is not asking whether an agent can write code; they are asking who checks it.**

**Security, governance, cost.** [Perry et al., CCS '23](https://arxiv.org/abs/2211.03622) (47 participants) found AI-assisted participants "wrote significantly less secure code … [and] were more likely to believe they wrote secure code" (stale model; participants "mainly university students"). [Retool 2026](https://retool.com/blog/ai-governance-report-2026) (307 respondents, all CTO/CIO/CISO) is the best-targeted set found: "91% chose security and data access controls" as a top priority, "Just 8% reported strong internal governance," and "37% of CISOs say tolerance for friction is 'near zero'" **[vendor]**. Cost ranks low — "only 6% switched because of costs," against 25% for better output (Stack Overflow 2026).

**Proof.** Why proof must be concrete: GitHub's [55% figure](https://github.blog/news-insights/research/research-quantifying-github-copilots-impact-on-developer-productivity-and-happiness/) rests on 95 developers writing one greenfield HTTP server, with a "95% confidence interval … [21%, 89%]" **[vendor]**. The alternative is an artifact, not a benchmark: a real, dated run the viewer can open. thirdshift's is an issue taken at 00:21 and its pull request merged at 01:22 on 12 October 2026, quoted from the stderr of that run.

## 2. Length and structure

Every usable length number is vendor data from the vendor's own hosting, uncontrolled for content type, unreplicated. Wistia's 2016 study (564,710 videos, "more than 1.3 billion plays"): "2 minutes is the sweet spot. After that, the drop-off in engagement is significant," and "a 90-second video will hold a viewer's attention as much as a 30-second video." [Vidyard 2025](https://www.vidyard.com/business-video-benchmarks/) (943,305 videos): under 1 minute, "65% of viewers stay engaged all the way to the end," versus "only 20%" over 20 minutes, and "The highest level of viewer engagement occurs within the first quarter of a video's runtime." [Wistia 2026](https://wistia.com/blog/video-marketing-statistics) (13M+ videos) adds only "The shorter the video, the higher the engagement rate" — its bucket chart is an image, so no ladder is quotable. All **[vendor]**. **No non-vendor measurement was found, so 45–75 s is a judgment from directional data, and a doc arguing for substantiation must say so. [inference]**

**"Answer first" is sourced; the funnel is not.** Minto's own site ([barbaraminto.com/concept](https://www.barbaraminto.com/concept)): "your thinking will be easy for a reader to grasp if you present the ideas organized as a pyramid under a single point." **Correction worth recording: her site says "SCQ Framework℠" — Situation, Complication, Question — with no "A." "SCQA," "MECE" and "governing thought" appear nowhere in her published web writing; the rules are in the paywalled 1996 textbook. Do not attribute them to her site.** Army Regulation 25-50 (10 Oct 2020) mandates the same for senior readers: "putting the main point at the beginning of the correspondence (bottom line up front)" — an institutional standard, not evidence it works. Nearest experiment: Haugtvedt & Wegener, *JCR* 21(1) 1994 ([doi:10.1086/209393](https://doi.org/10.1086/209393)) — high elaboration yields a **primacy** effect, low elaboration recency; abstract-only, and about two opposing messages. **No study tests problem → outcome → proof → how → CTA as a sequence; it is practitioner convention.** Hovland et al. (1957) could not be reached; do not cite it.

## 3. Claiming value without unsupported numbers

[Advertising Substantiation](https://www.ftc.gov/legal-library/browse/ftc-policy-statement-regarding-advertising-substantiation) (23 Nov 1984) is the binding rule: "Objective claims … represent explicitly or by implication that the advertiser has a reasonable basis supporting these claims … a firm's failure to possess and rely upon a reasonable basis for objective claims constitutes an unfair and deceptive act or practice in violation of Section 5." The [small-business FAQ](https://www.ftc.gov/business-guidance/resources/advertising-faqs-guide-small-business): "The law requires that advertisers have proof before the ad runs," and "Statements from satisfied customers usually are not sufficient." On AI, ["Keep your AI claims in check"](https://www.ftc.gov/business-guidance/blog/2023/02/keep-your-ai-claims-check) (27 Feb 2023): "if such proof is impossible to get, then don't make the claim." [Operation AI Comply](https://www.ftc.gov/news-events/news/press-releases/2024/09/ftc-announces-crackdown-deceptive-ai-claims-schemes) (25 Sep 2024): DoNotPay sold a "robot lawyer" that would "replace the $200-billion-dollar legal industry with artificial intelligence" but "did not conduct testing to determine whether its AI chatbot's output was equal to the level of a human lawyer"; the order bars "claims about its ability to substitute for any professional service without evidence to back it up." **A "replaces your engineers" line is that case.**

**Applying it.** Before scripting, write two lists from the product's own docs: the claims they substantiate, each with its file:line, and the claims they don't. thirdshift's lists are in its note linked above. For an AI coding tool, these usually fail substantiation:

- (a) Any productivity multiplier, time saved or throughput figure — unless measured for this product; the 40-point perception gap makes an author's impression worthless.
- (b) Guaranteed correctness.
- (c) "Replaces engineers."
- (d) Security sandboxing or isolation the docs don't establish.
- (e) Comparisons to other tools.
- (f) Enterprise governance (SSO, audit trail, org policy controls) the docs don't show. For a personal or small project, **saying so is a credibility feature, not a gap to hide.**
- (g) Reliability of unattended runs.

**Cost visibility is usually narrower than it sounds.** Name exactly what the product reports — for thirdshift, "per-session token and cost-equivalent figures are in the logs" — never "you can see your spend."

## 4. How the two cuts differ

| | Executive cut | Engineer cut |
|---|---|---|
| **Length** | 45–75 s **[inference]** | 2–4 min; Wistia 2016: "If they'd benefit from depth, don't cut just for the sake of cutting" |
| **Opening** | The answer in one sentence, before any mechanism (Minto; AR 25-50) | Pre-teach the nouns, then the causal flow (the product's newcomer-concepts note) |
| **Unit** | One decision: adopt or not | One run of the product, start to finish |
| **Proof** | One real, dated artifact | The same, plus prompts, logs, design records |
| **Avoid** | Internal mechanism nouns the decision doesn't need | Nothing — these are the content |
| **Cut** | Secondary modes, configuration, install | Nothing |
| **Keep** | Who stays in control; what happens on failure; the limits | All of it, with mechanism |
| **Risk** | Explicit and early — the credibility move for this audience (Retool: CISO friction tolerance "near zero") | Explicit and detailed |
| **CTA** | "Read how it works, then try it on one task you own" — a 10-minute evaluation, not a signup | "Install it, read the internals, run one task" |

## Executive cut: rules and outline

1. No number describing speed, throughput, output volume or time saved appears in the cut.
2. No comparison to another tool, named or implied.
3. Every factual on-screen claim traces to a line in the product's docs or code; list the source per beat before recording.
4. Security words ("sandbox", "isolated", "secure") appear only where the docs establish them, or in a negation.
5. Internal mechanism nouns the decision doesn't need do not appear.
6. Who stays in control (who reviews, who ships) is stated within the first 20 s.
7. One risk disclosure is spoken, not only captioned.
8. The proof beat names a real, dated artifact with its identifiers, or no proof beat runs.
9. Any cost mention names exactly what the product reports, never "cost" or "spend" unqualified.
10. Total runtime 45–75 s; no beat exceeds 12 s.
11. The CTA asks for an evaluation on something the viewer owns — not a purchase, trial or contact form.
12. Support expectations are stated honestly, such as a personal open-source project with no support commitment.

| # | ~s | Beat | Purpose |
|---|---|---|---|
| 1 | 0–8 | What goes in, what comes out, and who still decides | Answer first: the governing thought |
| 2 | 8–18 | The problem the audience already believes in: output that is almost right, and review that absorbs the gain | Name the believed risk before any benefit |
| 3 | 18–30 | The answer: the product's substantiated mechanism | The differentiated, fully substantiated claim |
| 4 | 30–40 | Proof: a real, dated artifact | A verifiable artifact instead of a benchmark |
| 5 | 40–52 | Failure: what happens to the work when it goes wrong | Answers the executive's real question |
| 6 | 52–62 | Limits, spoken | Credibility, and FTC-safe |
| 7 | 62–72 | CTA: one task the viewer owns; licence and support stated | Low-commitment evaluation, honest support expectations |

Each beat gets a source column (file:line) in the product's own outline.
