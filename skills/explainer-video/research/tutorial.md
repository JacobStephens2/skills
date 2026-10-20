# How to make the "How to use thirdshift" getting-started tutorial video

Research date: 2026-10-19.

**Question.** How should a getting-started tutorial video for the thirdshift CLI be made, and what exactly should it show, command by command, with the output a viewer should expect at each step?

**Method.** Part 1 cites primary literature (DOIs resolved against Crossref on title, authors, journal, pages) and standards text. **[FT]** = quoted from a paper read in full; **[AB]** = publisher abstract; **[SN]** = search snippet, unverified. **[DEL]** = obtained by a delegated standards pass with the provenance shown, not fetched in this session. Part 2 cites this repo with `file:line` — `README.md`, `docs/guide.md`, `site/index.html`, and `src/` only to confirm a command or flag exists.

**Out of scope.** The narrated 60–120 s *explainer*: `explainer-video-clarity.md` (Mayer's magnitudes, 160–185 wpm, captions, WCAG, diagrams) and `explainer-newcomer-concepts.md` (terms to pre-teach, six confirmed misconceptions) are taken as read and never repeated. Also out: audience segmentation, music, render tooling, hosting, localisation.

## TL;DR

- One programme is directly on topic: van der Meij & van der Meij's **eight guidelines for instructional video for software training**, tested — video beat paper on "motivation, higher skills proficiency immediately after training, and better skills retention after a one-week delay" **[FT]**. Its successor, the **eleven** guidelines (2022), is the current version and is **paywalled and unread — the biggest gap in this memo**.
- Those guidelines carry the decisions, not generic multimedia theory: G4 *Preview the task*, G5 *procedural rather than conceptual*, G7 *keep videos short*, G3.1 *pace carefully*.
- **Chapters and timestamps have no primary support.** Ploetzner's meta-analysis puts *navigational* features in the losing baseline. Chapter the video for re-use, and claim nothing more.
- **Typing speed and demonstration pacing are unevidenced.** No primary source. Any choice is a design judgement.
- **No standards body fixes a minimum text height for arbitrary on-screen text.** Every figure that exists governs subtitles. Safe-area geometry transfers; character height does not.
- Show the failure and the recovery, with an honest warrant: error management training gives *d* = 0.44 over 24 studies, *d* = 0.80 on adaptive transfer **[FT]** — for learners making their *own* errors, not for watching a demonstrator fail. Flagged extrapolation.
- **Record a real terminal, rehearsed.** No primary source compares real with rendered (flagged); the deciding argument is that the project already publishes real stderr as proof (`site/index.html:316`).
- The repo has a complete real transcript of a *successful* Run and **nothing** for `status`, `show`, `logs`, `setup`, `update` or the installer (§5.9).

## 1. Tutorial practice for software tasks

**The on-topic programme.** van der Meij & van der Meij (2013), "Eight guidelines for the design of instructional videos for software training", *Technical Communication* 60(3), 205–228 — **no DOI exists**; open PDF at [ris.utwente.nl](https://ris.utwente.nl/ws/portalfiles/portal/6827789/s4.pdf). Verbatim, Figure 1, p. 206 **[FT]**:

> 1 Provide easy access · 2 Use animation with narration (2.1 be faithful to the actual interface; 2.2 a spoken human voice; 2.3 action and voice must be in synch) · 3 Enable functional interactivity (3.1 pace the video carefully; 3.2 enable user control) · 4 Preview the task (4.1 promote the goal; 4.2 conversational style; 4.3 introduce new concepts by showing their use in context) · 5 Provide procedural rather than conceptual information · 6 Make tasks clear and simple (6.1 follow the user's mental plan; 6.2 draw attention to the interconnection of user actions and system reactions; 6.3 use highlighting to guide attention) · 7 Keep videos short · 8 Strengthen demonstration with practice

Results **[FT]**: "the video instructions yielded more favorable appraisals for motivation, higher skills proficiency immediately after training, and better skills retention after a one-week delay." Its own scope limit: "we concentrated on instructional video that serve a tutorial function. For video that function as a reference guide not all the guidelines are equally important."

DOI-verified but unread: the paper-vs-video comparison ([10.1016/j.compedu.2014.06.003](https://doi.org/10.1016/j.compedu.2014.06.003)) — **its between-condition result is not stated here, because the snippets contradicted each other**; the DBT framing ([10.1007/s11251-016-9394-9](https://doi.org/10.1007/s11251-016-9394-9)), anchored on Rosen et al. 2010 ([10.1177/0018720810381071](https://doi.org/10.1177/0018720810381071) — the circulated `…0810669458` does not resolve); and the successor, **van der Meij & Hopfner (2022), "Eleven guidelines…", *Technical Communication* 69(3), 5–23 ([10.55177/tc786532](https://doi.org/10.55177/tc786532))**, adding procedural discourse, video reviews, music and narrator presence. **Read the eleven before cutting; they supersede the eight.**

**Worked examples.** Sweller & Cooper (1985) ([10.1207/s1532690xci0201_3](https://doi.org/10.1207/s1532690xci0201_3)) is foundational but **unread, no verified effect size** — the quoted "six times longer" is **[SN]** and not reproduced. Review: Renkl (2014) ([10.1111/cogs.12086](https://doi.org/10.1111/cogs.12086)). The only meta-analysis found, Barbieri et al. (2023) ([10.1007/s10648-023-09745-1](https://doi.org/10.1007/s10648-023-09745-1)), gives g ≈ 0.48 **[SN, unverified]** and is **mathematics-only**; **no worked-example meta-analysis exists for software or procedural training**. The caveat is solid — Kalyuga et al. (2003) ([10.1207/S15326985EP3801_4](https://doi.org/10.1207/S15326985EP3801_4)): what helps novices loses value for experts. The audience is terminal-expert and thirdshift-novice, so demonstrate thirdshift's decisions, not git, `gh` or cron.

**The failure case.** Keith & Frese (2008), *Journal of Applied Psychology* 93(1), 59–69 ([10.1037/0021-9010.93.1.59](https://doi.org/10.1037/0021-9010.93.1.59)), author PDF read in full **[FT]**: "the mean effect of EMT across all identified 24 studies (N = 2183) was positive and significant (Cohen's *d* = 0.44)"; "effect sizes to be larger for posttraining transfer than for within-training performance (transfer performance: *d* = 0.56) and for performance tasks that were structurally distinct (adaptive transfer) rather than similar (analogical transfer) to training tasks (adaptive transfer: *d* = 0.80)"; analogical transfer alone "*d* = 0.20, *p* < .05". **Flagged extrapolation:** EMT is the *learner* exploring and erring, not a viewer watching a demonstrator fail. The failure chapter borrows EMT's direction, not its *d*.

**"Show the expected output first."** **No experimental test found.** The rationale is Collins, Brown & Holum (1991), "Cognitive apprenticeship: making thinking visible", *American Educator* **[FT]** — provenance trap: the circulated open PDF is this 1991 popularising article, *not* the 1989 Collins, Brown & Newman chapter in Resnick, pp. 453–494 ([10.4324/9781315044408-14](https://doi.org/10.4324/9781315044408-14)), so quote it as 1991. It names "four important aspects of traditional apprenticeship: modeling, scaffolding, fading, and coaching", and: "Giving students a conceptual model — a picture of the whole — is an important factor… First, it provides learners with an advanced organizer for their initial attempts to execute a complex skill". **The article labels this a hypothesis (Lave 1988) and is non-empirical.** The better-sourced hook is **G4 Preview the task** plus G8's "exercises that clearly set the starting condition and end goal for the user" **[FT]**, which the 2013 paper ties to Mayer's pre-training principle and Ausubel's advance organizers. That chain is the warrant used here.

**Segmenting for procedures.** **No meta-analysis of segmenting for procedural or step-based tasks exists.** Spanjers, van Gog & van Merriënboer (2010), *Educational Psychology Review* 22(4), 411–423 ([10.1007/s10648-010-9135-6](https://doi.org/10.1007/s10648-010-9135-6)) is a **theoretical review with no pooled effect size**: segmentation "could cue relevant segments to students, which **may** aid them in perceiving the structure underlying the process or procedure shown" **[AB]** — note the hedge. Höffler & Leutner (2007), *Learning and Instruction* 17(6), 722–738 ([10.1016/j.learninstruc.2007.09.013](https://doi.org/10.1016/j.learninstruc.2007.09.013)) give animation over static pictures at *d* = 0.37 (CI 0.25–0.49) overall, *d* = 1.06 (CI 0.72–1.40) for procedural-motor knowledge **[AB]** — but that is animation vs. static, not segmenting, and "procedural-motor" means physical tasks, so **applying *d* = 1.06 to a screencast would be a stretch and is not done here.**

## 2. Real terminal or rendered terminal

**No primary source compares a recording of a real terminal with a synthetic one.** Flagged; what follows is reasoning.

**Legibility — a negative result, then a usable floor.** **No standards body (BBC, EBU, ITU-R, SMPTE) specifies a minimum text height for arbitrary on-screen text** **[DEL]**. Every size spec governs *subtitles and captions* — short, timed, bottom-of-frame — which terminal content is not. WCAG 2.2 gives no font-size figure either and does not route a screencast through the text criteria: **1.4.4 Resize Text (AA)** excepts images of text outright ("Except for captions and images of text, text can be resized without assistive technology up to 200 percent") and **1.4.5** is written about images, not video ([WCAG 2.2](https://www.w3.org/TR/WCAG22/)). An earlier draft of this memo argued a recorded terminal is "an image of text that cannot be resized" — **that framing is withdrawn; no W3C sentence supports it.**

The nearest figures, both *for subtitles* **[DEL]**: the BBC Subtitle Guidelines require authored font to fit a **line height of 7–8% of active video height** (players may reduce, never increase; preferred presentation 0.6–0.8×, so ~81 px authored and ~54 px presented at 1080p — the vendor-blog "44 px minimum" is **not** in the BBC document); **EBU Tech 3360** gives font height ≈ 1/15 of the subtitle safe area, a row ≈ 1/12, about 7.5% from an independent direction. **Do not import 7–8%:** it is calibrated for television distance, and BBC R&D WHP 287 measured a median relative viewing distance of 5.5× screen height where a laptop viewer sits at 1–2×. What transfers is geometry: **ITU-R BT.1848-1** and **EBU R 95** both give 3.5% action-safe and 5% graphics-safe margins (96 px lateral inset at 1080p); SMPTE ST 2046-1 gives 93%×93% safe action, 90%×90% safe title (*secondhand via the free EG 2046-3*). Keep the terminal inside the 5% graphics-safe box. Three recs named in the brief do **not** apply: BT.1702 is photosensitive-epilepsy guidance, BT.2100 never mentions captions or safe area, and EBU Tech 3264 has no text-height spec.

**Reading rate.** Szarkowska & Gerber-Morón (2018), *PLoS ONE* 13(6): e0199331 ([10.1371/journal.pone.0199331](https://doi.org/10.1371/journal.pone.0199331)): 74 viewers coped well up to 20 cps, so 160–180 wpm is a convention, not a ceiling — **but none of that work measured code or command text**, which is near-certainly slower.

**Pacing and typing speed.** **No primary research exists** on either. The only citable material is normative, G3.1, p. 212 **[FT]**: "employ a conversational tempo and not to speak instructions too quickly… Designers occasionally also affect the pace by extending natural breaks with an additional two to five seconds pause", and "A slow demonstration can be boring… A fast demonstration can overload the user". The two-to-five seconds is what designers *occasionally do*, not a tested value.

**Verdict: real terminal, rehearsed.** Three repo-specific reasons. The project publishes real stderr as evidence and says so (`site/index.html:105`, `:316`), so a synthetic terminal would undercut its own standard of proof. A Run "takes minutes to tens of minutes" (`docs/guide.md:288`), so a real recording must be cut anyway — the only thing rendering would have bought. And the lines are fixed strings (`docs/guide.md:336`), so rendering buys nothing but fabrication risk. Cut waits with a visible time jump; never re-type a line that differs from what the binary prints.

## 3. Length and chapters

**Chapters are for re-use, not learning.** Ploetzner (2022), *Interactive Learning Environments* ([10.1080/10494820.2022.2123002](https://doi.org/10.1080/10494820.2022.2123002)) **[AB]**: "Videos that include enhanced interaction features are significantly more effective than videos that comprise merely navigational interaction features or no interaction features… an overall effect size of Hedges's g = 0.522… However, if a video is not paused while an enhanced interaction feature is offered to the learners, a split-attention effect occurs, and learning is impeded." Chapters, timestamps and a scrub bar are *navigational* — the losing baseline. **No primary research establishes a benefit for chapters or timestamps.** Mayer's segmenting is system-paced, and its *d* = 0.79 came from click-to-continue (clarity file §1), so a linear video inherits neither. Chapter it anyway, because a tutorial is consulted mid-task and the returning viewer needs §5.7 in one click; `<track kind="chapters">` is a standard `<track>` kind ([MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/track)). Merkt et al. (2011), *Learning and Instruction* ([10.1016/j.learninstruc.2011.03.004](https://doi.org/10.1016/j.learninstruc.2011.03.004)) is DOI-verified but **unread, volume and pages unconfirmed** — not relied on.

**Length.** G7 **[FT]**: "a length of between 15 to 60 seconds is optimal for keeping the user engaged"; the authors' own "average preview and procedural video was just over one minute"; and the rule that matters — "What matters more is that the user perceives a video as having a clear beginning and end. This generally means that the designer must look for structural changes such as goal or sub-goal completion." So **chapter boundaries follow thirdshift's own sub-goals**, which is what §5's headings are. *Inference:* eleven beats at 45–90 s lands at **7–10 minutes**, each chapter independently watchable; no source prescribes a total.

## 4. Accessibility: what a procedure adds

The clarity file's WCAG findings hold. Three additions.

- **Integrated description — speak every command and state change aloud.** 1.2.5 requires audio description; glossary Note 3 is the lever ("Where all of the video information is already provided in existing audio, no additional audio description is necessary") while Note 1 counts on-screen text among what description must cover. Narration that reads each command satisfies 1.2.3 and 1.2.5 with no AD track; "type this" does not. The trap is on point: Understanding 1.2.3's examples include a software training video where the presenter talks and demonstrates at once, leaving no gap for description, so an alternative for time-based media becomes necessary instead **[DEL]**. Script so the description *is* the narration. **W3C gives no guidance on how finely to read commands or code aloud** — unguided; the only principle is that everything on screen be available in the audio.
- **Captions must not cover the terminal** — "Captions should not obscure or obstruct relevant information in the video" ([WCAG 2.2](https://www.w3.org/TR/WCAG22/#dfn-captions)). Terminal in the upper two-thirds.
- **Print every command as copyable page text beside the video.** *Inference:* no criterion requires it, but it is the only real answer to §2.

## 5. What the video must show, from the repo

**5.1 Prerequisites.** The account needs (`docs/guide.md:240-246`) the **Harness** "installed and authenticated: **`claude`** (Claude Code, the default), **`codex`**… or **`opencode`**"; "**`gh`** (GitHub CLI), logged in"; "**`git`** with a global `user.name` and `user.email`, and credentials that can push to the repository (`gh auth setup-git` makes git use `gh`'s login)"; "**`node`**… for a Security run only". Platforms: "x86_64 Linux (Rocky, Ubuntu and WSL2) and Apple Silicon macOS" (`README.md:19`). Two lines belong on screen: sessions "run headless with the full permissions of that user account, including `sudo` if the user has it, and nobody is there to approve anything" (`:249`), and "**Install the target repository's toolchains up front**" (`:257`). Show `type thirdshift claude gh git` — the guide's own idiom (`:228`, `:905`) — and `gh auth status`. **Output: not documented; record it.**

**5.2 Install.** Verbatim (`README.md:13`):

```sh
curl -LsSf https://github.com/JacobStephens2/thirdshift/releases/latest/download/thirdshift-installer.sh | sh
```

The short redirect `curl -fsSL https://thirdshift.app/install.sh | sh` (`site/index.html:71`) "redirects to the same installer" (`docs/guide.md:209`). It "puts a single binary in `~/.local/bin`; no Rust toolchain or checkout of this repo is needed" (`README.md:15`) and "ends by pointing you to Setup" (`:211`). Alternative: `cargo install thirdshift` (`:215`). **Output: not documented.**

**5.3 `thirdshift setup`.** Writes `~/.thirdshift/config.toml` (`:347`) "listing every setting at its default so the file itself shows what can be changed" (`:397`), printed in full at `:399-458`. From a terminal it asks eight things in order (`:465-472`): Harness, then its Model and Effort; `merge.always`; `base.fix`; `launch.pull`; `security.fix`; `security.review`; then notifications, address, sender and the Resend key "with input hidden". "Pressing Enter takes the default shown" (`:474`); it "prints the file's path on stderr and exits `0` with stdout empty". Only two prompt strings are quotable — `Resend API key (input hidden, Enter to skip):` (`:472`) and `No User config at <path>. Set your defaults now? [Y/n]` (`:476`). **The rest is described, not quoted: record the transcript.**

**5.4 First Run.** Verbatim (`:268-270`):

```sh
cd ~/repos/widgets          # a clone of the issue's repository, on the Base branch
thirdshift https://github.com/acme/widgets/issues/7
```

Shorthand is real (`:274-278`): `thirdshift 7`, `thirdshift merge 7`, `thirdshift --no-merge 7 harness codex`. "A Run takes minutes to tens of minutes" (`:288`). `no-merge`/`--no-merge` goes "before or after the URL" (`:296`); confirmed at `src/args.rs:459-460`.

**Output — real and quotable.** `site/index.html:105` states the lines come from a real Pickup run on 2026-10-12; `:316` that they are "copied, timestamps and all, from the Pickup run's Command log… there are 139 lines on stderr in all." Use them in order from `:208-305`: `sessions run on codex · gpt-6.1-sol · high`, `labelling #663 in-progress, in place of ready-for-agent`, `creating worktree /home/jacob/repos/thirdshift-issue-663 on issue-663 from origin/main`; then session lines as `implement: $ <command>`, closing `implement: session ended after 26m 2s: 7416316 input tokens (7285760 cached), 20664 output tokens` (`:263`); then `pushing issue-663`, `checking the PR`, `merging origin/main into issue-663`, `waiting up to 60s for CI on c16e780`, `CI on c16e780: 6 of 8 checks still running`, `CI passed on c16e780`, `origin/main moved while CI ran; merging it again`, and the cleanup and merge lines ending `PR …/pull/665 is merged`.

The format is fixed (`docs/guide.md:336`): every line "starts with the local time it was printed, as in `thirdshift: 12:14:49 pushing issue-7`"; the first names date and offset; a top-level Run prints `Took: 1h 2m 3s`; the last line is `PR <url> is ready for review` or `PR <url> is merged`. **stdout carries only the PR URL** — `url=$(thirdshift "$issue") && echo "ready: $url"` (`:334`). Two warnings: "Your checkout's uncommitted changes stay out of the Run. Push any Base branch commits first" (`README.md:37`), and blunter — "Unpushed commits on the Base branch are not: push them first, or the Run stops" (`docs/guide.md:343`).

**5.5 Watching.** `thirdshift status` "names this host and lists live Commands across every repository in `logs.dir`, with their issue and title when present, Harness, Model, Effort, current stage and its age" (`:76`). Verbatim (`:166-172`):

```sh
thirdshift show 'widgets#7'
thirdshift logs 'widgets#7' --session implement
thirdshift logs 'widgets#7' --session repair --follow
```

`show` gives "the Runs, stage history with start times, outcomes, and Command and Session log paths" plus "its latest event, such as `Bash: cargo test`" (`:174`). `logs` "writes the Command log verbatim"; `--follow` "first prints the selected log, then flushes appended bytes until the owning Command ends or dies" (`:199`). Confirmed at `src/args.rs:254,269,280,299`. **Flag: the guide shows no human-readable sample output for `status`, `show` or `logs`.** The only rendered example is the idle line (`:82`): `Architect run idle on acme/widgets: Ready issue #7 "Make widgets" goes first: …`. Everything else is JSON (`:88`, `:138`, `:178`). Stage names are quotable (`:120`): `implement`, `Resume`, `Security review`, `pull request`, `CI watch`, `Repair`, `Self-merge`, `cleanup`.

**5.6 What comes back, and a Failed run.** "Ready" means (`site/index.html:339`): "An open pull request from the Issue branch to the Base branch. It is mergeable, its CI passes, and it has been reviewed against your repository's documented coding standards and against the issue. Otherwise thirdshift doesn't call it ready." Findings the agent declined are "listed as an Unaddressed finding in the pull request body, with the code, plan decision, ADR or focused run that refutes it" (`:340`). A Failed run "ends… without an open pull request from its Issue branch that targets the Base branch, is mergeable and has passing CI" (`docs/guide.md:724`); it "commits any uncommitted work… and pushes the Issue branch, so nothing is lost" and converts an open PR "back to a draft" (`:728-729`). Rerunning is the same command — it "picks up where the last Run stopped" as a "**Continuation**" (`:712-721`) — with the caveat on screen: "A Run is not idempotent: re-running builds on whatever is already on the branch, including a Failed run's work-in-progress commit" (`:722`).

The site's Failed-run block is explicitly hypothetical — "**Illustrative** … Their order is inferred from the code, not seen in a real Run" (`site/index.html:321-329`). **Prefer the one real failure transcript** (`docs/guide.md:745-752`), which prints the retry command:

```
thirdshift: 03:12:40 CI red on test, which also fails on main at 362b9ca; fix main first
thirdshift: 03:12:40 Retry with: thirdshift https://github.com/acme/widgets/issues/7 base-fix
```

**5.7 Scheduling a Pickup run.** "thirdshift has no scheduler of its own… the operating system's scheduler runs the ordinary command" (`:1107`). Verbatim (`:1112-1115`):

```
PATH=/home/you/.local/bin:/home/you/.cargo/bin:/usr/local/bin:/usr/bin:/bin
*/30 * * * * cd ~/repos/widgets && thirdshift pickup base main >> ~/.thirdshift/logs/cron.log 2>&1
```

Narrate three things (`:905`, `:1118`): `PATH` is set "because cron doesn't read your shell profile", and "cron expands neither `~` nor `$HOME` on that line"; `cd` "makes a clone of the repository the **Launch directory**" and `base main` names the Base branch "so the branch checked out in the clone doesn't matter"; and the throttles — "a pass takes one issue, so `*/30` starts at most one every half hour", "at 3 of them, or the `pickup.limit` you set, the passes take nothing until you have dealt with one", and a newly labelled issue "waits thirty minutes by default". Cautious variant: `… pickup base main no-merge` (`:1140`). Add with `crontab -e`, and "end each with a newline" (`:1136`). **Output is real** (`site/index.html:206-207`): `Pickup run starting, 2026-10-12 -0400`, then `taking Ready issue #663 "…", as thirdshift …/issues/663 would`.

**5.8 `help` and `update`.** `help` prints "to stdout and exit `0`" (`docs/guide.md:339-341`); **the real text is `src/main.rs:60-103`**, opening "thirdshift turns a GitHub issue into a ready-for-review pull request, unattended." (`:61`), with `usage:` at `:63-84` and the shared-options block at `:92`. `update` "replaces the installed binary with the latest stable GitHub Release, or says it is already on it. Messages go to stderr and stdout stays empty" (`docs/guide.md:221-223`), and "only replaces a copy put in place by the shell installer", refusing "to touch any other copy" (`:227`). Confirmed at `src/args.rs:236,238`. **Output: not documented for either.**

### 5.9 Output the docs never show — record it or drop the beat

| Beat | Documented output? |
| --- | --- |
| The `curl` installer's own output | **No** (`README.md:13` gives the command only) |
| The `setup` questions | Described, not quoted (`docs/guide.md:465-474`); two strings exist (`:472`, `:476`) |
| `status` / `show` / `logs --follow` human output | **No sample anywhere** — only the idle line (`:82`) and JSON (`:88`, `:138`, `:178`) |
| `thirdshift update` | **No sample** (`:221`) |
| Prerequisite checks | **No sample** |
| A Failed run's stderr | Only the "illustrative" block (`site/index.html:321`) and the real Inherited-failure block (`docs/guide.md:745`) |
| A successful Run's stderr | **Real and complete** (`site/index.html:206-305`; 139 lines, `:316`) |

## Tutorial cut: rules and outline

1. **One real terminal, rehearsed; never a rendered one** (§2). Re-type at human speed, cut every wait with a visible time jump.
2. **Never show a line the binary does not print.** Quote `site/index.html:206-305`, `docs/guide.md:336`, `:745-752` and `src/main.rs:60-103` character for character; record everything else from life.
3. **Caption any placeholder or reconstructed output as illustrative**, as the site does itself (`site/index.html:321`).
4. **Terminal inside the 5% graphics-safe box and in the upper two-thirds**, bottom band reserved for captions (§2, §4).
5. **Test the font size; no standard sets it.** *Inference:* longest line fits ~60–80 columns at 1080p, checked at phone width. Do not import the BBC 7–8% subtitle figure (§2).
6. **Speak every command and state change aloud, and print each one as copyable page text beside the video.** The narration discharges 1.2.3 and 1.2.5 with no AD track ("type this" does not); the page text is the only answer to §2's legibility problem (§4).
7. **Chapter on thirdshift's own sub-goals, not on a clock** — G7's "structural changes such as goal or sub-goal completion" (§3). One chapter per §5 heading, 45–90 s each, 7–10 min total.
8. **Claim chapters as convenience, never as a learning gain** — Ploetzner puts navigational features in the losing baseline (§3).
9. **Preview the task: open on the finished pull request** (G4, §1).
10. **Give the Failed run its own chapter and run the recovery command on screen** — direction borrowed from EMT, magnitude not claimed (§1).
11. **Demonstrate thirdshift's decisions, not git, `gh` or cron syntax** (expertise reversal, §1).
12. **End every chapter on an expected-output frame held still**, and offer the viewer nothing over moving video (Ploetzner's split-attention finding, §3).

| # | Chapter | Beat: command | Expected output to show | Narration gist | Source |
|---|---|---|---|---|---|
| 0 | Where we end up | — | The merged PR and `PR …/pull/665 is merged` | "One issue URL in, one reviewed pull request out." | `site/index.html:305`, `:339`; G4 |
| 1 | Prerequisites | `type thirdshift claude gh git`; `gh auth status` | **Record live — undocumented** | Harness + `gh` + git identity; sessions run as you, unattended, with no approver | `docs/guide.md:240-246`, `:249` |
| 2 | Install | `curl -LsSf …/thirdshift-installer.sh \| sh` | **Record live**; end on the Setup pointer | One binary into `~/.local/bin`; no Rust, no checkout | `README.md:13-15`, `docs/guide.md:211` |
| 3 | Setup | `thirdshift setup` | **Record the transcript**, then the written `config.toml` | Eight questions, Enter takes the default; the file lists every setting | `docs/guide.md:465-474`, `:399-458` |
| 4 | Push first | `git push` before the Run | The rule as on-screen text | "Unpushed commits on the Base branch… push them first, or the Run stops" | `docs/guide.md:343`, `README.md:37` |
| 5 | First Run | `cd ~/repos/widgets`; `thirdshift <Issue URL>` | `labelling #663 in-progress…`, `creating worktree …`, `implement: $ …`, `pushing issue-663`, `CI passed on …`, `PR <url> is ready for review` | Claim, worktree, one session implements *and* reviews, then thirdshift takes over deterministically | `docs/guide.md:268-270`, `:336`; `site/index.html:208-305` |
| 6 | Watching | `thirdshift status`; `thirdshift show 'widgets#7'`; `thirdshift logs … --follow` | **Record live — no sample in docs**; name the stage on screen | Host, live Commands, stage and age; `show` adds the latest event; `logs --follow` tails | `docs/guide.md:76`, `:174`, `:199`; `src/args.rs:254,269,280` |
| 7 | What comes back | The PR body on GitHub | The ready-for-review definition; one Unaddressed finding | "Otherwise thirdshift doesn't call it ready" | `site/index.html:339-340` |
| 8 | When it fails | re-run the same command | `CI red on test, which also fails on main…`; `Retry with: … base-fix` | Work is committed and pushed, the PR drops to draft, the same command continues it — and it is not idempotent | `docs/guide.md:724-729`, `:745-752`, `:712-722` |
| 9 | Merging | `thirdshift merge <Issue URL>` / `--no-merge` | `merging the PR into main`; `PR <url> is merged` | Self-merge only once open, ready, mergeable and green; never GitHub auto-merge | `docs/guide.md:293-296`; `site/index.html:268`, `:304-305`; `src/args.rs:459` |
| 10 | On a schedule | `crontab -e`, paste the `PATH` + `*/30` lines | `Pickup run starting, 2026-10-12 -0400`; `taking Ready issue #663 …` | thirdshift schedules nothing; `PATH` because cron reads no profile; one issue per pass, 3 Claims and it stops | `docs/guide.md:1107-1122`; `site/index.html:206-207` |
| 11 | Help and update | `thirdshift help`; `thirdshift update` | The real help text; **record `update` live** | Where to look next; `update` only touches a shell-installer copy | `src/main.rs:60-103`; `docs/guide.md:221-227` |
