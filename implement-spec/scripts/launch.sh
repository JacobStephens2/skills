#!/usr/bin/env bash
# launch.sh [--dry-run] [--launcher <launcher>] [--cli <cli>] <issue> <worktree-name> [<ticket-ref>]:
# a detached headless /implement round of the invocation in the ticket's worktree.
# <ticket-ref> is the /implement argument (URL, number, or path). Default: GitHub issue URL from origin.
# Omitted invocation is launcher va and CLI grok. --dry-run prints the command without detaching.
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck disable=SC1091
. "$SCRIPT_DIR/invocation.sh"
parse_round_flags "$@"
if [ "$WANT_HELP" = 1 ]; then
  echo "usage: launch.sh [--dry-run] [--launcher <launcher>] [--cli <cli>] <issue> <worktree-name> [<ticket-ref>]"
  echo "Spawn a detached /implement round of the invocation in the worktree."
  echo "Omitted invocation is launcher va and CLI grok."
  print_invocation_help
  exit 0
fi
set -- "${ROUND_ARGS[@]}"
ISSUE="$1"; WT="$2"
ROOT=$(cd "$SCRIPT_DIR" && cd "$(git rev-parse --git-common-dir)" && cd .. && pwd)
LOGDIR="$ROOT/worktrees/agent-logs"; LOG="$LOGDIR/issue-$ISSUE.log"
if [ -n "${3:-}" ]; then
  REF="$3"
else
  REF=$(git -C "$ROOT" remote get-url origin | sed -E 's#(\.git)?$##; s#^git@github\.com:#https://github.com/#')/issues/$ISSUE
fi
build_invocation "$LAUNCHER" "$CLI" launch "/implement $REF"
cd "$ROOT/worktrees/$WT"
[ -z "$(git status --porcelain)" ] || { echo "worktree $WT is not clean; refusing" >&2; exit 1; }
if [ "$DRY" = 1 ]; then
  print_would
  exit 0
fi
mkdir -p "$LOGDIR"
rm -f "$LOG.exit"
echo "# launched $(date -u +%FT%TZ) issue=$ISSUE worktree=$WT head=$(git rev-parse --short HEAD) ref=$REF" >> "$LOG"
export ROUND_LOG="$LOG"
RETRY=0; [ "$LAUNCHER" = va ] && RETRY=1
export ROUND_RETRY="$RETRY"
# shellcheck disable=SC2016 # The detached Bash expands this script.
PID=$("$SCRIPT_DIR/detach.sh" bash -c '
rc=1
attempts=1
[ "${ROUND_RETRY:-0}" = 1 ] && attempts=3
for attempt in $(seq 1 "$attempts"); do
  before=$(wc -c < "$ROUND_LOG")
  "$@" >> "$ROUND_LOG" 2>&1
  rc=$?
  [ "$rc" -eq 0 ] && break
  [ "$attempt" -lt "$attempts" ] || break
  tail -c "+$((before + 1))" "$ROUND_LOG" | grep -Fq "vaulted-agent: bws secret list" || break
  tail -c "+$((before + 1))" "$ROUND_LOG" | grep -Fq "429 Too Many Requests" || break
  delay=$((attempt + RANDOM % 3))
  echo "# vault rate-limited before session start; retrying in ${delay}s" >> "$ROUND_LOG"
  sleep "$delay"
done
printf "%s\n" "$rc" > "$ROUND_LOG.exit"
printf "# exited %s at %s\n" "$rc" "$(date -u +%FT%TZ)" >> "$ROUND_LOG"
' round "${INVOCATION_CMD[@]}")
echo "launched issue $ISSUE in $WT (pid $PID) -> $LOG"
