# Rounds

A round is a subagent run in the ticket worktree. Use the harness's native
subagents, pin every prompt to an absolute worktree path, and record the agent
identifier in the chart. Only one round edits that worktree at a time; gates run
after edits stop. Resume the same implementer for corrections when possible.

## Prompts

Supply references rather than copying the ticket into a second spec:

- **Implement:** Read `<implement/SKILL.md>` and follow it for `<ticket and
  comments>`. Work only in `<worktree>` on its feature branch. Commit there;
  leave pushing, PRs and ticket closure to the orchestrator. Append your report
  to `<agent-logs>/issue-<id>.md`.
- **Review:** In `<worktree>`, follow `<code-review/SKILL.md>` against
  `<recorded starting commit>`. The brief is `<ticket and comments>`, with shared
  rules in `<chart>`. Edit nothing; write `<agent-logs>/review-<id>.md`.
- **Adjudicate:** Read the ticket, chart, review, captured evidence, diff and its
  tests. Write `<agent-logs>/findings-<id>.md` with `reviewed-head: <full sha>`,
  then blockers (authority, evidence, closing outcome) and separate suggestions.
  Edit nothing else.
- **Correct:** Close the blockers in `<ledger>`, working only in `<worktree>`.
  Commit corrections without pushing. Report evidence for each closing outcome.
- **Verify corrections:** In `<worktree>`, verify `<ledger>` against current HEAD
  and inspect the diff since its `reviewed-head` for concrete regressions. Keep
  unrelated preferences as suggestions. Record outcomes without moving that SHA.

A quiet round may be running tests or its own reviewers. Inspect its status and
worktree before interrupting it. If an agent is unavailable after restart, give a
fresh round the same branch, chart and ledger instead of restarting the ticket.

## Helpers

Run helpers by absolute path from this skill's `scripts/` directory. They locate
the primary checkout from Git, including when invoked inside a ticket worktree.

- `suite-capture.sh <worktree-name> <label> -- <command>...` captures output under
  `worktrees/agent-logs/`, prints a short tail and returns the command's exit code.
  Arguments are preserved. For a compound command, explicitly pass
  `bash -c '<commands>'`; do not turn an argument array into shell source.
- `land.sh --reviewed-head <sha> [--dry-run] [--wait-checks] <issue> <worktree-name> <title> <body-file>
  [<base-ref>]` pushes and creates or resumes the branch's PR. It merges from the
  primary checkout and deletes the ticket branch only after verifying the merge.
  A required review or unavailable CI evidence leaves the PR open for handoff.

GitHub's merge precondition pins the head, not the base. The helper refreshes the
base immediately before merging and checks the PR's own merged tree afterward.
For concurrent landings, use existing server-enforced up-to-date checks or a merge
queue where configured; otherwise coordinate with other landers. An unexpected
merged tree is a failed landing requiring reviewed remediation, even though the
merge already happened. The helper retains the branch; it cannot undo that race.

When CI applies, `--wait-checks` requires readable, nonempty PR checks for the
candidate SHA. Without that flag, missing checks are allowed, but any reported
pending or failed check still prevents merge. Success, neutral and skipped are the supported terminal results;
a required test that was skipped still needs coverage at the skill's gate. The
helper has a bounded wait and does not use an Actions-only fallback, which cannot
prove the full PR check set. After a canceled run is rerun, invoke it again.

If the helper cannot fast-forward a checked-out land base, update that clean
checkout with `git merge --ff-only origin/<base>`. Run helper regression tests
with `bash <skill>/tests/land-seam.sh`; they use temporary repositories and fake
GitHub responses, with no live remote mutations.
