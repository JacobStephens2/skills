#!/usr/bin/env bash
# detach.sh <command> [args...]: run in a new session so the orchestrator's tool timeout cannot end it.
# Prints the child pid. The caller redirects the inner command's own output.
set -euo pipefail
python3 -c 'import sys, subprocess; p = subprocess.Popen(sys.argv[1:], stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True); print(p.pid)' "$@"
