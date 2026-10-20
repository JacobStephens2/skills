#!/usr/bin/env bash
# Push/create or resume a ticket PR, verify its reviewed head, then merge under normal policy.
set -euo pipefail
fail() { echo "$*" >&2; exit 1; }
usage() { fail 'usage: land.sh --reviewed-head <sha> [--dry-run] [--wait-checks] <issue> <worktree-name> <title> <body-file> [<base-ref>]'; }
DRY=0; WAIT=0; REVIEWED=
while :; do case "${1:-}" in
  --dry-run) DRY=1; shift;;
  --wait-checks) WAIT=1; shift;;
  --reviewed-head) [ $# -ge 2 ] || usage; REVIEWED=$2; shift 2;;
  *) break;;
esac; done
[ $# -ge 4 ] && [ $# -le 5 ] && [[ "$REVIEWED" =~ ^[a-f0-9]{40}$ ]] || usage
ISSUE=$1; WTN=$2; TITLE=$3
[ -f "$4" ] || fail "no body file $4"
BODY=$(cd "$(dirname "$4")" && pwd)/$(basename "$4")
COMMON=$(git rev-parse --git-common-dir) || fail 'not inside a git checkout'
ROOT=$(cd "$COMMON/.." && pwd)
WT="$ROOT/worktrees/$WTN"
[ -d "$WT" ] || fail "no worktree at $WT"
POLL=${LAND_POLL_SECONDS:-15}; ATTEMPTS=${LAND_CHECK_ATTEMPTS:-120}
[[ "$POLL" =~ ^[0-9]+$ && "$ATTEMPTS" =~ ^[1-9][0-9]*$ ]] || fail 'invalid wait limits'
DEFAULT=$(git -C "$ROOT" symbolic-ref --short refs/remotes/origin/HEAD) || fail 'resolve origin/HEAD before landing'
DEFAULT=${DEFAULT#origin/}; BASE=${5:-$DEFAULT}; BASE=${BASE#origin/}
git -C "$ROOT" fetch -q origin
BR=$(git -C "$WT" branch --show-current); H=$(git -C "$WT" rev-parse HEAD)
B=$(git -C "$ROOT" rev-parse "origin/$BASE")
[ -n "$BR" ] && [ "$BR" != "$BASE" ] && [ "$BR" != "$DEFAULT" ] || fail 'use a ticket feature branch'
[ "$H" = "$REVIEWED" ] || fail 'worktree differs from reviewed head; gate it again'
[ -z "$(git -C "$WT" status --porcelain)" ] || fail "$WT is not clean; refusing"
git -C "$ROOT" merge-base --is-ancestor "$B" "$H" || fail "origin/$BASE is not merged into the tip; run a merge round"
if [ "$DRY" = 1 ]; then
  echo "would: push $BR and create or resume its PR to $BASE using $BODY"
  echo "would: verify reviewed head $H and unchanged base $B"
  [ "$WAIT" = 0 ] || echo 'would: wait for nonempty, successful current PR checks and recheck before merge'
  echo 'would: merge under normal policy; verify landing before deleting the ticket branch'
  exit 0
fi

# Query current rollup instead of trusting --watch's exit during cancellation/rerun transitions.
# CheckRun conclusions and legacy status contexts use different fields.
# shellcheck disable=SC2016 # $p belongs to jq, not the shell.
QUERY='. as $p | (["head", $p.headRefOid, $p.baseRefName] | @tsv),
  ($p.statusCheckRollup[] | ["check", (
    if .__typename == "CheckRun" then
      if .status != "COMPLETED" then "pending"
      elif (.conclusion == "SUCCESS" or .conclusion == "NEUTRAL" or .conclusion == "SKIPPED") then "success"
      else "failed" end
    elif .__typename == "StatusContext" then
      if .state == "SUCCESS" then "success" elif .state == "PENDING" or .state == "EXPECTED" then "pending" else "failed" end
    else "failed" end)] | @tsv)'
read_checks() {
  local snapshot kind value base seen=0 count=0 pending=0 bad=0
  snapshot=$(cd "$ROOT" && gh pr view "$PR" --json headRefOid,baseRefName,statusCheckRollup --jq "$QUERY") || fail 'cannot read PR checks; leave the PR open for handoff'
  while IFS=$'\t' read -r kind value base; do
    case "$kind" in
      head) [ "$value" = "$H" ] && [ "$base" = "$BASE" ] || fail 'PR head or base changed; gate it again'; seen=1;;
      check) count=$((count + 1)); case "$value" in success) ;; pending) pending=1;; *) bad=1;; esac;;
      *) fail 'unrecognized PR check response';;
    esac
  done <<< "$snapshot"
  [ "$seen" = 1 ] || fail 'missing PR identity'
  RESULT=success
  if [ "$bad" = 1 ]; then RESULT=failed
  elif [ "$count" = 0 ]; then RESULT=missing
  elif [ "$pending" = 1 ]; then RESULT=pending; fi
}

git -C "$WT" push -u origin "$BR"
PR=$(cd "$ROOT" && gh pr list --head "$BR" --base "$BASE" --state open --json url --jq 'if length == 1 then .[0].url elif length == 0 then "" else error("multiple PRs") end')
if [ -z "$PR" ]; then
  PR=$(cd "$WT" && gh pr create --base "$BASE" --head "$BR" --title "$TITLE" --body-file "$BODY")
fi
[[ "$PR" =~ /pull/[0-9]+$ ]] || fail "no PR URL returned: $PR"
echo "PR: $PR"
if [ "$WAIT" = 1 ]; then
  for ((attempt=1; attempt<=ATTEMPTS; attempt++)); do
    read_checks
    [ "$RESULT" != failed ] || fail 'failed or canceled checks; not merging'
    [ "$RESULT" != success ] || break
    [ "$attempt" = "$ATTEMPTS" ] || sleep "$POLL"
  done
  [ "$RESULT" = success ] || fail "checks $RESULT after bounded wait; not merging (resume this PR later)"
fi

# Revalidate after waiting. --match-head-commit also pins the merge request at GitHub.
[ "$(git -C "$WT" rev-parse HEAD)" = "$H" ] && [ -z "$(git -C "$WT" status --porcelain)" ] || fail 'local candidate changed; gate it again'
read_checks
[ "$RESULT" = success ] || { [ "$WAIT" = 0 ] && [ "$RESULT" = missing ]; } || fail "final checks $RESULT; not merging"
git -C "$ROOT" fetch -q origin
[ "$(git -C "$ROOT" rev-parse "origin/$BASE")" = "$B" ] || fail 'land base advanced; run a merge round'
(cd "$ROOT" && gh pr merge "$PR" --merge --match-head-commit "$H") || fail "merge blocked; retain $PR and follow repository policy"
LANDING=$(cd "$ROOT" && gh pr view "$PR" --json state,mergeCommit --jq '[.state, .mergeCommit.oid // ""] | @tsv')
IFS=$'\t' read -r STATE MERGE_SHA <<< "$LANDING"
[ "$STATE" = MERGED ] || fail "PR is $STATE, not merged; retain branch and follow the queued or pending PR"
git -C "$ROOT" fetch -q origin --prune
[[ "$MERGE_SHA" =~ ^[a-f0-9]{40}$ ]] || fail 'merged PR has no commit identity; retain branch'
[ "$(git -C "$ROOT" rev-parse "$MERGE_SHA^{tree}")" = "$(git -C "$ROOT" rev-parse "$H^{tree}")" ] || fail 'landed tree differs from gated candidate; retain branch and review remediation'
git -C "$ROOT" merge-base --is-ancestor "$H" "origin/$BASE" || fail 'remote base does not contain reviewed head; retain branch'
if [ -n "$(git -C "$ROOT" ls-remote --heads origin "$BR")" ]; then git -C "$ROOT" push origin --delete "$BR"; fi
if git -C "$ROOT" fetch -q origin "$BASE:$BASE" 2>/dev/null; then
  echo "local $BASE fast-forwarded"
else echo "update the clean checkout holding $BASE with: git merge --ff-only origin/$BASE"; fi
echo "merged: origin/$BASE $(git -C "$ROOT" rev-parse "origin/$BASE")"
echo "issue $ISSUE: $(cd "$ROOT" && gh issue view "$ISSUE" --json state --jq .state)"
