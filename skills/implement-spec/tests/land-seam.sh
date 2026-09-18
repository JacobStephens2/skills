#!/usr/bin/env bash
# Real temporary Git remotes + fake GitHub. Requires jq; never contacts GitHub.
set -euo pipefail
SRC=$(cd "$(dirname "$0")/../scripts" && pwd)
FIX=$(mktemp -d "${TMPDIR:-/tmp}/land-seam.XXXXXX")
trap 'rm -rf "$FIX"' EXIT
ORIGIN="$FIX/origin.git"; PRIMARY="$FIX/primary"; WT="$PRIMARY/worktrees/ticket"
BIN="$FIX/bin"; LOG="$FIX/gh.log"; COUNTER="$FIX/counter"; BODY="$FIX/body.md"
git init -q --bare --initial-branch=main "$ORIGIN"
git init -q --initial-branch=main "$PRIMARY"
git -C "$PRIMARY" config user.email test@example.invalid
git -C "$PRIMARY" config user.name Test
printf 'base\n' > "$PRIMARY/file"; printf 'worktrees/\n' > "$PRIMARY/.gitignore"
git -C "$PRIMARY" add -A; git -C "$PRIMARY" commit -qm base
git -C "$PRIMARY" remote add origin "$ORIGIN"; git -C "$PRIMARY" push -qu origin main
git -C "$PRIMARY" remote set-head origin -a >/dev/null
mkdir -p "$PRIMARY/worktrees" "$BIN"
git -C "$PRIMARY" worktree add -qb ticket "$WT"
printf 'ticket\n' > "$WT/file"; git -C "$WT" commit -qam ticket
printf 'Closes #4\n\nTest body.\n' > "$BODY"
cat > "$BIN/gh" <<'FAKE'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$FAKE_LOG"
case "$1 $2" in
  'pr list') [ "${FAKE_EXISTS:-0}" = 0 ] || echo https://github.com/o/r/pull/7 ;;
  'pr create') echo https://github.com/o/r/pull/7 ;;
  'pr checks') echo 'canceled but watch returned success' ;; # Historical regression: exit status alone was unsafe.
  'pr view')
    if [ "$5" = state,mergeCommit ]; then
      if [ "$FAKE_MODE" = queued ]; then printf 'OPEN\t\n'; else printf 'MERGED\t%s\n' "$(git -C "$FAKE_PRIMARY" ls-remote origin refs/heads/main | cut -f1)"; fi
      exit
    fi
    [ "$FAKE_MODE" != unreadable ] || { echo 'checks inaccessible' >&2; exit 1; }
    n=$(cat "$FAKE_COUNTER"); n=$((n + 1)); echo "$n" > "$FAKE_COUNTER"
    head=$(git -C "$FAKE_WT" rev-parse HEAD)
    checks='[{"__typename":"CheckRun","status":"COMPLETED","conclusion":"SUCCESS"},{"__typename":"StatusContext","state":"SUCCESS"}]'
    case "$FAKE_MODE" in
      canceled) checks='[{"__typename":"CheckRun","status":"COMPLETED","conclusion":"CANCELLED"}]' ;;
      failed) checks='[{"__typename":"CheckRun","status":"COMPLETED","conclusion":"FAILURE"}]' ;;
      legacy-failed) checks='[{"__typename":"StatusContext","state":"ERROR"}]' ;;
      unknown) checks='[{"__typename":"Unknown","state":"SUCCESS"}]' ;;
      missing) checks='[]' ;;
      pending) checks='[{"__typename":"CheckRun","status":"IN_PROGRESS","conclusion":null}]' ;;
      register-later) [ "$n" -ne 1 ] || checks='[]' ;;
      rerun-after-green) [ "$n" -lt 2 ] || checks='[{"__typename":"CheckRun","status":"IN_PROGRESS","conclusion":null}]' ;;
      cancel-after-green) [ "$n" -lt 2 ] || checks='[{"__typename":"CheckRun","status":"COMPLETED","conclusion":"CANCELLED"}]' ;;
      change-head) [ "$n" -lt 2 ] || head=0000000000000000000000000000000000000000 ;;
      dirty-during-wait) touch "$FAKE_WT/dirt" ;;
      advance-base|late-base)
        if { [ "$FAKE_MODE" = advance-base ] && [ "$n" = 1 ]; } || { [ "$FAKE_MODE" = late-base ] && [ "$n" = 2 ]; }; then
          echo advance > "$FAKE_PRIMARY/advance"
          git -C "$FAKE_PRIMARY" add advance; git -C "$FAKE_PRIMARY" commit -q --allow-empty -m advance
          git -C "$FAKE_PRIMARY" push -q origin main
        fi ;;
      neutral-skipped) checks='[{"__typename":"CheckRun","status":"COMPLETED","conclusion":"NEUTRAL"},{"__typename":"CheckRun","status":"COMPLETED","conclusion":"SKIPPED"}]' ;;
    esac
    jq -n --arg head "$head" --argjson checks "$checks" '{headRefOid:$head,baseRefName:"main",statusCheckRollup:$checks}' | jq -r "$7"
    ;;
  'pr merge')
    [ "$FAKE_MODE" != blocked ] || { echo 'review required' >&2; exit 1; }
    [ "$FAKE_MODE" != queued ] || exit 0
    # Require the actual CLI merge precondition, not just an earlier local comparison.
    [ "${5:-}" = --match-head-commit ] && [ "${6:-}" = "$(git -C "$FAKE_WT" rev-parse HEAD)" ] || exit 1
    git -C "$FAKE_WT" push -q origin HEAD:main
    if [ "$FAKE_MODE" = wrong-tree ]; then
      git -C "$FAKE_PRIMARY" merge -q --ff-only "$(git -C "$FAKE_WT" rev-parse HEAD)"
      echo untested > "$FAKE_PRIMARY/untested"
      git -C "$FAKE_PRIMARY" add untested; git -C "$FAKE_PRIMARY" commit -qm untested
      git -C "$FAKE_PRIMARY" push -q origin main
    fi ;;
  'issue view') echo CLOSED ;;
  *) echo "unexpected fake gh call: $*" >&2; exit 1 ;;
esac
FAKE
chmod +x "$BIN/gh"
export PATH="$BIN:$PATH" FAKE_LOG="$LOG" FAKE_COUNTER="$COUNTER" FAKE_WT="$WT" FAKE_PRIMARY="$PRIMARY"
export LAND_POLL_SECONDS=0 LAND_CHECK_ATTEMPTS=2 FAKE_MODE=success FAKE_EXISTS=0
PASS=0
pass() { PASS=$((PASS + 1)); echo "PASS: $*"; }
run() {
  : > "$LOG"; echo 0 > "$COUNTER"; RC=0
  OUT=$(cd "$WT" && "$SRC/land.sh" --reviewed-head "$HEAD" "$@" 4 ticket 'Title' "$BODY" 2>&1) || RC=$?
}
refuses() {
  FAKE_MODE=$1; run --wait-checks
  if [ "$RC" -eq 0 ] || grep -q '^pr merge' "$LOG"; then echo "FAIL $1: $OUT" >&2; exit 1; fi
  pass "$1 cannot reach merge"
}
HEAD=$(git -C "$WT" rev-parse HEAD)
if "$SRC/land.sh" > "$FIX/usage" 2>&1; then exit 1; fi
grep -q '^usage:' "$FIX/usage"; pass 'missing arguments produce usage'
run --dry-run --wait-checks
[ "$RC" -eq 0 ] && [ ! -s "$LOG" ] || exit 1; pass 'dry-run from worktree makes no GitHub calls'
ORIGINAL_HEAD=$HEAD; HEAD=0000000000000000000000000000000000000000
run --dry-run
[ "$RC" -ne 0 ] && [ ! -s "$LOG" ] || exit 1; pass 'wrong reviewed SHA refuses before push'
HEAD=$ORIGINAL_HEAD
touch "$WT/dirt"; run --dry-run
[ "$RC" -ne 0 ] && [ ! -s "$LOG" ] || exit 1; pass 'dirty worktree refuses'
rm "$WT/dirt"
FAKE_MODE=failed; run
[ "$RC" -ne 0 ] && ! grep -q '^pr merge' "$LOG" || exit 1; pass 'known failed checks refuse even without waiting'
for mode in canceled failed legacy-failed unknown unreadable missing pending rerun-after-green cancel-after-green change-head dirty-during-wait advance-base; do
  refuses "$mode"
  [ ! -e "$WT/dirt" ] || rm "$WT/dirt"
done
run --dry-run
[ "$RC" -ne 0 ] && [ ! -s "$LOG" ] || exit 1; pass 'advanced base requires a merge round on restart'
git -C "$WT" merge -q --no-edit origin/main
HEAD=$(git -C "$WT" rev-parse HEAD)
refuses late-base
git -C "$WT" merge -q --no-edit origin/main
HEAD=$(git -C "$WT" rev-parse HEAD)
for mode in blocked queued; do
  FAKE_MODE=$mode; run --wait-checks
  [ "$RC" -ne 0 ] && grep -q '^pr merge' "$LOG" || exit 1
  [ -n "$(git -C "$PRIMARY" ls-remote --heads origin ticket)" ]
  pass "$mode leaves the PR and branch available"
done
FAKE_MODE=register-later; FAKE_EXISTS=1; run --wait-checks
[ "$RC" -eq 0 ] && grep -q '^merged:' <<< "$OUT" || exit 1
[ "$(cat "$COUNTER")" -eq 3 ] && ! grep -q '^pr create' "$LOG" || exit 1
pass 'waits for registration, reuses existing PR, and rechecks before pinned merge'
[ -z "$(git -C "$PRIMARY" ls-remote --heads origin ticket)" ]; pass 'deletes branch only after verified merge'
# Another ticket checks the documented neutral/skipped terminal outcomes.
git -C "$WT" checkout -qb second
printf 'second\n' > "$WT/second"; git -C "$WT" add second; git -C "$WT" commit -qm second
HEAD=$(git -C "$WT" rev-parse HEAD); FAKE_MODE=neutral-skipped; FAKE_EXISTS=0
run --wait-checks
[ "$RC" -eq 0 ]; pass 'neutral and skipped are terminal; required coverage is checked by the skill gate'
git -C "$WT" checkout -qb third
printf 'third\n' > "$WT/third"; git -C "$WT" add third; git -C "$WT" commit -qm third
HEAD=$(git -C "$WT" rev-parse HEAD); FAKE_MODE=wrong-tree
run --wait-checks
[ "$RC" -ne 0 ] && grep -q 'landed tree differs' <<< "$OUT" || exit 1
[ -n "$(git -C "$PRIMARY" ls-remote --heads origin third)" ]
pass 'unexpected merged tree is a landing failure and retains the branch'
git -C "$WT" checkout -qb no-ci origin/main
printf 'no-ci\n' > "$WT/no-ci"; git -C "$WT" add no-ci; git -C "$WT" commit -qm no-ci
HEAD=$(git -C "$WT" rev-parse HEAD); FAKE_MODE=missing
run
[ "$RC" -eq 0 ]; pass 'explicit no-wait workflow can land a repository with no checks'
echo "$PASS passed"
