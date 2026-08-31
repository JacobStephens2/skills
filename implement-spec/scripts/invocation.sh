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
  echo "  --cli <cli>            grok (required)"
}

# shellcheck disable=SC2034
build_invocation() {
  local launcher="$1" cli="$2" kind="$3" prompt="$4"
  INVOCATION_CMD=()
  case "$cli" in
    grok) ;;
    *) echo "unknown CLI: $cli" >&2; return 1 ;;
  esac
  case "$launcher" in
    va) INVOCATION_CMD+=(va) ;;
    none) ;;
    *) echo "unknown launcher: $launcher" >&2; return 1 ;;
  esac
  INVOCATION_CMD+=("$cli" --always-approve)
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
