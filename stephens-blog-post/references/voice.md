# Voice checklist

For agents using this skill, **this file is the operational source of truth** for the
expository register on stephens.page/blog. (Jacob may keep a fuller private style
guide; do not depend on paths outside this skill.)

Run this against the draft before committing:

1. **Thesis in sentence one.** The single load-bearing idea leads. No warm-up.
2. **Every referent is named exactly** - file path, version string, function name, the
   number, the person. If you wrote "a library" or "recently", name it or date it.
3. **Claims are anchored** to a named authority/framework, then made concrete and
   runnable. Floating assertions get an anchor or get cut.
4. **Zero em-dashes.** Spaced hyphen ( - ) only. `grep` the character (U+2014) - must be 0.
   (En-dashes U+2013 are fine inside code strings only.)
5. **Numbers on claims.** Counts, times, rates, with units spelled out (e.g. "coding
   attempts per shipped item", "agent-minutes", "items/day"). If a formula appears,
   define its variables and give units.
6. **Headings walk the argument** and are descriptive or question-style. Never "Part 1".
7. **The obvious objection is answered in-line**, not left for the reader to raise.
8. **Ends on "What's still open"** - name the genuine uncertainty; do not force closure.
9. **No filler / flattery / AI-isms.** Cut "delve", "moreover", "it's worth noting",
   "great question", "in today's fast-paced".
10. **Dry, deadpan wit is welcome**; effusiveness is not.

## Framing conventions specific to stephens.page/blog

- The canonical post must be written in Jacob's expository register from the first
  draft. Do not create generic collaborative prose and defer voice to a second URL.
- Use the live post
  [The Diagram Is Not the Model](https://stephens.page/blog/the-diagram-is-not-the-model/)
  (repo path `blog/the-diagram-is-not-the-model/index.html`) as a prose calibration
  sample: direct personal stakes, exact technical referents, concrete verbs, dry wit,
  and no loss of units or qualifications.
- The `.meta` line carries: **date**, **~word count**, and **figure count**
  ("6 live figures and a quiz"), plus the `agents.md` link.
- The top bar links to the post's folder in `JacobStephens2/stephens.page`, not only
  the rendered page, so readers can inspect every source and supporting artifact.
- Close with a **Sources** section (Ideas and authorities: author, title, year; Tools:
  name + link) and the **provenance `.ai-note`**: what it was drafted from, which
  figures run which real tools, and the actual division of authorship and technical
  collaboration.
- Every post includes `/blog/<slug>/agents.md`; no post is complete until the agent
  version, its four discovery links, checklist, and self-test are verified.
- The two-blog split: stephens.page/blog = technical writeups in Jacob's expository
  voice (this skill); jacobstephens.net/blog = personal essays/fiction (not this
  skill).

## How Jacob iterates (expect these asks)

He pushes for more realness and more clarity. Anticipate:
- "This should actually render real X" - never fake a demonstration.
- "Make it even clearer why" - answer the objection, add the units, show the loss.
- "Add sources." - keep a real bibliography.
- Renumbering and cross-reference drift after inserting a figure - always re-check.
