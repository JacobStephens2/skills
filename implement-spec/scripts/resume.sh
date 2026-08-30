#!/usr/bin/env bash
# resume.sh <issue> <worktree-name> <prompt-file>: continue the worktree's most recent grok session with the file's text, detached.
set -euo pipefail
ISSUE="$1"; WT="$2"
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$SCRIPT_DIR" && cd "$(git rev-parse --git-common-dir)" && cd .. && pwd)
PF=$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$3")
LOG="$ROOT/worktrees/agent-logs/issue-$ISSUE.log"
cd "$ROOT/worktrees/$WT"
rm -f "$LOG.exit"
echo "# resumed $(date -u +%FT%TZ) head=$(git rev-parse --short HEAD) prompt=$PF" >> "$LOG"
PID=$("$SCRIPT_DIR/detach.sh" bash -c "cd '$PWD' && va grok --always-approve -c -p \"\$(cat '$PF')\" >> '$LOG' 2>&1; echo \$? > '$LOG.exit'; echo \"# exited \$(cat '$LOG.exit') at \$(date -u +%FT%TZ)\" >> '$LOG'")
echo "resumed issue $ISSUE in $WT (pid $PID)"
