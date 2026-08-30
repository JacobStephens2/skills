#!/usr/bin/env bash
# review.sh <issue> <worktree-name> <fixed-point>: a fresh grok agent runs /code-review of the worktree's HEAD against <fixed-point>, read-only.
set -euo pipefail
ISSUE="$1"; WT="$2"; FP="$3"
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$SCRIPT_DIR" && cd "$(git rev-parse --git-common-dir)" && cd .. && pwd)
LOG="$ROOT/worktrees/agent-logs/review-$ISSUE.log"
cd "$ROOT/worktrees/$WT"
rm -f "$LOG.exit"
echo "# review launched $(date -u +%FT%TZ) head=$(git rev-parse --short HEAD) fixed-point=$FP" > "$LOG"
export PROMPT_TEXT="/code-review $FP. The originating ticket is #$ISSUE: fetch it with the workflow in docs/agents/issue-tracker.md (the repo may be private; a web fetch will not open it). Report only; edit nothing."
PID=$("$SCRIPT_DIR/detach.sh" bash -c "cd '$PWD' && va grok --always-approve -p \"\$PROMPT_TEXT\" >> '$LOG' 2>&1; echo \$? > '$LOG.exit'")
echo "review of issue $ISSUE launched (pid $PID) -> $LOG"
