#!/usr/bin/env bash
# land.sh seam: dry-run output, refusals, and the checks fallback, against a bare origin and a fake gh. No live GitHub.
set -uo pipefail
SRC=$(cd "$(dirname "$0")/../scripts" && pwd)
PASS=0; FAIL=0; FIX=
cleanup() { [ -n "$FIX" ] && [ -d "$FIX" ] && rm -rf "$FIX"; }
trap cleanup EXIT
fail() { echo "FAIL: $*" >&2; FAIL=$((FAIL + 1)); }
pass() { echo "PASS: $*"; PASS=$((PASS + 1)); }

FIX=$(mktemp -d "${TMPDIR:-/tmp}/land-seam.XXXXXX")
ORIGIN="$FIX/origin.git"; PRIMARY="$FIX/primary"; BIN="$FIX/bin"; GHLOG="$FIX/gh.log"; WT="$PRIMARY/worktrees/wt"
git init -q --bare --initial-branch=main "$ORIGIN"
git init -q --initial-branch=main "$PRIMARY"
git -C "$PRIMARY" config user.email t@t
git -C "$PRIMARY" config user.name t
echo base > "$PRIMARY/file"; echo "worktrees/" > "$PRIMARY/.gitignore"; git -C "$PRIMARY" add -A; git -C "$PRIMARY" commit -q -m base
git -C "$PRIMARY" remote add origin "$ORIGIN"; git -C "$PRIMARY" push -q -u origin main; git -C "$PRIMARY" remote set-head origin -a
mkdir -p "$PRIMARY/worktrees"
git -C "$PRIMARY" worktree add -q "$WT" -b wt-branch
echo change > "$WT/file"; git -C "$WT" commit -q -am change
BODY="$FIX/body.md"; printf 'Closes #4\n\nbody\n' > "$BODY"

mkdir -p "$BIN"
cat > "$BIN/gh" <<'FAKE'
#!/usr/bin/env bash
# Fake gh: records every call to FAKE_GH_LOG; FAKE_GH_CHECKS (ok|pat) and FAKE_GH_RUNS (success|failure) pick the branch.
printf '%s\n' "$*" >> "$FAKE_GH_LOG"
case "$1 $2" in
  "pr create") echo "https://github.com/o/r/pull/7" ;;
  "pr checks")
    case "${FAKE_GH_CHECKS:-ok}" in
      pat) echo "error: Resource not accessible by personal access token" >&2; exit 1 ;;
      *) printf 'build\tpass\t1m\thttps://github.com/o/r/actions/runs/1\n' ;;
    esac ;;
  "repo view") echo "o/r" ;;
  "api "*)
    case "${FAKE_GH_RUNS:-success}" in
      failure) printf 'build\tcompleted\tfailure\n' ;;
      *) printf 'build\tcompleted\tsuccess\n' ;;
    esac ;;
  "pr merge") git -C "$FAKE_GH_WT" push -q origin HEAD:main ;;
  "issue view") echo "CLOSED" ;;
  *) echo "fake gh: unhandled: $*" >&2; exit 1 ;;
esac
FAKE
chmod +x "$BIN/gh"
export PATH="$BIN:$PATH" FAKE_GH_LOG="$GHLOG" FAKE_GH_WT="$WT" LAND_POLL_SECONDS=0 LAND_SETTLE_SECONDS=0

rc=0; out=$("$SRC/land.sh" 2>&1) || rc=$?
if [ "$rc" -ne 0 ] && grep -q '^usage' <<<"$out"; then pass "no arguments prints usage and exits non-zero"; else fail "no arguments: rc=$rc out: $out"; fi

: > "$GHLOG"
rc=0; out=$(cd "$WT" && "$SRC/land.sh" --dry-run --wait-checks 4 wt "Title" "$BODY" 2>&1) || rc=$?
if [ "$rc" -eq 0 ] && grep -q '^would: gh pr create --base main --head wt-branch' <<<"$out" && grep -q '^would: wait for' <<<"$out" && [ ! -s "$GHLOG" ]; then
  pass "dry-run from inside the worktree prints the commands and calls nothing"
else fail "dry-run: rc=$rc out: $out"; fi

echo dirt > "$WT/dirt"
rc=0; out=$(cd "$PRIMARY" && "$SRC/land.sh" --dry-run 4 wt "Title" "$BODY" 2>&1) || rc=$?
if [ "$rc" -ne 0 ] && grep -q 'not clean' <<<"$out"; then pass "dirty worktree refuses"; else fail "dirty worktree: rc=$rc out: $out"; fi
rm -f "$WT/dirt"

echo more > "$PRIMARY/other"; git -C "$PRIMARY" add -A; git -C "$PRIMARY" commit -q -m more; git -C "$PRIMARY" push -q origin main
rc=0; out=$(cd "$PRIMARY" && "$SRC/land.sh" --dry-run 4 wt "Title" "$BODY" 2>&1) || rc=$?
if [ "$rc" -ne 0 ] && grep -q 'not merged into' <<<"$out"; then pass "land base not merged into the tip refuses"; else fail "base not merged: rc=$rc out: $out"; fi
git -C "$WT" merge -q --no-edit origin/main

: > "$GHLOG"
rc=0; out=$(cd "$PRIMARY" && FAKE_GH_CHECKS=pat FAKE_GH_RUNS=success "$SRC/land.sh" --wait-checks 4 wt "Title" "$BODY" 2>&1) || rc=$?
if [ "$rc" -eq 0 ] && grep -q '^merged: origin/main' <<<"$out" && grep -q '^api repos/o/r/actions/runs' "$GHLOG" && grep -q '^pr merge 7' "$GHLOG"; then
  pass "a token that cannot read PR checks lands on the Actions runs instead"
else fail "PAT fallback success: rc=$rc out: $out gh: $(cat "$GHLOG")"; fi
if ! git -C "$PRIMARY" ls-remote --heads origin wt-branch | grep -q .; then pass "remote branch deleted after the merge"; else fail "remote branch still exists"; fi

WT2="$PRIMARY/worktrees/wt2"
git -C "$PRIMARY" worktree add -q "$WT2" -b wt2-branch origin/main
echo two > "$WT2/two"; git -C "$WT2" add -A; git -C "$WT2" commit -q -m two
export FAKE_GH_WT="$WT2"
: > "$GHLOG"
rc=0; out=$(cd "$PRIMARY" && FAKE_GH_CHECKS=pat FAKE_GH_RUNS=failure "$SRC/land.sh" --wait-checks 4 wt2 "Title" "$BODY" 2>&1) || rc=$?
if [ "$rc" -ne 0 ] && grep -q 'not merging' <<<"$out" && ! grep -q '^pr merge' "$GHLOG"; then
  pass "a failed Actions run stops the landing before the merge"
else fail "PAT fallback failure: rc=$rc out: $out gh: $(cat "$GHLOG")"; fi

: > "$GHLOG"
rc=0; out=$(cd "$PRIMARY" && FAKE_GH_CHECKS=ok "$SRC/land.sh" --wait-checks 4 wt2 "Title" "$BODY" 2>&1) || rc=$?
if [ "$rc" -eq 0 ] && grep -q '^merged: origin/main' <<<"$out" && grep -q '^pr checks 7 --watch --fail-fast' "$GHLOG" && ! grep -q '^api ' "$GHLOG"; then
  pass "readable PR checks are watched and the Actions API is not called"
else fail "checks ok: rc=$rc out: $out gh: $(cat "$GHLOG")"; fi

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
