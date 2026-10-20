# Implement spec

The language for driving a spec's tickets to closed from the blocking graph, one ticket at a time.

## Language

**Orchestrator**:
The session that invoked `/implement-spec`. It stands in for the human running the ask-matt loop: it charts, spawns rounds, gates, and lands.
_Avoid_: agent, driver, manager

**Subagent**:
The harness's own fresh-context worker, whatever the harness calls it. Every round runs in one.
_Avoid_: detached process, headless run, CLI process, invocation

**Round**:
One subagent run on a ticket's branch: an implementation, a review, an adjudication, or a correction.
_Avoid_: process, session, task

**Agent**:
The subagent inside a round, as the party that implements, reviews, or adjudicates.
_Avoid_: orchestrator, grok, claude, codex

**Chart**:
The orchestrator's record of one spec on disk: the tickets with their gate items, the suite, the probe, the traps, the standing rules, and the loop's `Now`.
_Avoid_: plan, state file, scratchpad

**Frontier**:
The open `ready-for-agent` tickets whose blockers are all closed. The next ticket is the lowest-numbered one.
_Avoid_: queue, backlog, batch

**Blocker ledger**:
The fixed approval bar from the initial review: authority, evidence, and closing outcome for each blocker, plus non-blocking suggestions.
_Avoid_: latest review, new bar, finding dump

**Initial review**:
The one independent full review that establishes the blocker ledger.
_Avoid_: open review, fresh review

**Correction verification**:
A review against the blocker ledger and regressions introduced after its reviewed head.
_Avoid_: fresh review, re-review
