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
- **Install:** (none / `.venv` / `node_modules`)
- **Extra gate:**

If the environment has no suite, write that, capture the last landing's check or `true`, and name which ticket adds the suite.

## Probe

| Claim or figure | Command | Result |
|---|---|---|
| | | Holds / spec finding |

## Spec traps (green suite does not prove)

-

## Paths vs land base

`git cat-file -e <base>:<path>` for every path a ticket names. Missing paths are untracked drafts; the ticket lands without them.

## Standing rules

1.
