---
name: implement-spec
description: Drive a spec's tickets to closed one at a time - a subagent round per ticket in its own worktree, gated, then landed as the blocking graph unblocks them.
disable-model-invocation: true
argument-hint: "<spec>"
---

This is the loop `/ask-matt` describes after `/to-tickets`: `/implement` per ticket in a fresh context, then the next. You stand in for the human running it. A spec arrives as tickets with blocking edges. The **frontier** is the open `ready-for-agent` tickets whose blockers are all closed; the **next ticket** is the lowest-numbered one. Each ticket gets a **round** at a time: a **subagent** of your own harness, in the ticket's own worktree. A finished branch clears a **gate** before it **lands**. After every landing you pick the next ticket. One round at a time, one spec per land base at a time. You chart, gate, and land. The agents implement, review, adjudicate, and answer review. `ready-for-human` tickets stay on the chart until the human closes them.

The issue tracker and triage label vocabulary should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`. `docs/agents/issue-tracker.md` holds the forms for sub-issues and blocking edges. [`ROUNDS.md`](ROUNDS.md) is how a round is spawned, pinned to its worktree, continued, and read; read it before the first round. The **chart** is your record of the spec on disk, a filled copy of [`CHART.md`](CHART.md) at `worktrees/agent-logs/spec-<id>-chart.md`, where `<id>` is the spec issue number or the file stem of a local spec. When a ticket's land base isn't the default branch, read [`LAND-BASE.md`](LAND-BASE.md).

## Start

Fetch and fast-forward the primary checkout onto the land base before anything else. If that moved this skill's folder, re-read this file. If the chart already exists, this is a restart: go to `Restart`. Otherwise chart the spec.

## Chart the spec

1. Read the spec, every ticket with its comments, its triage label, and the blocking edges. The tracker's edges are the gate (native `blocked_by` on a real tracker; `Blocked by` lines in local files). When a body names a dependency the tracker lacks, add it as a tracker edge, so that you compute the frontier from one source.
2. For every ticket, write the **land base**: the branch its merge targets, and check whether you can actually merge there - a protected default branch that requires a review you cannot give yourself blocks the loop at the first landing, and that is one API call to learn. When it is protected, or when the spec's tickets edit the same files, open a `<spec>/staging` ref, land every ticket on it, and open one pull request to the default branch at `Finish` for the human. Read [`LAND-BASE.md`](LAND-BASE.md). Otherwise the default is the repo's default branch. A ticket that names an integration branch, or says not to merge it independently to that default, names a different base. A ticket whose land base is another repository is a spec finding: your merge authority ends at this repo. Raise it under `Raise, hold, continue` and ask for the split - the other repo's change as its own ticket there, blocking this one.
3. Read the last few landings and fix the convention: title in the repo's voice, the tracker's close-on-merge line as the body's first line, a merge commit, and the remote branch deleted afterward.
4. Write down the spec's own traps: the things it says a green suite doesn't prove (a visual check, a byte-identical artifact, a test committed red before its fix). Each is a gate item for the ticket it names. A criterion only a human can witness is a trap on the ticket that owns the witness. The `ready-for-agent` ticket's gate is the mechanical inspection that makes that witness possible.
5. Read extra gate commands from the environment: CI config, a test README, anything under `docs/agents/`. Write each on the ticket it gates.
6. Resolve every path a ticket names against the land base with `git cat-file -e <base>:<path>`. A path that isn't there is someone's untracked draft, and the ticket lands without it. Settle any mismatch with the ticket body in a comment before the first round.
7. Find the **suite command** that covers the tickets' code, from the environment (`package.json` `test`/`check`, a Makefile target, CI, a test README), and what a worktree needs to run it (a `.venv`, `node_modules`). A repo with more than one suite gets the suite the tickets change. If the environment has no suite, chart that, capture the last landing's check or `true`, and name which ticket adds the suite.
8. **Probe** every claim the spec makes about what production does or lacks, and every figure it states, on the land base, before the first round: feed the shape through the production path and record the command that reproduces the result. Then probe the **meaning**: for every figure that counts things matching a predicate, find the code that *writes* each value the predicate names, and check the spec's word for it against what that code does. A count is not evidence for the sentence around it - a correct count of a misread column reads as confirmation, and the probe that only checks arithmetic will confirm a wrong spec rather than catch it. Finding the writer is one search. A claim, figure, or meaning that fails the probe is a spec finding. Raise it under `Raise, hold, continue` before a round writes a test to it.
9. Write the **standing rules**: the repo's documented coding standards that apply to every ticket. If the tickets edit a skill, `SKILL.md`, or `AGENTS.md`, those rules include writing-for-agents: one home per fact, user-invoked stays user-invoked. The standing rules bind your own comments and PR bodies too: a repo that lints its docs lints them.
10. Find the `/implement` skill's `SKILL.md` among the project's skills and your user skills, and write its absolute path. A round reads it by path.

Done when the chart is a filled copy of [`CHART.md`](CHART.md): every slot has a value, and `Now` names the next ticket.

## Run the loop

Before the first round, comment the standing rules on every open ticket: the implementer's review sub-agent reads the ticket's comments before the implementer commits. Then repeat until the frontier is empty:

1. **Pick** the next ticket and write it in the chart's `Now`.
2. **Cut its worktree** from the land base's tip: `worktrees/issue-<n>-<slug>`, with `worktrees/` in the primary checkout's `.gitignore`. Install what the suite needs **to run without skipping** - dependencies, and the ignored config a checkout does not carry; a suite missing its config skips itself and still reports OK, so read the skip count, not the exit code. An install copied from before a dependency landed isn't that file. Capture the suite once at that tip with the charted command through the skill's `scripts/suite-capture.sh`. Done when the worktree is clean at the tip and that capture **matches the land base's baseline**: green where the land base is green, and the same failures where it is not. A land base whose suite is red in your environment is charted, not fixed - a ticket branch is not where an environmental failure gets repaired.
3. **Spawn the implementation round** as [`ROUNDS.md`](ROUNDS.md) says. Its prompt is three facts: the implement skill's path, the ticket, and the worktree. The ticket is the brief; a prompt that restates it becomes a second spec the agent has to reconcile.
4. When the round returns, **gate** the branch, then **land** it.
5. If the land base moved during the round, continue the round with the prompt in [`MERGE-ROUND.md`](MERGE-ROUND.md) before the gate, and gate what it commits.

When the frontier is empty and open tickets remain, they are blocked on a human or on hold: go to `Finish`.

## Gate a finished branch

1. **Check every acceptance criterion, mechanically where a command can.** Capture the suite with `scripts/suite-capture.sh` and the charted command. The implementer's reported count isn't the gate. When the charted command excludes tests - because they cannot run from a worktree, or skip themselves in CI - write down what it cannot see, and carry that debt to `Finish`. Run the extra gate commands from the chart. Put the checks a spec repeats at every gate into one script at the first gate, diffed against the merge-base. The agent's report covers what no command can; read it against the ticket's criteria, one by one.
2. **Check the spec's traps for this ticket**, from your chart.
3. **Run one initial review** as a review round, against the merge-base of the ticket branch and its land base - the commit the worktree held when the round started. The implementer ran one and answered it. The second still finds real things: a check that lost one of its two directions, a rule weakened to keep a test green.
4. **Adjudicate the report into a blocker ledger** through an adjudication round, at `worktrees/agent-logs/findings-<n>.md`, beginning with `reviewed-head: <full commit sha>`. Give the round the facts you established at the gate, as settled, so it spends its rounds on what you could not decide. Where a finding turns on one fact, name that fact and ask the round to determine it. A blocker names its authority - a ticket criterion, spec trap, documented repository rule, or concrete correctness, security, data-loss, or external-side-effect failure - then the evidence on the reviewed head and the outcome that closes it. A different reasonable mechanism is a suggestion unless the authority fixes that mechanism. Suggestions are recorded separately and do not hold the branch. Read the ledger: strike a blocker whose authority you don't recognise, add one the round missed. The ledger is the only review text you hold.
5. **Send the ledger back to the branch's own agent**: continue the implementation round with the ledger's path, or, when your harness cannot continue it, a fresh round on the branch with the ledger. The ledger holds the fixed approval bar either way.
6. **Converge after correction.** Re-run the mechanical gate. Then run a correction verification round from the ledger's `reviewed-head`, with the ledger path: it checks the recorded blockers on current HEAD and reviews only the correction diff for concrete regressions. A pre-existing architectural alternative discovered late is a suggestion. Record blocker outcomes in the same ledger without changing `reviewed-head`; it remains the approval bar through correction.

A branch clears the gate when every mechanical criterion is true, every ledger blocker is closed, and correction verification finds no introduced regression. A human-witness trap stays on its ticket. If the same blocker survives two correction rounds, or the implementer and verifier disagree about the authority rather than the evidence, use `Raise, hold, continue`: give the human the evidence and a one-word recommendation instead of starting a third correction round.

## Land

On a GitHub tracker, open the PR from the branch in the landing convention through `scripts/land.sh`. It pushes and opens the PR from the ticket worktree, merges from the primary checkout, deletes the remote branch, and fast-forwards the land-base ref. On another real tracker, the same steps with that tracker's merge-request CLI. On a local tracker, merge the branch into the land base in the primary checkout and set the ticket resolved. Land within the hour the gate clears, on a tip that has the land base as an ancestor, so that the tree that merges is the tree you captured the suite on; when the script refuses because the base moved, run a merge round and gate again. Close the issue if close-on-merge didn't fire. If the repo has a documented post-merge gate (CI, a publish unit), watch it; a red gate is yours to fix forward the same hour. Done when the issue has closed and the landing is in the chart's `Now`.

## Settle rules once

When the **gate** settles something every remaining ticket must follow, comment it on the open tickets. An implementer's review sub-agent re-reads the ticket with its comments before the implementer commits. A rule taken from the first implementer's report, before the second review, isn't settled.

## Raise, hold, continue

A finding about the spec rather than a ticket - a mechanism the spec argued against, a meaning it got wrong, a rule it assumed - goes on the spec issue for the human, as the evidence and a recommendation the human can accept in one word. **Hold** the branch it affects: leave it in its worktree, not merged, and skip the tickets it blocks. Continue with the rest of the frontier. The decision is the human's: merging is the one act that changes what the repository means, and a held branch costs nothing. When the ruling comes, record it on the spec, amend the bodies it changes, and release the hold in the same comment.

A `ready-for-human` ticket that blocks the frontier gets a handoff comment: the mechanical inspection you can run, and exactly what the human needs for their part - what you derived, the URLs, where the control lives. Then finish; the human's closing is what unblocks the next run.

## Restart

With an existing chart: re-read it and this skill, and recompute the frontier from the tracker, since tickets close without you. For the ticket in `Now`, read its branch. Commits beyond the land base and no ledger: a finished round, gate it. A ledger with open blockers: a fresh correction round on the branch with the ledger. Nothing beyond the base: spawn its round. The same rule applies after a compaction: when your context opens with a continuation summary, re-read this skill and the chart before your next step.

## Finish

Reached when the frontier is empty. **Before the last pull request, run the whole suite once in the primary checkout, where nothing is excluded, and compare it to the baseline you captured on the land base at charting.** Every per-ticket gate ran the charted command, and whatever that command could not see, no gate saw either - so a defect inside the exclusion survives six green gates and six green CI runs. It is one run and it is the only place that debt gets paid. A regression it finds is yours to fix on the land base before the pull request goes up, on its own branch, gated like any other. Comment on the spec with what landed, merge by ticket, what you settled on the way, and what's still open for the human: holds, and `ready-for-human` tickets with their handoffs. Close the spec in that comment when every ticket has closed and no branch is on hold; otherwise the spec stays open, pointing at what waits. Name suggestions for new tickets and a PR to this skill in the same comment. They hold nothing open. Report the same to the user, with your own mistakes named.

The merge authority belongs to the Land step and ends with the last ticket. Everything after this - a follow-up the spec surfaced, a correction, a change to this skill - goes up as a PR and stops there, for the human to merge.
