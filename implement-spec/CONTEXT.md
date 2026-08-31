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

**Orchestrator**:
The session that invoked `/implement-spec`.
_Avoid_: agent
