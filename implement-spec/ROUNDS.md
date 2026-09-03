# Rounds

A **round** is one subagent run on a ticket's branch. This file is the shell for it: how a round is spawned, pinned to its worktree, continued, and read. The judgment stays in [`SKILL.md`](SKILL.md).

## Spawning

Spawn a round with your harness's own subagent, in the background when it offers that, and read what it returns. Only the round's report reaches your context; the ledger is the only review text you hold. A subagent starts in your working directory, the primary checkout, not the worktree: every prompt pins the worktree by absolute path, and the round works, searches, and commits only under it. Record the round's subagent id in the chart's `Now` so you can continue it after a compaction.

Four kinds of round, each a prompt of a few facts:

- **Implementation**: `Read <absolute path to implement/SKILL.md> and follow it for <ticket reference>. Work only in <absolute worktree path>, on its branch. Commit there; do not push, open a PR, or close the ticket. Append your report to <agent-logs>/issue-<n>.md.` The ticket is the brief.
- **Review**: `In <absolute worktree path>, run /code-review <fixed-point>. The originating ticket is <ticket reference>: fetch it with the workflow in docs/agents/issue-tracker.md. Report only; edit nothing. Write the report to <agent-logs>/review-<n>.md.` The initial review's fixed point is the merge-base of the ticket branch and its land base. `/code-review` may fan out to its own sub-agents; only its summary returns to the round.
- **Adjudication**: `Read <ticket reference> with its comments, the review at <agent-logs>/review-<n>.md, the diff in <absolute worktree path> since <merge-base>, and every test that diff adds. Judge each finding against the ticket's criteria, the spec traps and standing rules in <chart path>, and concrete correctness, security, data-loss, or external-side-effect failures. Write <agent-logs>/findings-<n>.md: first line reviewed-head: <full sha>; then each blocker with its authority, its evidence on that head, and the outcome that closes it; then suggestions, separately. Edit nothing else.`
- **Correction verification**: the review prompt plus the ledger: `This is a correction verification against a fixed approval bar. Read the blocker ledger at <ledger path>. Verify each recorded blocker against current HEAD and report concrete regressions in the correction diff after <reviewed-head>. Keep pre-existing architectural alternatives and preferences as suggestions, not blockers.` Its fixed point is the ledger's `reviewed-head`.

## Continuing

A correction goes to the implementation round's own subagent: continue it with the ledger's path and `Close every blocker in the ledger; commit on the branch; do not push.` When your harness cannot continue a finished subagent, or the round predates this session, spawn a fresh implementation round on the branch with the ledger path in place of the skill path. A merge round is the same continue, with the prompt from [`MERGE-ROUND.md`](MERGE-ROUND.md).

## Scripts

Run them by absolute path from this skill's `scripts/` folder. They find the primary checkout from your working directory and read the default branch from the remote rather than assume it.

- `scripts/suite-capture.sh <worktree-name> <label> -- <command>...`: runs `<command>` in the worktree, logs it to `worktrees/agent-logs/suite-gate-<label>.log`, and prints the exit code and the log's tail. `<command>` is the suite command from the chart. Piping a suite through `tail` yourself reports the exit code of `tail` and hides the summary; the script is how you read a suite.
- `scripts/land.sh [--dry-run] [--wait-checks] <issue> <worktree-name> <title> <body-file> [<base-ref>]`: GitHub. Pushes and opens the PR from the worktree, merges it from the primary checkout, deletes the remote branch, fast-forwards the local land-base ref, and prints the merge hash and the issue's state. Refuses a dirty worktree or a land base not yet merged into the tip; the second refusal means a merge round first. `--wait-checks` holds the merge until the PR's checks pass and stops without merging when one fails: use it from the first ticket that gives the repo CI onward, and always when a merge triggers a deploy. When the token cannot read PR checks, it reads the Actions runs for the tip instead. Run it with `--dry-run` first to print the commands.

When `land.sh` prints that it could not fast-forward the local land-base ref, from the primary: `git merge --ff-only origin/<base>`.

## Traps

Each cost a round or a wrong reading once.

- A subagent's search from the session's working directory finds the primary checkout's files, and an edit there lands outside the branch. Pin the worktree in every prompt; a report that names paths outside it is a round to redo.
- A test that hard-codes the primary checkout's absolute path loads two copies of one library from a worktree and dies on a redeclare, and skips itself on a CI runner that has no such path. Before the first round, run the suite **in the worktree**, not only in the primary checkout. If some tests cannot run there, exclude them by name in a gate script and have it **print how many it excluded**, so a run that covered less than the suite never reads like one that covered all of it. Then write your own tests with paths relative to the test file, the way the excluded ones should have been.
- The ticket-fetch line in every round prompt is worth testing once yourself. A tracker CLI that renders for a terminal can print nothing at all when its output is redirected to a file, and a round that fetched an empty ticket implements the prompt instead.
- Two rounds in one worktree at once corrupt both. A round runs to its report before the next spawns in that worktree, and the suite capture runs between rounds, not beside one.
- A silent round isn't a stalled round. A suite or a review sub-agent runs for twenty minutes without a line. Read the worktree's git log before you stop anything.
- The implementer's "N tests OK" isn't the gate. Your captured run is, after every correction too.
- An install copied into a worktree, used as the interpreter without the repo's own test entrypoint, isn't that file. Run the charted command.
- The ticket's own new tests are where "a rule weakened to keep a test green" shows up first. The adjudication round reads each new test's filters against the criterion's words.
- Put the checks a spec repeats at every gate into one script at the first gate, and diff against the merge-base: `git diff origin/<default>..HEAD` counts turn false the moment the base moves.
- A conflict-resolution script gates `git add` on its own success. A replacement that failed and a `git add` that ran anyway stages the conflict markers, and the merge commits them.
- Merging a PR from the ticket worktree tries to delete the branch that worktree is on and stops at "used by worktree". `land.sh` merges from the primary checkout for that reason.
