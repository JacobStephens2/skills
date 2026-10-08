# Grilling file template

The file a grill-with-docs session writes its rounds into, one file per issue in this folder, named like `428-more-harnesses.md`. The session itself (design tree, frontier, recommendations, `CONTEXT.md`, ADRs) follows the `grilling` and `domain-modeling` skills. This file covers only how the rounds are written down.

## Writing a round

1. **Re-read the whole file.** Jacob's editor can save a stale copy over rounds added since he opened it. Put back anything missing, and keep every answer he wrote.
2. **Record the answers.** Mark the round `(answered)`. Put any facts you checked in reply under the answer they bear on, as `*Checked:* …`.
3. **List what follows from the answers** under "Settled by earlier answers": every consequence they imply, so that nothing settled stays unspoken.
4. **Write the next frontier** as `## Round N (open)`, numbering questions on from the last. Each question ends on a blank answer line.
5. **Move research.** Findings go to "Research results", with how each was confirmed. Pending work goes to "Waiting on research", naming the questions that wait on it.
6. **Reply in chat** with a few lines that point at the file.

The round is done when every question in the file has an answer line, every open answer line is exactly `*Answer:* ` (with the trailing space), and every round Jacob answered says `(answered)`.

## The answer line

`*Answer:* `, with one space after the closing `*`. Jacob writes in Flintmark, where a click at the end of the line then puts the cursor after the italic, so his typing lands outside it. "agree" means he accepts the recommendation.

## Layout

```markdown
# Grilling: #<n>, <title>

Issue: <url>
Research: <links>

## Round 1 (answered)

**Q1 - <title>.** <question and options>

*Answer:* <answer>

## Round N (open)

**QN - <title>.** <What has to be decided, why it matters, and which settled answers it builds on.> The options:
- (a) <option>
- (b) <option>

*Recommended:* (a). <Why.>

*Answer:* 

## Settled by earlier answers (shout if any is wrong)

- <a consequence of answers already given>

## Research results (<date>)

- <fact>, confirmed by <test | help | docs | source>

## Waiting on research

- <what an agent is finding out>, for <QN>
```
