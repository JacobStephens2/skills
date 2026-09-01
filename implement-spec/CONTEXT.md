# Implement spec

The language for driving a spec's tickets to closed from the blocking graph.

## Language

**Invocation**:
The launcher and CLI that spawn a round. Sticky on the spec's chart.
_Avoid_: agent, command line, runner, harness

**Launcher**:
Whether `va` wraps the CLI or the CLI runs bare.
_Avoid_: harness, wrapper, agent

**CLI**:
The coding-agent binary that runs a round.
_Avoid_: agent, harness, model, launcher

**Permission mode**:
How that CLI authorizes tool calls. A round uses the CLI's non-interactive permission mode; it is not a choice on the invocation.
_Avoid_: yolo, bypass, auto (those are product names for one mode)

**Agent**:
The per-ticket process in a worktree that implements or reviews.
_Avoid_: grok, claude, invocation, orchestrator

**Round**:
One detached headless CLI process of the invocation in a ticket's worktree.
_Avoid_: subagent

**Blocker ledger**:
The fixed approval bar from the initial review: authority, evidence, and closing outcome for each blocker, plus non-blocking suggestions.
_Avoid_: latest review, new bar, finding dump

**Initial review**:
The one independent full review that establishes the blocker ledger.
_Avoid_: open review, fresh review

**Correction verification**:
A review against the blocker ledger and regressions introduced after its reviewed head.
_Avoid_: fresh review, re-review

**Orchestrator**:
The session that invoked `/implement-spec`.
_Avoid_: agent
