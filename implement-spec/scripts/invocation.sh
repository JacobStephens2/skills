#!/usr/bin/env bash
# Recipe table for a round's invocation. Sourced by launch, resume, and review.
# CLI flags live here and in each CLI's --help, not in SKILL.md or ROUNDS.md.
# Callers read DRY, LAUNCHER, CLI, WANT_HELP, ROUND_ARGS, INVOCATION_CMD.

# shellcheck disable=SC2034
parse_round_flags() {
  DRY=0
  LAUNCHER=
  CLI=
  WANT_HELP=0
  ROUND_ARGS=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run) DRY=1; shift ;;
      --launcher) LAUNCHER="${2:?--launcher needs a value}"; shift 2 ;;
      --cli) CLI="${2:?--cli needs a value}"; shift 2 ;;
      --help|-h) WANT_HELP=1; shift ;;
      *) ROUND_ARGS+=("$@"); return 0 ;;
    esac
  done
}

require_invocation() {
  if [ -z "$LAUNCHER" ] || [ -z "$CLI" ]; then
    echo "launcher and CLI are required (--launcher, --cli)" >&2
    return 1
  fi
}

print_invocation_help() {
  echo "  --dry-run              print the command without detaching"
  echo "  --launcher <launcher>  va or none (required)"
  echo "  --cli <cli>            grok, claude, or codex (required)"
}

# Session-id file for CLIs that record one; empty otherwise.
session_record_file() {
  case "$CLI" in
    codex) printf '%s\n' "$ROOT/worktrees/agent-logs/issue-$ISSUE.session" ;;
  esac
}

read_session_id() {
  local f
  f=$(session_record_file)
  if [ ! -s "$f" ]; then
    echo "no recorded session id for issue $ISSUE" >&2
    return 1
  fi
  tr -d '[:space:]' < "$f"
}

# First `session id:` line in a round log, or no-op. Used by launch after spawn.
record_session_id() {
  local log="$1" dest="$2" sid
  [ -n "$dest" ] && [ -f "$log" ] || return 0
  sid=$(awk '/^session id:[[:space:]]*/ { sub(/^session id:[[:space:]]*/, ""); print; exit }' "$log")
  [ -n "$sid" ] || return 0
  printf '%s\n' "$sid" > "$dest"
}

# shellcheck disable=SC2034
build_invocation() {
  local launcher="$1" cli="$2" kind="$3" prompt="$4"
  local permission_flag
  INVOCATION_CMD=()
  case "$cli" in
    grok) permission_flag=--always-approve ;;
    claude) permission_flag=--dangerously-skip-permissions ;;
    codex) ;;
    *) echo "unknown CLI: $cli" >&2; return 1 ;;
  esac
  case "$launcher" in
    va) INVOCATION_CMD+=(va) ;;
    none) ;;
    *) echo "unknown launcher: $launcher" >&2; return 1 ;;
  esac
  if [ "$cli" = codex ]; then
    INVOCATION_CMD+=(codex exec)
    if [ "$kind" = resume ]; then
      local sid
      sid=$(read_session_id) || return 1
      INVOCATION_CMD+=(resume --dangerously-bypass-approvals-and-sandbox "$sid" "$prompt")
    else
      INVOCATION_CMD+=(--dangerously-bypass-approvals-and-sandbox "$prompt")
    fi
    return 0
  fi
  INVOCATION_CMD+=("$cli" "$permission_flag")
  [ "$kind" = resume ] && INVOCATION_CMD+=(-c)
  INVOCATION_CMD+=(-p "$prompt")
}

print_would() {
  printf 'would:'
  local w
  for w in "${INVOCATION_CMD[@]}"; do
    printf ' %q' "$w"
  done
  printf '\n'
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo "source invocation.sh from launch, resume, or review" >&2
  exit 1
fi
