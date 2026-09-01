#!/usr/bin/env bash
# Round-script seam: dry-print argv or non-zero exit. No live agent.
set -euo pipefail

SRC=$(cd "$(dirname "$0")/../scripts" && pwd)
PASS=0
FAIL=0
FIX=

cleanup() {
  if [ -n "$FIX" ] && [ -d "$FIX" ]; then
    git -C "$FIX" worktree prune >/dev/null 2>&1 || true
    rm -rf "$FIX"
  fi
}
trap cleanup EXIT

fail() { echo "FAIL: $*" >&2; FAIL=$((FAIL + 1)); }
pass() { echo "PASS: $*"; PASS=$((PASS + 1)); }

setup_fixture() {
  FIX=$(mktemp -d "${TMPDIR:-/tmp}/round-spawn.XXXXXX")
  git init -q "$FIX"
  git -C "$FIX" config user.email t@t
  git -C "$FIX" config user.name t
  mkdir -p "$FIX/implement-spec/scripts" "$FIX/worktrees"
  cp "$SRC"/*.sh "$FIX/implement-spec/scripts/"
  cat > "$FIX/implement-spec/scripts/detach.sh" <<'EOF'
#!/usr/bin/env bash
echo "detach must not run during dry-print" >&2
exit 99
EOF
  chmod +x "$FIX/implement-spec/scripts"/*.sh
  git -C "$FIX" add -A
  git -C "$FIX" commit -q -m init
  git -C "$FIX" worktree add -q "$FIX/worktrees/wt" -b wt-branch
}

LAUNCH() { "$FIX/implement-spec/scripts/launch.sh" "$@"; }
RESUME() { "$FIX/implement-spec/scripts/resume.sh" "$@"; }
REVIEW() { "$FIX/implement-spec/scripts/review.sh" "$@"; }

REF=https://github.com/JacobStephens2/skills/issues/4

# Parse a would: line (printf %q words) and compare argv to the expected tokens.
assert_argv() {
  local name="$1" line="$2" rest nexp i want expected
  shift 2
  nexp=$#
  i=0
  for want; do
    i=$((i + 1))
    eval "exp_$i=\$want"
  done
  case "$line" in
    would:*) ;;
    *) fail "$name; not a would: line: ${line:-<empty>}"; return ;;
  esac
  rest=${line#would:}
  eval "set -- $rest"
  if [ "$#" -ne "$nexp" ]; then
    fail "$name; $# words, want $nexp; got: $line"
    return
  fi
  i=0
  for want; do
    i=$((i + 1))
    eval "expected=\$exp_$i"
    if [ "$want" != "$expected" ]; then
      fail "$name; word $i is '$want', want '$expected'; got: $line"
      return
    fi
  done
  pass "$name"
}

assert_required() {
  local name="$1" rc="$2" err="$3"
  if [ "$rc" -ne 0 ] && printf '%s\n' "$err" | grep -q 'required'; then
    pass "$name"
  else
    fail "$name; rc=$rc out: $err"
  fi
}

setup_fixture

rc=0
err=$(LAUNCH --dry-run 4 wt "$REF" 2>&1) || rc=$?
assert_required "omitted invocation launch exits non-zero" "$rc" "$err"

rc=0
err=$(LAUNCH --dry-run --cli grok 4 wt "$REF" 2>&1) || rc=$?
assert_required "launch with only --cli exits non-zero" "$rc" "$err"

rc=0
err=$(LAUNCH --dry-run --launcher none 4 wt "$REF" 2>&1) || rc=$?
assert_required "launch with only --launcher exits non-zero" "$rc" "$err"

out=$(LAUNCH --dry-run --launcher va --cli grok 4 wt "$REF") || fail "va grok launch --dry-run exited $?"
assert_argv "launcher va CLI grok launch matches today's va grok command" "$out" \
  va grok --always-approve -p "/implement $REF"

out=$(LAUNCH --dry-run --launcher va --cli claude 4 wt "$REF") || fail "va claude launch --dry-run exited $?"
assert_argv "launcher va CLI claude launch prefixes va" "$out" \
  va claude --dangerously-skip-permissions -p "/implement $REF"

out=$(LAUNCH --dry-run --launcher none --cli grok 4 wt "$REF") || fail "none grok launch --dry-run exited $?"
assert_argv "launcher none CLI grok launch is bare grok with non-interactive permission flags" "$out" \
  grok --always-approve -p "/implement $REF"

out=$(LAUNCH --dry-run --launcher none --cli claude 4 wt "$REF") || fail "none claude launch --dry-run exited $?"
assert_argv "launcher none CLI claude launch is bare claude with non-interactive permission flags" "$out" \
  claude --dangerously-skip-permissions -p "/implement $REF"

out=$(LAUNCH --dry-run --launcher none --cli codex 4 wt "$REF") || fail "none codex launch --dry-run exited $?"
assert_argv "launcher none CLI codex launch is Codex headless exec with non-interactive permission flags" "$out" \
  codex exec --dangerously-bypass-approvals-and-sandbox "/implement $REF"

out=$(LAUNCH --dry-run --launcher va --cli codex 4 wt "$REF") || fail "va codex launch --dry-run exited $?"
assert_argv "launcher va CLI codex launch prefixes va" "$out" \
  va codex exec --dangerously-bypass-approvals-and-sandbox "/implement $REF"

rc=0
err=$(LAUNCH --dry-run --launcher none --cli unknown 4 wt "$REF" 2>&1) || rc=$?
if [ "$rc" -ne 0 ] && printf '%s\n' "$err" | grep -q 'unknown CLI'; then
  pass "unknown CLI launch exits non-zero"
else
  fail "unknown CLI launch rc=$rc out: $err"
fi

echo dirt > "$FIX/worktrees/wt/dirty"
rc=0
err=$(LAUNCH --dry-run --launcher none --cli grok 4 wt "$REF" 2>&1) || rc=$?
if [ "$rc" -ne 0 ] && printf '%s\n' "$err" | grep -q 'not clean'; then
  pass "dirty worktree refuses launch"
else
  fail "dirty worktree launch rc=$rc out: $err"
fi
rm -f "$FIX/worktrees/wt/dirty"

PF="$FIX/prompt.txt"
printf 'review findings\n' > "$PF"

rc=0
err=$(RESUME --dry-run 4 wt "$PF" 2>&1) || rc=$?
assert_required "omitted invocation resume exits non-zero" "$rc" "$err"

out=$(RESUME --dry-run --launcher va --cli grok 4 wt "$PF") || fail "va grok resume --dry-run exited $?"
assert_argv "launcher va CLI grok resume includes continue" "$out" \
  va grok --always-approve -c -p "review findings"

out=$(RESUME --dry-run --launcher none --cli grok 4 wt "$PF") || fail "none grok resume --dry-run exited $?"
assert_argv "launcher none CLI grok resume is bare grok continue" "$out" \
  grok --always-approve -c -p "review findings"

out=$(RESUME --dry-run --launcher va --cli claude 4 wt "$PF") || fail "va claude resume --dry-run exited $?"
assert_argv "launcher va CLI claude resume uses cwd-scoped continue" "$out" \
  va claude --dangerously-skip-permissions -c -p "review findings"

out=$(RESUME --dry-run --launcher none --cli claude 4 wt "$PF") || fail "none claude resume --dry-run exited $?"
assert_argv "launcher none CLI claude resume uses cwd-scoped continue" "$out" \
  claude --dangerously-skip-permissions -c -p "review findings"

rc=0
err=$(RESUME --dry-run --launcher none --cli codex 4 wt "$PF" 2>&1) || rc=$?
if [ "$rc" -ne 0 ] && printf '%s\n' "$err" | grep -q 'session id'; then
  pass "codex resume without recorded session id exits non-zero"
else
  fail "codex resume without session id rc=$rc out: $err"
fi

mkdir -p "$FIX/worktrees/agent-logs"
CLOG="$FIX/worktrees/agent-logs/codex-human.log"
CDEST="$FIX/worktrees/agent-logs/parsed.session"
# Default `codex exec` (no --json) prints a human config summary to stderr.
cat > "$CLOG" <<'EOF'
# launched 2026-08-31T00:00:00Z issue=4 worktree=wt head=abc123 ref=https://github.com/JacobStephens2/skills/issues/4
OpenAI Codex v0.50.0
--------
workdir: /tmp/wt
model: gpt-5
provider: openai
approval: never
sandbox: danger-full-access
reasoning effort: medium
reasoning summaries: auto
session id: 0199a213-81c0-7800-8aa1-bbab2a035a53
--------
user
/implement https://github.com/JacobStephens2/skills/issues/4
EOF
# shellcheck disable=SC1091
. "$FIX/implement-spec/scripts/invocation.sh"
record_session_id "$CLOG" "$CDEST"
got=
if [ -s "$CDEST" ]; then
  got=$(tr -d '[:space:]' < "$CDEST")
fi
if [ "$got" = "0199a213-81c0-7800-8aa1-bbab2a035a53" ]; then
  pass "codex human exec log records a session id"
else
  fail "codex human exec log records a session id; got '${got:-<empty>}'"
fi

printf '01997dac-9581-7de3-b6a0-1df8256f2752\n' > "$FIX/worktrees/agent-logs/issue-4.session"

out=$(RESUME --dry-run --launcher none --cli codex 4 wt "$PF") || fail "none codex resume --dry-run exited $?"
assert_argv "launcher none CLI codex resume includes the recorded session id" "$out" \
  codex exec resume --dangerously-bypass-approvals-and-sandbox 01997dac-9581-7de3-b6a0-1df8256f2752 "review findings"

out=$(RESUME --dry-run --launcher va --cli codex 4 wt "$PF") || fail "va codex resume --dry-run exited $?"
assert_argv "launcher va CLI codex resume prefixes va and includes the recorded session id" "$out" \
  va codex exec resume --dangerously-bypass-approvals-and-sandbox 01997dac-9581-7de3-b6a0-1df8256f2752 "review findings"

rc=0
err=$(RESUME --dry-run --launcher none --cli unknown 4 wt "$PF" 2>&1) || rc=$?
if [ "$rc" -ne 0 ] && printf '%s\n' "$err" | grep -q 'unknown CLI'; then
  pass "unknown CLI resume exits non-zero"
else
  fail "unknown CLI resume rc=$rc out: $err"
fi

FP=abc123
REVIEW_PROMPT="/code-review $FP. The originating ticket is #4: fetch it with the workflow in docs/agents/issue-tracker.md (the repo may be private; a web fetch will not open it). Report only; edit nothing."

rc=0
err=$(REVIEW --dry-run 4 wt "$FP" 2>&1) || rc=$?
assert_required "omitted invocation review exits non-zero" "$rc" "$err"

out=$(REVIEW --dry-run --launcher va --cli grok 4 wt "$FP") || fail "va grok review --dry-run exited $?"
assert_argv "launcher va CLI grok review matches today's fresh va grok command" "$out" \
  va grok --always-approve -p "$REVIEW_PROMPT"

out=$(REVIEW --dry-run --launcher none --cli grok 4 wt "$FP") || fail "none grok review --dry-run exited $?"
assert_argv "launcher none CLI grok review is a fresh bare grok command" "$out" \
  grok --always-approve -p "$REVIEW_PROMPT"

out=$(REVIEW --dry-run --launcher va --cli claude 4 wt "$FP") || fail "va claude review --dry-run exited $?"
assert_argv "launcher va CLI claude review is a fresh claude process of the same invocation" "$out" \
  va claude --dangerously-skip-permissions -p "$REVIEW_PROMPT"

out=$(REVIEW --dry-run --launcher none --cli claude 4 wt "$FP") || fail "none claude review --dry-run exited $?"
assert_argv "launcher none CLI claude review is a fresh claude process of the same invocation" "$out" \
  claude --dangerously-skip-permissions -p "$REVIEW_PROMPT"

out=$(REVIEW --dry-run --launcher none --cli codex 4 wt "$FP") || fail "none codex review --dry-run exited $?"
assert_argv "launcher none CLI codex review is a fresh Codex exec of the same invocation" "$out" \
  codex exec --dangerously-bypass-approvals-and-sandbox "$REVIEW_PROMPT"

out=$(REVIEW --dry-run --launcher va --cli codex 4 wt "$FP") || fail "va codex review --dry-run exited $?"
assert_argv "launcher va CLI codex review prefixes va on a fresh Codex exec" "$out" \
  va codex exec --dangerously-bypass-approvals-and-sandbox "$REVIEW_PROMPT"

LEDGER="$FIX/worktrees/agent-logs/findings-4.md"
CORRECTION_BASE=$(git -C "$FIX/worktrees/wt" rev-parse HEAD)
printf 'reviewed-head: %s\n\n- blocker: exact failure\n' "$CORRECTION_BASE" > "$LEDGER"
LEDGER=$(cd "$(dirname "$LEDGER")" && pwd)/$(basename "$LEDGER")
CORRECTION_PROMPT="/code-review $CORRECTION_BASE. The originating ticket is #4: fetch it with the workflow in docs/agents/issue-tracker.md (the repo may be private; a web fetch will not open it). This is a correction verification against a fixed approval bar. Read the blocker ledger at $LEDGER. Verify each recorded blocker against current HEAD and report concrete regressions in the correction diff after $CORRECTION_BASE. Keep pre-existing architectural alternatives and preferences as suggestions, not blockers. Report only; edit nothing."

out=$(REVIEW --dry-run --launcher none --cli grok 4 wt "$CORRECTION_BASE" "$LEDGER") || fail "grok correction review --dry-run exited $?"
assert_argv "correction review carries the fixed blocker ledger" "$out" \
  grok --always-approve -p "$CORRECTION_PROMPT"

git -C "$FIX/worktrees/wt" commit -q --allow-empty -m correction
MISMATCHED_BASE=$(git -C "$FIX/worktrees/wt" rev-parse HEAD)
rc=0
err=$(REVIEW --dry-run --launcher none --cli grok 4 wt "$MISMATCHED_BASE" "$LEDGER" 2>&1) || rc=$?
if [ "$rc" -ne 0 ] && printf '%s\n' "$err" | grep -q 'does not match'; then
  pass "correction review fixed point must match the blocker ledger"
else
  fail "mismatched correction fixed point rc=$rc out: $err"
fi

rc=0
err=$(REVIEW --dry-run --launcher none --cli grok 4 wt "$FP" "$FIX/missing-ledger.md" 2>&1) || rc=$?
if [ "$rc" -ne 0 ] && printf '%s\n' "$err" | grep -q 'blocker ledger not found'; then
  pass "correction review requires its blocker ledger"
else
  fail "missing correction ledger rc=$rc out: $err"
fi

rc=0
err=$(REVIEW --dry-run --launcher none --cli unknown 4 wt "$FP" 2>&1) || rc=$?
if [ "$rc" -ne 0 ] && printf '%s\n' "$err" | grep -q 'unknown CLI'; then
  pass "unknown CLI review exits non-zero"
else
  fail "unknown CLI review rc=$rc out: $err"
fi

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
