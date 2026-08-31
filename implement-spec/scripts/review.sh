#!/usr/bin/env bash
# review.sh [--dry-run] [--launcher <launcher>] [--cli <cli>] <issue> <worktree-name> <fixed-point>:
# a fresh agent of the invocation runs /code-review of the worktree's HEAD against <fixed-point>, read-only.
# Omitted invocation is launcher va and CLI grok. --dry-run prints the command without detaching.
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck disable=SC1091
. "$SCRIPT_DIR/invocation.sh"
parse_round_flags "$@"
if [ "$WANT_HELP" = 1 ]; then
  echo "usage: review.sh [--dry-run] [--launcher <launcher>] [--cli <cli>] <issue> <worktree-name> <fixed-point>"
  echo "Spawn a fresh /code-review round of the invocation in the worktree."
  echo "Omitted invocation is launcher va and CLI grok."
  print_invocation_help
  exit 0
fi
set -- "${ROUND_ARGS[@]}"
ISSUE="$1"; WT="$2"; FP="$3"
ROOT=$(cd "$SCRIPT_DIR" && cd "$(git rev-parse --git-common-dir)" && cd .. && pwd)
LOG="$ROOT/worktrees/agent-logs/review-$ISSUE.log"
PROMPT="/code-review $FP. The originating ticket is #$ISSUE: fetch it with the workflow in docs/agents/issue-tracker.md (the repo may be private; a web fetch will not open it). Report only; edit nothing."
build_invocation "$LAUNCHER" "$CLI" review "$PROMPT"
cd "$ROOT/worktrees/$WT"
if [ "$DRY" = 1 ]; then
  print_would
  exit 0
fi
rm -f "$LOG.exit"
echo "# review launched $(date -u +%FT%TZ) head=$(git rev-parse --short HEAD) fixed-point=$FP" > "$LOG"
PID=$("$SCRIPT_DIR/detach.sh" bash -c "cd '$PWD' && \"\$@\" >> '$LOG' 2>&1; echo \$? > '$LOG.exit'" round "${INVOCATION_CMD[@]}")
echo "review of issue $ISSUE launched (pid $PID) -> $LOG"
