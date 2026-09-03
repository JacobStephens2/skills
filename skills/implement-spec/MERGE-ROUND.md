# Merge round

The prompt for continuing a ticket's round when the land base moved under it: a push by the human, CI, or a landing outside this spec. Fill the angle brackets from the chart and the diff, and keep the rest. The agent merges; you gate the result as you gate any finished branch.

```text
<land base> has moved under your branch: <what moved it> touches <the files the diff names>. Merge <land base> into this branch now - a merge commit, not a rebase, so nothing already reviewed is rewritten. Do not push.

1. `git fetch origin && git merge origin/<land base>`. Expect conflicts in <the files>.

2. In source files keep both sides' additions; the union is the answer. For docstrings and comments take <land base>'s wording and add only what this ticket needs to say.

3. Never hand-merge a generated file. Resolve <each generated file> by regenerating: <the regeneration commands>. Restate <each count, constant, or summary the ticket owns> for the combined tree; <its arithmetic rule>.

4. If you regenerated, regenerate once more from a clean state and confirm `git status` shows no generated file differing from what you commit. Run the full suite with <the charted suite command>. Commit the merge with a message naming what you merged over.

5. Loop until current: after the suite is green, `git fetch origin` again. If <land base> moved, merge it the same way, re-run the suite, and repeat. Stop only when `git merge-base --is-ancestor origin/<land base> HEAD` holds at the moment you commit.

Finish with a short report: what you merged, the conflicts you resolved, and the suite result.
```

For a branch with no generated file and no restated count, item 3 collapses to one line: migrate what the merge brought in under the ticket's own rule, and name each file. Drop any numbered item the chart has nothing to fill. Add a numbered item for anything the ticket's reviews found, so one round answers both.
