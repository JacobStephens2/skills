---
name: implement-spec
description: Drive a spec's tickets in dependency order, with a subagent per ticket, independent verification, and gated landing.
disable-model-invocation: true
argument-hint: "<spec>"
---

Run the `/implement` loop for a whole spec. You chart, gate, and land; subagents
implement, review, and correct. Run one ticket round at a time in its own worktree.
The **frontier** is the open `ready-for-agent` tickets whose blockers are closed;
choose the lowest-numbered one. Keep `ready-for-human` tickets visible for handoff.

Use the project's tracker instructions and triage labels. Read
[`ROUNDS.md`](ROUNDS.md) before dispatching. Keep the run's state in a copy of
[`CHART.md`](CHART.md) at `worktrees/agent-logs/spec-<id>-chart.md`.

## Chart

If a chart exists, go to Restart. Otherwise:

1. Read the spec, tickets, comments, and tracker blocking edges. Reconcile missing
   edges with the written dependencies. Identify each ticket's **land base** from
   the requested branch workflow; default to the repository's default branch.
   Read [`LAND-BASE.md`](LAND-BASE.md) when using an integration branch.
2. Check tracker access and credentials, branch protection, required
   reviews/checks, and merge authority now. Record any human step. A protected
   branch is a handoff, not permission to change the workflow or bypass its
   rules. Fetch the land base and fast-forward its clean checkout, preserving
   unrelated work.
3. Read repository instructions and environment policy. Locate `/implement` and
   `/code-review` by absolute path. Record coding standards, landing convention,
   suite commands, dependencies, configuration and post-merge checks.
4. Establish the baseline in a permitted test environment. Record failures,
   skips, and exclusions by name and explain their coverage. Verify paths named
   by the spec exist. Probe uncertain claims through the relevant code, including
   the writers of values whose meaning the spec relies on; keep probes within
   the authorized environment and side effects.
5. Map acceptance criteria to evidence, including what green tests cannot prove:
   real delivery, UI behavior, artifact integrity, migration preservation, or a
   human decision. For tickets requiring deployment or external activation, read
   [`ROLLOUT.md`](ROLLOUT.md) and chart those remaining phases separately.

The chart is ready when each ticket has a base and evidence requirements, and
`Now` identifies the next round or concrete hold. Share settled standing rules
on the open tickets so their implementers and reviewers see them.

## Implement

1. Fetch the next ticket's land base. Cut `worktrees/issue-<id>-<slug>` from its tip
   and exclude local worktrees from Git, including shared virtualenv or dependency
   symlinks in `.git/info/exclude` so landing sees a clean tree. Prepare matching
   dependencies and safe ignored configuration; a worktree does not isolate
   databases or providers.
2. Capture the baseline with `scripts/suite-capture.sh`. Resolve unexpected
   differences before attributing them to the ticket. A known baseline failure
   is not permission to skip a required acceptance check.
3. Dispatch the implementation round using ROUNDS. The ticket and its comments
   are the brief; the chart holds shared constraints.
4. Gate its result, then land it. If the land base advanced, use
   [`MERGE-ROUND.md`](MERGE-ROUND.md) and gate the combined result first.

## Gate

1. Independently run the charted suite and extra checks on the candidate commit.
   Check every criterion against observed evidence. Record the SHA, commands,
   results, skips and limits; an implementer's reported count is not verification.
2. Run one independent full review against the ticket's recorded starting commit.
   Adjudicate it into `worktrees/agent-logs/findings-<id>.md`, beginning with
   `reviewed-head: <full sha>`. Each blocker names its authority, evidence and
   closing outcome. Keep suggestions separate. Give the adjudicator the captured
   evidence to inspect, rather than treating the orchestrator's claims as settled.
3. Send blockers to the ticket's implementer. After correction, rerun affected
   checks and required gates. Verify the ledger and concrete regressions in the
   correction diff. Keep its original `reviewed-head`; a new architectural
   preference does not reopen the approval bar.

The gate clears when required evidence passes and all blockers close. If the same
blocker survives two correction rounds, or its authority is disputed, hold it for
human resolution. A missing required live check remains open even when CI passes.

## Land

Use `scripts/land.sh --reviewed-head <gated-sha> --dry-run` first, then `--wait-checks` when the project has CI
or merging triggers deployment. The helper pins the candidate commit, rechecks
current CI and the base, and merges through normal repository policy. A canceled
run, pending rerun, missing evidence, changed head or unreadable check state is
not success. Its bounded wait can be resumed against the existing PR.

Land only the reviewed, tested tree. After merge, fast-forward the land base and
watch applicable post-merge checks. Fix a new failure through the same reviewed
branch workflow. Close a ticket only when its acceptance criteria are complete;
use `Refs #<id>` for preparation that leaves rollout work open. Integration merges
and rollout completion follow their respective references.

Update `Now` immediately with the merge, remaining phase, or exact blocker. Then
recompute the frontier. A required human review gets a ready PR and handoff while
you continue independent authorized work.

## Hold

Raise a spec conflict on the spec with evidence and a concrete recommendation.
Keep the affected branch unmerged and continue other unblocked tickets. Record
the user's ruling once in the tracker and align the affected ticket bodies.
Distinguish that decision from an access problem, branch rule, or missing test.
Ask only for the unresolved requirement; prior authorization remains in force.

## Restart

Read the chart and this skill, then refresh tracker state, branches, PRs and
checks. For a release, refresh live state too. Resume the recorded phase:
unfinished round, correction, gate, existing PR, rollout, or human hold. A merged
branch with open rollout criteria needs rollout work, not another implementation.
Replace stale `Now` entries; keep historical evidence separate from current state.

## Finish

Before the final release PR, validate the combined tree, including changes from
its destination branch. Run the full applicable suite in a permitted environment
and account for earlier exclusions; a primary checkout is not inherently safer
or better configured. Reuse evidence only when the tested code and relevant
runtime have not changed.

When no authorized work remains, report landings, evidence, decisions and exact
handoffs on the spec and to the user, including material mistakes and their
resolution. Close the spec only when every ticket and required rollout is done.
Follow-up suggestions do not expand merge authority: put separately requested
improvements up as PRs for human review.
