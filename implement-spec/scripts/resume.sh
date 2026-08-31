#!/usr/bin/env bash
# resume.sh [--dry-run] [--launcher <launcher>] [--cli <cli>] <issue> <worktree-name> <prompt-file>:
# the invocation's continue with the file's text, detached.
# Requires --launcher and --cli. --dry-run prints the command without detaching.
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck disable=SC1091
. "$SCRIPT_DIR/invocation.sh"
parse_round_flags "$@"
if [ "$WANT_HELP" = 1 ]; then
  echo "usage: resume.sh [--dry-run] [--launcher <launcher>] [--cli <cli>] <issue> <worktree-name> <prompt-file>"
  echo "The invocation's continue with the file's text."
  echo "Requires --launcher and --cli."
  print_invocation_help
  exit 0
fi
require_invocation
set -- "${ROUND_ARGS[@]}"
ISSUE="$1"; WT="$2"
ROOT=$(cd "$SCRIPT_DIR" && cd "$(git rev-parse --git-common-dir)" && cd .. && pwd)
PF=$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$3")
LOG="$ROOT/worktrees/agent-logs/issue-$ISSUE.log"
PROMPT=$(cat "$PF")
build_invocation "$LAUNCHER" "$CLI" resume "$PROMPT"
cd "$ROOT/worktrees/$WT"
if [ "$DRY" = 1 ]; then
  print_would
  exit 0
fi
rm -f "$LOG.exit"
echo "# resumed $(date -u +%FT%TZ) head=$(git rev-parse --short HEAD) prompt=$PF" >> "$LOG"
PID=$("$SCRIPT_DIR/detach.sh" bash -c "cd '$PWD' && \"\$@\" >> '$LOG' 2>&1; echo \$? > '$LOG.exit'; echo \"# exited \$(cat '$LOG.exit') at \$(date -u +%FT%TZ)\" >> '$LOG'" round "${INVOCATION_CMD[@]}")
echo "resumed issue $ISSUE in $WT (pid $PID)"
