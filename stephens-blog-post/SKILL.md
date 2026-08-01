---
name: stephens-blog-post
description: Write and ship an interactive, teaching-first engineering blog post for stephens.page/blog in Jacob Stephens' expository writing style, with a required AI-agent-oriented agents.md companion. Use when adding, drafting, revising, or publishing a post on stephens.page/blog (the technical blog, not jacobstephens.net). Covers the house HTML template, voice, the "ship real, not facsimile" figure philosophy, agent-facing artifacts, headless verification, and git deploy.
---

# Writing a stephens.page blog post

This skill encodes how posts are built for **stephens.page/blog**. Every canonical
post must sound like Jacob Stephens, even when research, figures, or technical
editing are collaborative. Hand-written personal essays and fiction live at
jacobstephens.net and are out of scope here.

**Source tree:** GitHub [`JacobStephens2/stephens.page`](https://github.com/JacobStephens2/stephens.page).
On the production host the same tree is often checked out at `/var/www/stephens.page`.
Prefer repo-relative paths (`blog/<slug>/...`) when working from a local clone.

The reference post this skill was distilled from is live at
[The Diagram Is Not the Model](https://stephens.page/blog/the-diagram-is-not-the-model/)
(`blog/the-diagram-is-not-the-model/` in the repo). When in doubt, open it and copy its
structure.

## The shape of the work, in order

1. **Read the source material first.** Posts start from Jacob's own artifacts:
   model-council notes, talk notes, profiling reports, commit history, an ADR, a
   working design doc - whatever he points you at. Read all of it before writing a
   line. The post's job is to *teach* what those notes contain, not to summarize them.
2. **Find the thesis.** State the single load-bearing idea in sentence one (see Voice).
   Everything else is scaffolding for it.
3. **Pick the teaching techniques.** Education concepts applied deliberately (from
   notes on Geoffrey Litt's "Understanding: the New Bottleneck"): intuition before
   detail, **demonstration, visualization, animation, interaction**,
   predict-observe-explain, micro-worlds, and a **quiz at the end** ("don't merge
   until you can pass the quiz"). Map each core idea to the technique that fits it.
4. **Build the page** from the house template (`references/post-template.html`).
5. **Build the figures for real** (see "Ship real, not facsimile").
6. **Verify headless** in light and dark, driving every interaction (see
   `references/verification.md`). Zero console errors is the bar.
7. **Add the blog-index entry** at the top of `blog/index.html` in the site repo.
8. **Add a Sources section and the provenance note** (see Structure).
9. **Build the required agent-oriented version** at `agents.md` (see "Required
   agent-oriented version" below). A post is not complete without it.
10. **Commit, push, verify live** (see Deploy).

## Voice - write as Jacob

For agents using this skill, **`references/voice.md` is the operational source of
truth** (expository register). The non-negotiables that show up in every post:

- **Write in Jacob's voice from the first draft.** Do not produce neutral,
  institutional, or generic collaborative prose and offer an own-voice rewrite
  later. The canonical post is the own-voice version.
- **Point/result first, mechanism second.** Thesis in sentence one. No preamble.
- **Name the exact specific thing** - the file, the version (`mermaid.js v11`), the
  function (`snapshot.can(...)`), the number, the named authority (Litt, Matuschak,
  Papert, Kay, Goldratt). Never gesture at a referent you could name.
- **Anchor claims to named authorities and frameworks**, then translate into something
  concrete and runnable.
- **Never use em-dashes.** Use a spaced hyphen ( - ) everywhere an em-dash would go.
  This is a hard rule; grep the final file for the character and confirm zero.
- **Count things.** Put numbers on claims (attempts per item, ms, items/day, ΔE).
- **Descriptive, argument-walking headings**, never mechanical "Part 1 / Section 2".
  Question-style headings are good ("You can't see a bottleneck in a flowchart").
- **End humble and open.** Close on a "What's still open" section that names the real
  uncertainty rather than forcing a tidy win.
- **No filler, no flattery, no AI-isms.** Cut "delve", "moreover", "great question".
- **Answer the obvious objection in-line.** When you assert a design choice, name the
  fair counter-argument and refute it (e.g. "Mermaid is text too, so why JSON?").

Write posts in Jacob's voice unless he says otherwise. Use the canonical live post
[The Diagram Is Not the Model](https://stephens.page/blog/the-diagram-is-not-the-model/)
as the prose exemplar: personal stakes are named, transitions are direct, dry lines
are allowed, and technical paragraphs keep exact versions, units, objections, and
authorities. Provenance must describe the collaboration honestly without changing
the voice into an AI house style.

## Ship real, not facsimile

This is the strongest single preference. Jacob pushed twice on the reference post:
*"should actually render real Mermaid and React Flow"* and *"Ship React Flow and XState
live demonstrations."* A figure that *looks* interactive but is faked is worse than none.

- **Run the genuine library in the browser** whenever one exists. The reference post
  ships mermaid.js, React Flow (`@xyflow/react`), XState, and Graphviz (viz-js WASM),
  all live.
- **When the real renderer is too heavy for the browser, use a real service and say so.**
  D2's renderer is a large Go/WASM binary, so the reference post renders D2 via the
  **Kroki** service and labels it plainly. The honest split ("browser-renderable vs
  render-in-CI") is itself a teaching point - do not hide it.
- **Hand-build only when the implementation itself teaches the point.** Browser-capable
  DES libraries exist (including SimScript and SimPy through Pyodide). The reference
  post's first factory simulation is hand-built vanilla SVG because exposing the queue,
  capacity, and rework arithmetic is the lesson; its sequel demonstrates the real
  libraries. Never claim that a hand-built figure proves no browser library exists.
- **Every figure carries a fallback.** If a CDN is unreachable, degrade to a hand-drawn
  SVG, a static image, state chips, or a message-plus-link - never a blank box.
- **State exactly how each figure renders** in the caption and the provenance note, so
  a reader is never misled about what is live.

See `references/figure-patterns.md` for the concrete recipes (CDN URLs, theming via CSS
variables, theme-toggle re-render, click-to-load for heavy libs, lazy-load on
IntersectionObserver, `prefers-reduced-motion`).

## Page structure and house style

- One self-contained file: `blog/<kebab-slug>/index.html` in the stephens.page repo
  (live as `/blog/<kebab-slug>/`).
- Copy the head boilerplate verbatim from `references/post-template.html`: the inline
  theme bootstrap script, favicon `/bee-favicon.png`, viewport, `<title> | Jacob
  Stephens`, description + og + twitter meta, the gtag block, the Source Serif 4 /
  Source Sans 3 Google Font link, the page-local `:root` tokens, `theme.css`, `theme.js`.
- Body: `.container` > `.topbar` (All posts / Source on GitHub / email) >
  `article.note` with `.eyebrow`, `h1.title`, `.meta` (date, ~word count, figure
  count), then the prose and figures. Point the source link at
  `https://github.com/JacobStephens2/stephens.page/tree/main/blog/<slug>/` so readers
  can inspect every file shipped with the post.
- Figures use the `.fig / .fig-head / .fig-body / .fig-caption` component. Number them
  `Fig. N` in order and keep every cross-reference in sync (renumbering is the easiest
  thing to get wrong - grep `Fig\. \d` and check the sequence after any insertion).
- Close with: a **Sources** section (two groups - "Ideas and authorities" with
  author/title/year, and "Tools demonstrated or referenced" with links), then the
  `.ai-note` **provenance box** stating what was drafted from, which figures run which
  real tools, and the actual division of work. Prefer concrete language such as
  "The decisions, the [work], and the words are mine; Claude was the technical
  collaborator" when that is true.
- Footer with the auto-year script, then `/blog/newsletter-widget.js`.
- Load heavy in-browser libraries (mermaid, xstate) via a bottom `<script type="module">`
  with dynamic `import(...).then(...).catch(...)`; call into the main IIFE via
  `window.__onX` hooks so the fallback path is clean.

## Required agent-oriented version

Every post ships as two artifacts:

- **The canonical human post** at `/blog/<slug>/`, written in Jacob's expository
  voice and listed once in the blog index. Do not create a parallel
  `<slug>-my-voice` version. If a legacy voice variant exists, consolidate its prose
  into the canonical URL and 301 redirect the old path.
- **The required agent-oriented version** at `/blog/<slug>/agents.md` - raw markdown
  (Apache
  serves `.md` as `text/markdown`), YAML frontmatter (title, audience, canonical
  URL, date, license matching the repo's LICENSE - MIT, don't invent one). Recast
  the ideas as operational directives to the reading agent; inline every diagram
  source, schema, adapter, and reference implementation needed to act without a
  browser; replace interactive figures with closed-form math plus verified numbers
  in tables; preserve uncertainty and runtime/version details; end with an
  operational checklist and a self-test with answers inline. Link it from the
  canonical post FOUR ways: in the
  `.meta` line at the top ("reading this as an AI agent? agents.md is for you"),
  a `<link rel="alternate" type="text/markdown">` in the head, an HTML comment at
  the top of the head for agents reading raw HTML, and a "For AI agents:" paragraph
  at the bottom.

Before shipping, fetch `agents.md` over HTTP and verify `200`, a Markdown content
type, the canonical human URL, all verified figures/numbers used by the human post,
the checklist, and the self-test. The agent artifact is a deliverable, not a summary
added if time remains.

Citations: when Jacob attended the talk or event being cited, link the specific
recording (he supplied the exact YouTube URL for Litt's talk) and say "talk I
attended" - never a generic homepage when a specific artifact exists.

## Deploy

- Repo: GitHub [`JacobStephens2/stephens.page`](https://github.com/JacobStephens2/stephens.page).
  On the production host, that tree is typically `/var/www/stephens.page` and is
  tree-is-live - editing the file is the deploy; commit + push is the record.
- Commit as Jacob Stephens. **Do not add a Claude (or other agent) co-author trailer**
  unless Jacob explicitly asks for one.
- Write a real commit body: what changed and why, and one line on how it was verified.
- `git push origin main`, then `curl` the live URL (expect 200) and grep for a
  distinctive new string to confirm it deployed.

## Reference files

- `references/post-template.html` - the house HTML skeleton to start from.
- `references/figure-patterns.md` - live-figure recipes, theming, fallbacks, CDNs.
- `references/verification.md` - the headless-Chrome + Node stub-DOM verification protocol.
- `references/voice.md` - the condensed voice checklist and the em-dash guard.
