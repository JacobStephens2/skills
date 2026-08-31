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
export ROUND_LOG="$LOG" ROUND_REF="$REF"
# shellcheck disable=SC2016 # The detached Bash expands this script.
PID=$("$SCRIPT_DIR/detach.sh" bash -c '
rc=1
for attempt in 1 2 3; do
  before=$(wc -c < "$ROUND_LOG")
  va grok --always-approve -p "/implement $ROUND_REF" >> "$ROUND_LOG" 2>&1
  rc=$?
  [ "$rc" -eq 0 ] && break
  [ "$attempt" -lt 3 ] || break
  tail -c "+$((before + 1))" "$ROUND_LOG" | grep -Fq "vaulted-agent: bws secret list" || break
  tail -c "+$((before + 1))" "$ROUND_LOG" | grep -Fq "429 Too Many Requests" || break
  delay=$((attempt + RANDOM % 3))
  echo "# vault rate-limited before session start; retrying in ${delay}s" >> "$ROUND_LOG"
  sleep "$delay"
done
printf "%s\n" "$rc" > "$ROUND_LOG.exit"
printf "# exited %s at %s\n" "$rc" "$(date -u +%FT%TZ)" >> "$ROUND_LOG"
')
echo "launched issue $ISSUE in $WT (pid $PID) -> $LOG"
