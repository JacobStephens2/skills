#!/usr/bin/env bash
# launch.sh <issue> <worktree-name> [<ticket-ref>]: a detached headless grok /implement round in the ticket's worktree.
# <ticket-ref> is the /implement argument (URL, number, or path). Default: GitHub issue URL from origin.
set -euo pipefail
ISSUE="$1"; WT="$2"
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$SCRIPT_DIR" && cd "$(git rev-parse --git-common-dir)" && cd .. && pwd)
LOGDIR="$ROOT/worktrees/agent-logs"; LOG="$LOGDIR/issue-$ISSUE.log"
if [ -n "${3:-}" ]; then
  REF="$3"
else
  REF=$(git -C "$ROOT" remote get-url origin | sed -E 's#(\.git)?$##; s#^git@github\.com:#https://github.com/#')/issues/$ISSUE
fi
mkdir -p "$LOGDIR"; cd "$ROOT/worktrees/$WT"
[ -z "$(git status --porcelain)" ] || { echo "worktree $WT is not clean; refusing" >&2; exit 1; }
rm -f "$LOG.exit"
echo "# launched $(date -u +%FT%TZ) issue=$ISSUE worktree=$WT head=$(git rev-parse --short HEAD) ref=$REF" >> "$LOG"
PID=$("$SCRIPT_DIR/detach.sh" bash -c "cd '$PWD' && va grok --always-approve -p '/implement $REF' >> '$LOG' 2>&1; echo \$? > '$LOG.exit'; echo \"# exited \$(cat '$LOG.exit') at \$(date -u +%FT%TZ)\" >> '$LOG'")
echo "launched issue $ISSUE in $WT (pid $PID) -> $LOG"
