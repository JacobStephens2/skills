#!/usr/bin/env bash
# watch.sh [--review] <issue>...: print DONE as each round's exit marker appears; exit when all have. A Monitor command.
set -uo pipefail
PREFIX=issue; [ "${1:-}" = "--review" ] && { PREFIX=review; shift; }
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$SCRIPT_DIR" && cd "$(git rev-parse --git-common-dir)" && cd .. && pwd)
L="$ROOT/worktrees/agent-logs"
seen=" "
tick=0
sleep 30
while true; do
  left=0
  for n in "$@"; do
    f="$L/$PREFIX-$n.log.exit"
    if [ -f "$f" ]; then
      case "$seen" in
        *" $n "*) ;;
        *) seen="$seen$n "; echo "DONE $PREFIX-$n exit=$(cat "$f") log=$(wc -c < "$L/$PREFIX-$n.log")B" ;;
      esac
    else
      seen=$(printf '%s' "$seen" | sed "s/ $n / /")
      left=$((left+1))
    fi
  done
  [ "$left" = 0 ] && { echo "ALL DONE"; exit 0; }
  tick=$((tick+1)); [ $((tick % 40)) -eq 0 ] && echo "heartbeat: $left running"
  sleep 30
done
