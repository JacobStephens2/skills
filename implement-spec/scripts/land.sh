#!/usr/bin/env bash
# land.sh [--dry-run] [--wait-checks] <issue> <worktree-name> <title> <body-file> [<base-ref>]: push and open the PR from the
# ticket worktree, merge it from the primary checkout, delete the remote branch, fast-forward the local land-base ref, print
# the merge sha and the issue's state. --wait-checks waits for the PR's checks between create and merge and stops without
# merging when one fails; a token that cannot read PR checks gets the Actions runs for the tip instead. Refuses a dirty
# worktree or a land base not yet merged into the tip. <base-ref> defaults to the repo's default branch; `main` and
# `origin/main` are equivalent. The primary checkout is found from the working directory, from inside any of its worktrees.
set -uo pipefail
DRY=0; WAIT=0
while :; do case "${1:-}" in
  --dry-run) DRY=1; shift;;
  --wait-checks) WAIT=1; shift;;
  *) break;;
esac; done
[ $# -ge 4 ] || { echo "usage: land.sh [--dry-run] [--wait-checks] <issue> <worktree-name> <title> <body-file> [<base-ref>]" >&2; exit 1; }
ISSUE="$1"; WTN="$2"; TITLE="$3"
[ -f "$4" ] || { echo "no body file $4" >&2; exit 1; }
BODY=$(cd "$(dirname "$4")" && pwd)/$(basename "$4")
ROOT=$(cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && cd .. && pwd) || { echo "not inside a git checkout" >&2; exit 1; }
WT="$ROOT/worktrees/$WTN"
[ -d "$WT" ] || { echo "no worktree at $WT" >&2; exit 1; }
POLL=${LAND_POLL_SECONDS:-15}

# Wait for the PR's checks. They register a beat after the push, so wait for them to exist first. A token that cannot read
# PR checks ("Resource not accessible by personal access token") falls back to the Actions runs for the tip.
wait_for_checks() {
  local pr="$1" sha="$2" out
  for _ in $(seq 1 20); do
    out=$(cd "$ROOT" && gh pr checks "$pr" 2>&1)
    case "$out" in
      *"Resource not accessible by personal access token"*) wait_for_runs "$sha"; return $? ;;
      ""|*"no checks reported"*) sleep "$POLL"; continue ;;
    esac
    break
  done
  (cd "$ROOT" && gh pr checks "$pr" --watch --fail-fast >/dev/null 2>&1) || {
    echo "checks failed on PR $pr; not merging" >&2
    (cd "$ROOT" && gh pr checks "$pr" 2>&1 | tail -5) >&2
    return 1
  }
}

# Actions runs for the tip. Waits for every run to complete; a conclusion other than success or skipped stops the landing.
wait_for_runs() {
  local sha="$1" repo runs
  repo=$(cd "$ROOT" && gh repo view --json nameWithOwner --jq .nameWithOwner) || { echo "cannot name the repo for the Actions API" >&2; return 1; }
  for _ in $(seq 1 20); do
    runs=$(cd "$ROOT" && gh api "repos/$repo/actions/runs?head_sha=$sha&per_page=100" --jq '.workflow_runs[] | "\(.name)\t\(.status)\t\(.conclusion // "")"' 2>&1) || { echo "cannot read Actions runs: $runs" >&2; return 1; }
    [ -n "$runs" ] && break
    sleep "$POLL"
  done
  [ -n "$runs" ] || { echo "no Actions runs for ${sha:0:7}; not merging" >&2; return 1; }
  for _ in $(seq 1 240); do
    if printf '%s\n' "$runs" | awk -F'\t' '$2 != "completed" { pending=1 } END { exit pending ? 0 : 1 }'; then
      sleep "$POLL"
      runs=$(cd "$ROOT" && gh api "repos/$repo/actions/runs?head_sha=$sha&per_page=100" --jq '.workflow_runs[] | "\(.name)\t\(.status)\t\(.conclusion // "")"' 2>&1) || { echo "cannot read Actions runs: $runs" >&2; return 1; }
      continue
    fi
    if printf '%s\n' "$runs" | awk -F'\t' '$3 != "success" && $3 != "skipped" { bad=1 } END { exit bad ? 0 : 1 }'; then
      echo "Actions runs failed on ${sha:0:7}; not merging" >&2; printf '%s\n' "$runs" >&2; return 1
    fi
    printf '%s\n' "$runs" | sed 's/^/run: /'
    return 0
  done
  echo "Actions runs for ${sha:0:7} did not complete; not merging" >&2; return 1
}

DEFAULT=$(git -C "$ROOT" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || { git -C "$ROOT" remote set-head origin -a >/dev/null 2>&1; git -C "$ROOT" symbolic-ref --short refs/remotes/origin/HEAD; }); DEFAULT=${DEFAULT#origin/}
BASE=${5:-$DEFAULT}; BASE=${BASE#origin/}
git -C "$ROOT" fetch -q origin
BR=$(git -C "$WT" branch --show-current); H=$(git -C "$WT" rev-parse HEAD); B=$(git -C "$ROOT" rev-parse "origin/$BASE")
[ -n "$BR" ] || { echo "$WT is not on a branch" >&2; exit 1; }
[ -z "$(git -C "$WT" status --porcelain)" ] || { echo "$WT is not clean; refusing" >&2; exit 1; }
git -C "$ROOT" merge-base --is-ancestor "$B" "$H" || { echo "origin/$BASE (${B:0:7}) is not merged into ${H:0:7}; run a merge round first" >&2; exit 1; }
head -1 "$BODY" | grep -qE "^Closes #$ISSUE\.?$" || echo "note: body's first line is not 'Closes #$ISSUE'" >&2
if [ "$DRY" = 1 ]; then
  echo "would: git -C $WT push -u origin $BR"; echo "would: gh pr create --base $BASE --head $BR --title '$TITLE' --body-file $BODY (from $WT)"
  [ "$WAIT" = 1 ] && echo "would: wait for the PR's checks, or the Actions runs for ${H:0:7} when the token cannot read checks"
  echo "would: gh pr merge <n> --merge (from $ROOT); git push origin --delete $BR; git fetch origin $BASE:$BASE"; exit 0
fi
git -C "$WT" push -u origin "$BR" 2>&1 | tail -1
PR=$(cd "$WT" && gh pr create --base "$BASE" --head "$BR" --title "$TITLE" --body-file "$BODY" 2>&1 | tail -1); echo "PR: $PR"; N=${PR##*/}
[ "$N" -gt 0 ] 2>/dev/null || { echo "no PR number in: $PR" >&2; exit 1; }
if [ "$WAIT" = 1 ]; then wait_for_checks "$N" "$H" || exit 1; fi
(cd "$ROOT" && gh pr merge "$N" --merge 2>&1 | tail -1)
sleep "${LAND_SETTLE_SECONDS:-5}"; git -C "$ROOT" fetch -q origin --prune
git -C "$ROOT" merge-base --is-ancestor "$H" "origin/$BASE" || { echo "origin/$BASE does not contain ${H:0:7}; the merge did not land" >&2; exit 1; }
git -C "$ROOT" ls-remote --heads origin "$BR" | grep -q . && git -C "$ROOT" push origin --delete "$BR" 2>&1 | tail -1
git -C "$ROOT" fetch -q origin "$BASE:$BASE" 2>/dev/null && echo "local $BASE fast-forwarded to $(git -C "$ROOT" rev-parse --short "$BASE")" || echo "local $BASE not fast-forwarded (checked out somewhere, or diverged); origin/$BASE is $(git -C "$ROOT" rev-parse --short "origin/$BASE")"
echo "merged: origin/$BASE $(git -C "$ROOT" rev-parse --short "origin/$BASE") - $(git -C "$ROOT" log -1 --format=%s "origin/$BASE")"
echo "issue $ISSUE: $(cd "$ROOT" && gh issue view "$ISSUE" --json state --jq .state 2>/dev/null)"
