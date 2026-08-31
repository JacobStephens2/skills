# Spec chart

Copy this file to `worktrees/agent-logs/spec-<id>-chart.md` and fill every slot. `<id>` is the spec issue number, or the file stem for a local spec.

```
invocation: <cli>
```
or `invocation: va <cli>`. One token is launcher none and that CLI.

## Tickets

| Ticket | Title | Blockers | Label | Worktree | Land base | Gate items (this ticket's) |
|---|---|---|---|---|---|---|
| | | | | `worktrees/issue-<n>-<slug>` | | |

Frontier now: the open `ready-for-agent` tickets whose blockers are closed.

## Landing convention

Title voice, close-on-merge first line, merge commit, remote branch deleted. `--wait-checks` only if this repo has CI or a merge deploys.

## Suite

- **Command:**
- **Install:** (none / `.venv` / `node_modules`)
- **Exclusive shared resources:** (none / ports, simulators, emulators, databases)
- **Extra gate:**

If the environment has no suite, write that, capture the last landing's check or `true`, and name which ticket adds the suite.

## Probe

| Claim | Result |
|---|---|
| | Holds / spec finding |

## Spec traps (green suite does not prove)

-

## Paths vs land base

`git cat-file -e <base>:<path>` for every path a ticket names. Missing paths are untracked drafts; the ticket lands without them.

## Siblings

Other specs on this land base, their running agents, and the files their open tickets change. None, or list them.

## Standing rules

1.
