---
status: superseded by ADR-0004
---

# Rounds are detached CLI processes

A round is a detached headless CLI process in the ticket worktree, not a spawn through the orchestrator's native subagent API. Closing the TUI or hitting a tool timeout must not kill the loop; weekend batches have to finish after the orchestrator session is gone. Native subagents are session-scoped, so they are not rounds.
