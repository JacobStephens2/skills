#!/usr/bin/env bash
# land.sh [--dry-run] <issue> <worktree-name> <title> <body-file> [<base-ref>]: push and open the PR from the ticket worktree,
# merge it from the primary checkout, delete the remote branch, fast-forward the local land-base ref, print the merge sha
# and the issue's state. Refuses a dirty worktree or a land base not yet merged into the tip. <base-ref> defaults to the
# repo's default branch; `main` and `origin/main` are equivalent.
set -uo pipefail
DRY=0; [ "${1:-}" = "--dry-run" ] && { DRY=1; shift; }
ISSUE="$1"; WTN="$2"; TITLE="$3"
BODY=$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$4")
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$SCRIPT_DIR" && cd "$(git rev-parse --git-common-dir)" && cd .. && pwd); WT="$ROOT/worktrees/$WTN"
DEFAULT=$(git -C "$ROOT" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || { git -C "$ROOT" remote set-head origin -a >/dev/null 2>&1; git -C "$ROOT" symbolic-ref --short refs/remotes/origin/HEAD; }); DEFAULT=${DEFAULT#origin/}
BASE=${5:-$DEFAULT}; BASE=${BASE#origin/}
git -C "$ROOT" fetch -q origin
BR=$(git -C "$WT" branch --show-current); H=$(git -C "$WT" rev-parse HEAD); B=$(git -C "$ROOT" rev-parse "origin/$BASE")
[ -n "$BR" ] || { echo "$WT is not on a branch" >&2; exit 1; }
[ -z "$(git -C "$WT" status --porcelain)" ] || { echo "$WT is not clean; refusing" >&2; exit 1; }
git -C "$ROOT" merge-base --is-ancestor "$B" "$H" || { echo "origin/$BASE (${B:0:7}) is not merged into ${H:0:7}; converge first (automerge.sh or a merge round)" >&2; exit 1; }
[ -f "$BODY" ] || { echo "no body file $BODY" >&2; exit 1; }
head -1 "$BODY" | grep -qE "^Closes #$ISSUE\.?$" || echo "note: body's first line is not 'Closes #$ISSUE'" >&2
if [ "$DRY" = 1 ]; then
  echo "would: git -C $WT push -u origin $BR"; echo "would: gh pr create --base $BASE --head $BR --title '$TITLE' --body-file $BODY (from $WT)"
  echo "would: gh pr merge <n> --merge (from $ROOT); git push origin --delete $BR; git fetch origin $BASE:$BASE"; exit 0
fi
git -C "$WT" push -u origin "$BR" 2>&1 | tail -1
PR=$(cd "$WT" && gh pr create --base "$BASE" --head "$BR" --title "$TITLE" --body-file "$BODY" 2>&1 | tail -1); echo "PR: $PR"; N=${PR##*/}
[ "$N" -gt 0 ] 2>/dev/null || { echo "no PR number in: $PR" >&2; exit 1; }
(cd "$ROOT" && gh pr merge "$N" --merge 2>&1 | tail -1)
sleep 5; git -C "$ROOT" fetch -q origin --prune
git -C "$ROOT" merge-base --is-ancestor "$H" "origin/$BASE" || { echo "origin/$BASE does not contain ${H:0:7}; the merge did not land" >&2; exit 1; }
git -C "$ROOT" ls-remote --heads origin "$BR" | grep -q . && git -C "$ROOT" push origin --delete "$BR" 2>&1 | tail -1
git -C "$ROOT" fetch -q origin "$BASE:$BASE" 2>/dev/null && echo "local $BASE fast-forwarded to $(git -C "$ROOT" rev-parse --short "$BASE")" || echo "local $BASE not fast-forwarded (checked out somewhere, or diverged); origin/$BASE is $(git -C "$ROOT" rev-parse --short "origin/$BASE")"
echo "merged: origin/$BASE $(git -C "$ROOT" rev-parse --short "origin/$BASE") - $(git -C "$ROOT" log -1 --format=%s "origin/$BASE")"
echo "issue $ISSUE: $(gh issue view "$ISSUE" --json state --jq .state 2>/dev/null)"
