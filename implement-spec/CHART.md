# Spec chart

Copy this file to `worktrees/agent-logs/spec-<id>-chart.md` and fill every slot. `<id>` is the spec issue number, or the file stem for a local spec.

## Now

- **Ticket:** the next ticket, or the one in flight
- **Round:** none / implementation / review / adjudication / correction / verification, with the subagent id when the harness gives one
- **State:** cutting / running / gating / landing / held
- **Last landing:** merge sha and ticket

## Implement skill

Absolute path of `implement/SKILL.md`. A round reads it by path.

## Tickets

| Ticket | Title | Blockers | Label | Worktree | Land base | Gate items (this ticket's) |
|---|---|---|---|---|---|---|
| | | | | `worktrees/issue-<n>-<slug>` | | |

Frontier: the open `ready-for-agent` tickets whose blockers are closed. Next: the lowest-numbered.

## Landing convention

Title voice, close-on-merge first line, merge commit, remote branch deleted. `--wait-checks` only if this repo has CI or a merge deploys.

## Suite

- **Command:**
- **Install:** (none / `.venv` / `node_modules` / ignored config a checkout does not carry)
- **Baseline on the land base:** the counts, and each failure by name
- **What the command cannot see:** tests excluded to make it run, and where they are covered instead
- **Extra gate:**

If the environment has no suite, write that, capture the last landing's check or `true`, and name which ticket adds the suite. If the suite is red on the land base, that baseline is the gate: a branch matches it, and the failures in it are nobody's ticket to fix.

## Probe

| Claim or figure | Command | Result |
|---|---|---|
| | | Holds / spec finding |

For each figure that counts rows matching a predicate, also record what each value in that predicate **means**, and the code that writes it. A right number under a wrong word is the failure this table exists to catch.

## Spec traps (green suite does not prove)

-

## Paths vs land base

`git cat-file -e <base>:<path>` for every path a ticket names. Missing paths are untracked drafts; the ticket lands without them.

## Standing rules

1.
