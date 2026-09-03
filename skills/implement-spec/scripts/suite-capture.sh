#!/usr/bin/env bash
# suite-capture.sh <worktree-name> <label> -- <command>...: run <command> in the worktree, log it to
# worktrees/agent-logs/suite-gate-<label>.log, print the exit code and the log's tail, and exit with the command's code.
# The primary checkout is found from the working directory, from inside any of its worktrees.
set -uo pipefail
[ -n "${1:-}" ] && [ -n "${2:-}" ] || { echo "usage: suite-capture.sh <worktree-name> <label> -- <command>..." >&2; exit 1; }
ROOT=$(cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && cd .. && pwd) || { echo "not inside a git checkout" >&2; exit 1; }
WTN=$1; LABEL=$2; shift 2
[ "${1:-}" = "--" ] && shift
[ -n "${1:-}" ] || { echo "usage: suite-capture.sh <worktree-name> <label> -- <command>..." >&2; exit 1; }
WT="$ROOT/worktrees/$WTN"
[ -d "$WT" ] || { echo "no worktree at $WT" >&2; exit 1; }
L="$ROOT/worktrees/agent-logs/suite-gate-$LABEL.log"; mkdir -p "$(dirname "$L")"
echo "# suite $WTN at $(git -C "$WT" rev-parse --short HEAD) started $(date -u +%FT%TZ)" > "$L"
echo "# cmd: $*" >> "$L"
(cd "$WT" && "$@") >> "$L" 2>&1; rc=$?
echo "suite $WTN ($(git -C "$WT" rev-parse --short HEAD)) exit=$rc log=$L"
tail -20 "$L"
exit "$rc"
