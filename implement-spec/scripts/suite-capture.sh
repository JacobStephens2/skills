#!/usr/bin/env bash
# suite-capture.sh <worktree-name> <label> -- <command>...: run <command> in the worktree into
# worktrees/agent-logs/suite-gate-<label>.log and write its exit code to <log>.exit.
set -uo pipefail
[ -n "${1:-}" ] && [ -n "${2:-}" ] || { echo "usage: suite-capture.sh <worktree-name> <label> -- <command>..." >&2; exit 1; }
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$SCRIPT_DIR" && cd "$(git rev-parse --git-common-dir)" && cd .. && pwd)
WTN=$1; LABEL=$2; shift 2
[ "${1:-}" = "--" ] && shift
[ -n "${1:-}" ] || { echo "usage: suite-capture.sh <worktree-name> <label> -- <command>..." >&2; exit 1; }
WT="$ROOT/worktrees/$WTN"
L="$ROOT/worktrees/agent-logs/suite-gate-$LABEL.log"; mkdir -p "$(dirname "$L")"
echo "# suite $WTN at $(git -C "$WT" rev-parse --short HEAD) started $(date -u +%FT%TZ)" > "$L"
echo "# cmd: $*" >> "$L"
(cd "$WT" && "$@") >> "$L" 2>&1; rc=$?
echo "$rc" > "$L.exit"
echo "suite $WTN ($(git -C "$WT" rev-parse --short HEAD)) exit=$rc log=$L"
tail -20 "$L"
