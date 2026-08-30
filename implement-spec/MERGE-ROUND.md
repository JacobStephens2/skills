# Merge round

This is the prompt a branch's own agent gets, through `scripts/resume.sh`, when the land base has moved under it and the next landing is its. Write the branch's real name into the prompt. The agent must not guess it. The agent merges, and the orchestrator gates the result as it gates any finished branch. Fill the angle brackets from the chart and keep the rest.

```text
Your branch is next to land, and <land base> has moved: <the sibling tickets that merged> touch the same files. Merge <land base> into this branch now - a merge commit, not a rebase, so nothing already reviewed is rewritten. Do not push.

1. `git fetch origin && git merge origin/<land base>`. Expect conflicts in <the files the chart named>.

2. In source files keep both sides' additions; the union is the answer. For docstrings and comments take <land base>'s wording and add only what this ticket needs to say.

3. Never hand-merge a generated file. Resolve <each generated file> by regenerating: <the regeneration commands>. Restate <each count, constant, or summary the ticket owns> for the combined tree; <its arithmetic rule>.

4. In the prose every count that names <what the chart listed> is the combined figure with its scope stated; keep <land base>'s sentences about the sibling tickets and add this ticket's beside them.

5. If you regenerated, regenerate once more from a clean state and confirm `git status` shows no generated file differing from what you commit. Run the full suite with <the charted suite command>. Commit the merge with a message naming the siblings merged over.

6. Loop until current: after the suite is green, `git fetch origin` again. If <land base> moved, merge it, resolve and migrate the same way, re-run the suite, and repeat. Stop only when `git merge-base --is-ancestor origin/<land base> HEAD` holds at the moment you commit.

Finish with a short report: every landing merged, the conflicts you resolved, and the suite result.
```

For a ticket with no generated file and no restated count - a tests-only ticket - items 2 to 4 collapse to one: migrate what the merge brought in under the ticket's own rule, and name each file.

The template caches what the agent can't see from the tree: which files carry typed counts, that generated files come from regeneration rather than hand resolution, and that a test asserting the complete list equals this batch breaks on the next landing. Drop any numbered item the chart has nothing to fill. Add a numbered item for anything the ticket's reviews found, so one round answers both.
