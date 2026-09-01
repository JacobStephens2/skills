#!/usr/bin/env bash
# review.sh [--dry-run] [--launcher <launcher>] [--cli <cli>] <issue> <worktree-name> <fixed-point> [<blocker-ledger>]:
# a fresh agent of the invocation runs the initial /code-review, or verifies a fixed blocker ledger after correction.
# Requires --launcher and --cli. --dry-run prints the command without detaching.
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck disable=SC1091
. "$SCRIPT_DIR/invocation.sh"
parse_round_flags "$@"
if [ "$WANT_HELP" = 1 ]; then
  echo "usage: review.sh [--dry-run] [--launcher <launcher>] [--cli <cli>] <issue> <worktree-name> <fixed-point> [<blocker-ledger>]"
  echo "Spawn the initial /code-review, or a correction verification when a blocker ledger is supplied."
  echo "Requires --launcher and --cli."
  print_invocation_help
  exit 0
fi
require_invocation
set -- "${ROUND_ARGS[@]}"
ISSUE="$1"; WT="$2"; FP="$3"
ROOT=$(cd "$SCRIPT_DIR" && cd "$(git rev-parse --git-common-dir)" && cd .. && pwd)
LOG="$ROOT/worktrees/agent-logs/review-$ISSUE.log"
MODE=initial
PROMPT="/code-review $FP. The originating ticket is #$ISSUE: fetch it with the workflow in docs/agents/issue-tracker.md (the repo may be private; a web fetch will not open it). Report only; edit nothing."
if [ -n "${4:-}" ]; then
  LEDGER="$4"
  [ -f "$LEDGER" ] || { echo "blocker ledger not found: $LEDGER" >&2; exit 1; }
  LEDGER=$(cd "$(dirname "$LEDGER")" && pwd)/$(basename "$LEDGER")
  MODE=correction
  PROMPT="/code-review $FP. The originating ticket is #$ISSUE: fetch it with the workflow in docs/agents/issue-tracker.md (the repo may be private; a web fetch will not open it). This is a correction verification against a fixed approval bar. Read the blocker ledger at $LEDGER. Verify each recorded blocker against current HEAD and report concrete regressions introduced after its reviewed-head. Keep pre-existing architectural alternatives and preferences as suggestions, not blockers. Report only; edit nothing."
fi
build_invocation "$LAUNCHER" "$CLI" review "$PROMPT"
cd "$ROOT/worktrees/$WT"
if [ "$DRY" = 1 ]; then
  print_would
  exit 0
fi
rm -f "$LOG.exit"
echo "# review launched $(date -u +%FT%TZ) mode=$MODE head=$(git rev-parse --short HEAD) fixed-point=$FP" > "$LOG"
PID=$("$SCRIPT_DIR/detach.sh" bash -c "cd '$PWD' && \"\$@\" >> '$LOG' 2>&1; echo \$? > '$LOG.exit'" round "${INVOCATION_CMD[@]}")
echo "review of issue $ISSUE launched (pid $PID) -> $LOG"
