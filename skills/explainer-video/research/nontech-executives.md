# Tailoring an explainer to non-technical executives

Research date: 2026-10-20. Researched for the [thirdshift](https://github.com/JacobStephens2/thirdshift) explainer videos, then generalised. thirdshift's own analogy mappings, term translations, claims and beat outline stay in its [`explainer-video-nontech-executives.md`](https://github.com/JacobStephens2/thirdshift/blob/main/docs/research/explainer-video-nontech-executives.md), a worked example of the product-specific half.

**Question.** How should a 60–90 s narrated explainer for an AI software tool be tailored to a non-technical leader (CEO, COO, founder, business-unit or operations head) who does not code and does not know what an issue, a pull request, CI, cron or a code review is?

**Method.** This note builds on [audiences.md](audiences.md) (the technical-executive cut) and does not re-derive its FTC, length, answer-first, DORA, METR or Stack Overflow sourcing; read it first. Multimedia design is in [clarity.md](clarity.md) and music in [music.md](music.md). External sources were read as primary PDFs or publisher pages (Gentner 1983; Gentner & Gentner 1983; Camerer et al. 1989; Cowan 2001 abstract; digital.gov; Deloitte; McKinsey). `mckinsey.com` and `pwc.com` refuse non-browser clients: McKinsey came from an Internet Archive **raw** snapshot (`web.archive.org/.../id_/<url>`) of the canonical URL, and PwC's numbers from **PwC's own press release as distributed by PR Newswire** (`SOURCE PwC`), because every `pwc.com` path and its archive snapshot returned 403. **Both are worth one human spot-check.** McKinsey's agentic-trust survey could not be reached and is not cited. **[vendor]** marks seller-funded data; **[inference]** marks my judgment.

**Out of scope.** Everything the other notes cover. Script, storyboard, voice casting, render tooling, distribution, translation, A/B testing. Non-English audiences.

## TL;DR

- **This audience's scepticism is financial, not technical.** PwC's 29th Global CEO Survey (4,454 CEOs, 95 countries, 30 Sep–10 Nov 2025): "only one-in-eight (12%) CEOs say AI has delivered both cost and revenue benefits … while 56% say they have seen no significant financial benefit to date." The cut must therefore **not** promise financial benefit: this audience has heard productivity numbers and been disappointed.
- **Governance is the gap they know they have.** Deloitte (3,235 IT and business leaders, 24 countries): only **21%** have "a mature governance model in place for agentic AI." If the product keeps a person deciding what ships, that is the most valuable sentence in the cut for this viewer. **[vendor]**
- **The analogy you choose decides which errors the viewer makes.** Gentner & Gentner 1983 is direct primary evidence: subjects taught a water model got batteries right and resistors wrong; subjects taught a moving-crowd model got resistors right (93% vs 63%) and batteries wrong. So pick the analogy whose *predictable* residual error is harmless.
- **Carry the chain of relations, not the worker's character.** "Request → work → check → sign-off" maps; "employee", "junior developer" and "it checks its own homework" import attributes nothing supports (§3).
- **Budget: translate every term, pre-teach at most three or four, and spend about 10 of 75 seconds doing it.** Cowan 2001: "a single, central capacity limit averaging about four chunks."

## 1. What non-technical leaders want to know

**Value, and their disappointment with it.** PwC's 29th Global CEO Survey, published 20 Jan 2026 ("We surveyed 4,454 CEOs in 95 countries and territories from 30 September to 10 November 2025," global figures "weighted proportionally to country nominal GDP"): "only three-in-ten (30%) CEOs say they are confident about revenue growth over the next 12 months—down from 38% in 2025 and 56% in 2022"; "only one-in-eight (12%) CEOs say AI has delivered both cost and revenue benefits. Overall, 33% report gains in either cost or revenue, while 56% say they have seen no significant financial benefit to date." Their top concern is "whether they are transforming fast enough to keep pace with technological change, including AI" (42%, "well ahead of worries about innovation capability or medium to long-term viability (both 29%)").

McKinsey's State of AI (online survey "in the field from May 4 to June 8, 2026 … 1,719 participants in 97 nations," 36% from organisations over $1bn revenue, weighted by national GDP) gives the same shape with better instrumentation: "Thirty-seven percent of respondents attribute at least some EBIT impact to AI use (about the same share as last year)," and AI high performers "account for just 6 percent of survey respondents, unchanged from 2025." Individual-level gains are not in doubt ("Eighty percent of respondents report that AI has improved their individual productivity"), but **the gap between personal gain and company result is exactly where this viewer sits**. McKinsey also records the behaviour AI coding tools belong to: "Nearly a third of respondents (32 percent) report that their organizations have decided against buying one or more software products or features because they could be built internally with agentic coding tools."

**Control, oversight and accountability.** Deloitte's *State of AI in the Enterprise* (Jan 2026; "3,235 information technology and business leaders from 24 countries," all with "direct involvement in their organizations' AI programs") finds only **21%** report "a mature governance model in place for agentic AI," so "approximately 80% of surveyed organizations currently lack mature governance capabilities for agentic AI." Its definition of mature governance: "clear boundaries for agents that define which decisions they can make independently versus which require human approval," plus "real-time monitoring systems that track agent behavior and flag anomalies" and "audit trails that capture the full chain of agent actions." **[vendor]** Claim only the parts of that definition the product's docs substantiate.

**Their own competence is a live anxiety.** Deloitte's Global Boardroom Program ("695 board members (84%) and C-suite executives (16%) in 56 countries," fielded "from January to February 2025") found "66% say their boards have 'limited to no knowledge or experience' with AI, down from 79%," and "31% say AI is not on the board agenda, down from 45%." **[vendor]** **[inference]** A cut that makes this viewer feel ignorant will lose them; a cut that hands them one sentence they can repeat in a meeting wins. Write for repeatability, not for completeness.

**Risk framing to keep.** McKinsey's high performers "are much more likely than others to report working to mitigate the exploitation of AI-driven technical vulnerabilities as well as unauthorized or unintended actions." **[inference]** A product's access limit (what account it runs as, what it can reach) is not a confession to this viewer; it is the one risk statement they can act on, because access is something they already govern.

## 2. Explaining it to someone who does not code

**The curse of knowledge is measured, and markets only halve it.** Camerer, Loewenstein & Weber, *JPE* 97(5) 1232–1254 (1989), [doi:10.1086/261651](https://doi.org/10.1086/261651): "Better-informed agents are unable to ignore private information even when it is in their interest to do so; more information is not always better," and "we find that market forces reduce the curse by approximately 50 percent but do not eliminate it." **Newton's 1990 tapping study could not be reached as a primary source and is not cited here; do not attribute it.** **[inference]** The author of the video cannot judge its clarity. Test the script on one non-engineer before recording, and treat their questions as data.

**Structure-mapping says carry the relations, not the objects.** Gentner, *Cognitive Science* 7, 155–170 (1983): the two mapping principles are "(a) Relations between objects, rather than attributes of objects, are mapped from base to target: and (b) The particular relations mapped are determined by systematicity, as defined by the existence of higher-order relations," and an analogy proper is "a comparison in which relational predicates, but few or no object attributes, can be mapped." The systematicity principle: "A predicate that belongs to a mappable system of mutually interconnecting relationships is more likely to be imported into the target than is an isolated predicate." **[inference]** So the analogy must carry the *chain* (request → work → check → approval), not the character of the worker. An analogy that invites the viewer to import object attributes ("it's like a junior engineer": tired, loyal, learns, can be promoted) imports exactly the wrong things.

**And the analogy determines the error.** Gentner & Gentner, "Flowing waters or teeming crowds: Mental models of electricity," in *Mental Models* (Erlbaum, 1983), 99–129. Experiment 1 (36 high-school and college students screened as "fairly naive about physical science"; only the 7 consistent fluid-flow and 8 consistent moving-crowd users analysed): "people who used the flowing-fluid model performed better on batteries than on resistors. The reverse is true for the moving-crowd people." Experiment 2 taught the models (18 subjects, 7/6/5 per group: **tiny, and worth saying so**): "In the M group, 93% of the subjects answered that current given two parallel resistors would be greater than or equal to current given a single resistor, as compared with .63 for the combined P and R groups … significant by a X 2 test (p < .05)." **The lesson is not "use analogies" but "every analogy ships a predictable blind spot; choose the one whose blind spot you can live with."**

**Plain language is a legal standard, not a style preference.** The Plain Writing Act of 2010 "established the requirement that content for the public is written for its specific audience" ([digital.gov](https://digital.gov/guides/plain-language), which now hosts the former plainlanguage.gov guidance). Its principles: "The first rule of plain language is: write for your audience"; "Take your audience's current level of knowledge, expertise, and interest into account"; and the myth it rejects: "you have to 'dumb down' your content so that everyone can read it … That's not true." On jargon: "Jargon is complicated language used to impress, rather than to inform, your audience"; "When we say not to use jargon, we're not advocating leaving out necessary technical terms"; "Try to substitute everyday language for jargon as often as possible"; "When you have no way to express an idea except to use technical language, make sure to define your terms"; "Rewrite to try to eliminate the need for most definitions"; and "Never define a word to mean something other than its commonly accepted meaning." That last rule bars redefining "review" or "merge" to mean something convenient.

**Mayer's pre-training is the mechanism (reuse, don't re-derive).** 13/16 tests, *d* = 0.75: learners need "the names and characteristics of the main concepts" first ([clarity.md](clarity.md) §1). Signaling (*d* = 0.41) and the 8–10 s one-idea segment carry over unchanged. Redundancy's exception applies: 2–3 printed words anchored beside the part of the graphic they name *helped* retention (*d* = 0.47, 0.70), and for a lay viewer meeting new nouns that anchoring is the cheapest clarity available. **[inference]**

## 3. Which analogies are safe

**Safe shape.** For a tool that turns a request into a change a person approves: *a work order handed to a shop → a separate bench, not your desk → a second pair of eyes before it leaves the bench → a draft submitted for sign-off → you sign it off*. Each maps a relation, and each has a blind spot to correct in the same breath (a separate bench suggests a locked room; a second pair of eyes suggests a guarantee). The product's own note should tabulate each mapping against the doc line that substantiates it and the blind spot it accepts.

**Barred analogies, with reasons.** (a) **"An employee," "a teammate," "a junior developer who works nights."** Invites object-attribute mapping (loyalty, learning, judgment, accountability), and edges toward the DoNotPay "robot lawyer" order cited in [audiences.md](audiences.md) §3. (b) **"Replaces your engineers"**: the exact kind of claim the FTC's order addressed. (c) **"An assembly line that runs itself"**, unless the product really schedules and recovers itself. (d) **"A robot that checks its own homework"**: the self-approval reading a human sign-off exists to deny. (e) **"A locked sandbox / a safe room"**, unless the product really isolates. (f) **Any medical, legal or safety analogy**: implies a standard of care.

## 4. Vocabulary budget

**Translate everything; pre-teach three or four things at most.** Cowan, *BBS* 24(1) 2001: "A single, central capacity limit averaging about four chunks is implicated," real "only if the boundary conditions for observing them can be carefully described"; a one-pass linear video with novel labels is close to his condition "(1) when information overload limits chunks to individual stimulus items." **[inference]** Four is therefore a ceiling, not a target; three is safer, and each must be anchored on screen (§2) and spoken in the same beat it appears. An engineer cut's term list is the wrong list for this audience: those terms are the mechanism, and this viewer buys the governance. Pre-teach the nouns the governance story needs (for a coding tool: the request, the draft for sign-off, the automatic checks), translate everything else inline, and never speak the product's own term for it.

## 5. Claims this register invites

Apply the FTC substantiation rule in [audiences.md](audiences.md) §3 ("The law requires that advertisers have proof before the ad runs") to the phrases a business register reaches for:

- **"Overnight":** allowed when it factually describes when a documented run ran.
- **"While you sleep":** allowed only as literal timing, never as autonomy, and never beside a suggestion that work ships unseen.
- **"It runs itself," "set it and forget it," "fully autonomous":** barred unless the docs substantiate scheduling, recovery and decisions without a person.
- **"Automates engineering," "automates your development team":** barred. A tool that turns one request into a draft for sign-off automates one path, not a team.
- **Any throughput, headcount, cost or time-saved figure:** barred, as in the technical cut. **[inference]** This audience's own benchmark is the PwC 12%/56% split, so a number is both unsubstantiated and unbelievable.
- **"Enterprise-ready," "governed," "auditable," "compliant," "secure":** barred unless the docs show the controls (SSO, org policy, audit trail, monitoring) that Deloitte's definition of mature governance names.
- **Support:** say plainly what support exists. For a leader who will ask "who supports this?", answering before they ask is the credibility move.

## 6. Length and structure

All length evidence remains vendor-measured and directional ([audiences.md](audiences.md) §2); nothing new was found. **[inference]** 60–90 s, at the long end of the technical cut, because the terms must be pre-taught and pre-teaching is not free: Mayer's pre-training effect is purchased with time, so budget about 10 s of 75 for it and cut a mechanism beat, not the risk beat. Answer-first still holds (Minto; AR 25-50), but **the answer itself changes**: the technical executive's answer is *what it produces*; this viewer's answer is *who stays in charge*. Lead with the control, then the output. Music: head and tail only, never under narration ([music.md](music.md)).

## Rules

The technical-executive rules in [audiences.md](audiences.md) still bind; these add to them.

1. The first spoken sentence says who decides what ships, then what the product does.
2. No more than three new terms in the whole cut. Count them before recording; a fourth fails the cut.
3. None of the product's internal or developer vocabulary is spoken or printed. List the banned words in the storyboard before writing scenes.
4. None of the barred analogies in §3 appears.
5. Each analogy used appears once and is never extended past the relation it maps.
6. Each new term appears as 2–3 anchored on-screen words beside the thing it names, spoken in the same beat.
7. "Overnight" or "while you sleep" never occurs in the same beat as a statement about work being finished, filed or shipped.
8. No number describing speed, throughput, headcount, cost or time saved, and no comparison to another tool.
9. The risk beat is spoken, not captioned, and states the access fact in lay terms: whose account it runs as, and what that account can reach.
10. The proof beat names one real, dated artifact, or no proof beat runs.
11. Total runtime 60–90 s; no beat exceeds 12 s; music only before the first word and after the last.
12. Before recording, one person who does not write software watches it and is asked, unprompted, "who decides whether this change happens?" If they cannot answer, the cut fails.

## Beat outline

| # | ~s | Beat | Purpose |
|---|---|---|---|
| 1 | 0–9 | Who decides, then what it does | Answer first, and the answer is control, not output |
| 2 | 9–19 | Pre-teach the three terms, anchored | Mayer pre-training; the whole cut's vocabulary, paid for up front |
| 3 | 19–28 | The problem in their language: AI writes plenty, and few companies have a rule for what to accept | Names the believed risk, matched to their own data (Deloitte 21%) |
| 4 | 28–42 | What happens, as a chain of relations: request → separate copy → work → second pair of eyes → automatic checks → ready only when all pass | The differentiated, substantiated claim (Gentner) |
| 5 | 42–52 | Proof: one real, dated artifact | A verifiable artifact, not a benchmark |
| 6 | 52–62 | When it can't finish: what is kept, and how "ready" stays meaningful | Answers "what does failure cost me?" |
| 7 | 62–74 | The limit, spoken, and what helps get the work right | Credibility, FTC-safe; the risk this viewer can govern |
| 8 | 74–86 | Call to action: have someone point it at one request in a project you own | A delegated, low-commitment evaluation |
