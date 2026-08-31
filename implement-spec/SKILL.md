---
name: implement-spec
description: Orchestrate a spec issue to done - one grok agent per ticket, each in its own worktree, landed one branch at a time as the blocking graph unblocks them.
disable-model-invocation: true
argument-hint: "<spec issue URL, number, or path>"
---

This is the loop `/ask-matt` describes after `/to-tickets`: `/implement` per ticket, a fresh context each time, worked from the **frontier**. A spec arrives as tickets with blocking edges. The **frontier** is the open `ready-for-agent` tickets whose blockers are all closed. This skill drives those to closed; `ready-for-human` tickets stay on the chart until the human closes them. The unit of work is a **round**: one detached `va grok --always-approve` run of `/implement` in the ticket's own worktree. A finished branch clears a **gate** before it **lands**. After every landing, you recompute the frontier. You orchestrate. The agents implement and answer review. You land.

The issue tracker and triage label vocabulary should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`. `docs/agents/issue-tracker.md` holds the forms for sub-issues and blocking edges. [`ROUNDS.md`](ROUNDS.md) is the shell for rounds - launching, resuming, reviewing, and watching - with the scripts beside it in `scripts/`. Read it before the first launch. When a ticket's land base isn't the default branch, read [`LAND-BASE.md`](LAND-BASE.md).

## Chart the spec

1. Read the spec, every ticket with its comments, its triage label, and the blocking edges. The tracker's edges are the gate (native `blocked_by` on a real tracker; `Blocked by` lines in local files). A "Blocked by" line in a body is the author's intent at writing time. When a body names a dependency the tracker lacks, add it as a tracker edge before launch, so that you compute the frontier from one source.
2. For every ticket, write the **land base**: the branch its merge targets. The default is the repo's default branch. A ticket that names an integration branch, or says not to merge it independently to that default, names a different base.
3. Read the last few landings and fix the convention: title in the repo's voice, the tracker's close-on-merge line as the body's first line, a merge commit, and the remote branch deleted afterward.
4. Write down the spec's own traps: the things it says a green suite doesn't prove (a visual check, a byte-identical artifact, a test committed red before its fix). Each is a gate item for the ticket it names. A criterion only a human can witness is a trap on the ticket that owns the witness. The `ready-for-agent` ticket's gate is the mechanical inspection that makes that witness possible. Read extra gate commands from the environment: CI config, a test README, anything under `docs/agents/`. Resolve every path a ticket names against the land base with `git cat-file -e <base>:<path>`. A path that isn't there is someone's untracked draft, and the ticket lands without it. Settle any mismatch with the ticket body in a comment before launch.
5. Find the **suite command** that covers the tickets' code, from the environment (`package.json` `test`/`check`, a Makefile target, CI, a test README) and what a worktree needs to run it (a `.venv`, `node_modules`). A repo with more than one suite gets the suite the tickets change. Write both in the table.
6. **Probe** every claim the spec makes about what production does or lacks, on the land base, before the first launch: feed the shape through the production path and read the result. A claim that fails the probe is a spec finding. Raise it under `Raise, hold, continue` before a round writes a test to it.
7. Name the other specs in flight on the same land base - their `worktrees/agent-logs/spec-*-chart.md`, their running agents - and the files their open tickets change. Each of their landings costs this spec a merge before its next landing.
8. Write the **standing rules**: the repo's documented coding standards that apply to every ticket.

Done when `worktrees/agent-logs/spec-<id>-chart.md` holds the table: ticket, blockers, label, worktree, land base, the gate items that are its own, the suite command, the standing rules, and the siblings that move the base. `<id>` is the spec issue number, or the file stem for a local spec.

## Prepare worktrees

Fast-forward the primary checkout onto the land base. Make one worktree per open `ready-for-agent` ticket, `worktrees/issue-<n>-<slug>`, off that tip. Add `worktrees/` to the primary checkout's `.gitignore` so git leaves the directory untracked. Install what the suite needs in each worktree, copied from a land-base checkout when cheaper than reinstalling. An install copied from before a dependency landed isn't that file. Capture the suite once at that tip with the charted command. Done when each worktree is clean at the land base's tip and one captured suite at that tip is green.

## Launch the frontier

Comment the standing rules on every open ticket before the first launch: the implementer's review sub-agent reads the ticket's comments before the implementer commits. Launch each frontier ticket with `scripts/launch.sh` and arm a watch. Run three or four at a time across every session on the box. The limit is the box's memory, not the graph. The prompt is exactly `/implement <ticket>`. The ticket is the brief, and a prompt that restates it becomes a second spec the agent has to reconcile. Done when every frontier ticket has a round running or finished.

## Gate a finished branch

1. **Check every acceptance criterion, mechanically where a command can.** Capture the suite with `scripts/suite-capture.sh` and the charted command into `worktrees/agent-logs/`. The implementer's reported count isn't the gate. Run the extra gate commands from the table. Read each test the ticket asked for against the criterion's words: a filter that admits what the criterion forbids is a weakened rule, not a passing test. Put the checks a spec repeats at every gate into one script at the first gate, diffed against the merge-base. The agent's report covers what no command can. Read it against the ticket's criteria, one by one.
2. **Check the spec's traps for this ticket**, from your table.
3. **Run a second `/code-review`** as a grok agent, with `scripts/review.sh`, against the merge-base of the ticket branch and its land base - the commit the worktree held at launch. The implementer ran one and answered it. The second still finds real things: a check that lost one of its two directions, a rule weakened to keep a test green.
4. **Send findings back to the branch's own agent** with `scripts/resume.sh`: every hard finding, and every judgment call that changes what the ticket lands. The agent holds the context, and you hold the list. Arm a new watch. Gate again when it returns.

A branch clears the gate when every mechanical criterion is true on its tree and no hard finding stands. A human-witness trap stays on its ticket.

## Land

On a GitHub tracker, open the PR from the branch in the landing convention through `scripts/land.sh`. It pushes and opens the PR from the ticket worktree, merges from the primary checkout, deletes the remote branch, and fast-forwards the land-base ref. On another real tracker, the same steps with that tracker's merge-request CLI. On a local tracker, merge the branch into the land base in the primary checkout and set the ticket resolved. Land within the hour the gate clears, on a tip that has the land base as an ancestor, so that the tree that merges is the tree you captured the suite on. `Recompute the frontier` is how a tip gets there. Close the issue if close-on-merge didn't fire. If the repo has a documented post-merge gate (CI, a publish unit), watch it; a red gate is yours to fix forward the same hour. Done when the issue has closed.

## Recompute the frontier

After every landing, re-read the blocking edges. A newly unblocked `ready-for-agent` ticket's worktree predates the landings it depends on: rebase it onto the land base before its launch. When the land base moves under the next branch to land, **converge** before its merge. An **automatic merge** is yours to make when the dry run is clean, no generated file changes, and nothing the landing brought in needs migrating: `scripts/automerge.sh` makes it in a scratch worktree and proves the tree equals the one `git merge-tree` produces. You capture the suite there and adopt it. Anything else is a **merge round** by the branch's own agent, from [`MERGE-ROUND.md`](MERGE-ROUND.md): union the source, regenerate generated files, migrate what the landing brought in, run the suite, and loop until the base is an ancestor at the moment it commits. You gate the result. Regenerate generated files rather than hand-merge them.

## Settle rules once

When the **gate** settles something every remaining ticket must follow, comment it on the open tickets. An implementer's review sub-agent re-reads the ticket with its comments before the implementer commits, so a comment reaches a round already running. A rule taken from the first implementer's report, before the second review, isn't settled.

## Raise, hold, continue

A finding about the spec rather than a ticket - a mechanism the spec argued against, a meaning it got wrong, a rule it assumed - goes on the spec issue for the human, as the evidence and a recommendation the human can accept in one word. **Hold** the branches it affects: leave them in their worktrees, not merged. Land everything it doesn't affect. The decision is the human's: merging is the one act that changes what the repository means, and a held branch costs nothing. When the ruling comes, record it on the spec, amend the bodies it changes, and release the hold in the same comment.

## Finish

Reached when every `ready-for-agent` ticket has closed and no branch is on hold. Comment on the spec with what landed, merge by ticket, what you settled on the way, and what's still open for the human. Close the spec in that comment when every ticket has closed and no branch is on hold. An open `ready-for-human` ticket leaves the spec open the same way a hold does. Name suggestions for new tickets and a PR to this skill in the same comment. They hold nothing open. A hold leaves the spec open, pointing at the branch. Report the same to the user, with your own mistakes named.

The merge authority belongs to the Land step and ends with the last ticket. Everything after this - a follow-up the spec surfaced, a correction, a change to this skill - goes up as a PR and stops there, for the human to merge.
