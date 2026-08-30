#!/usr/bin/env bash
# automerge.sh <worktree-name> [<base-ref>]: when the land base moved and the dry run is clean, merge it into a detached
# scratch worktree worktrees/<name>-merge at the branch tip, prove the tree equals the automatic merge's, print the sha.
# Exit 2 with the conflict list means a merge round instead. Capture the suite on <name>-merge, then:
# automerge.sh --adopt <worktree-name>: fast-forward the branch worktree to the scratch tip and remove the scratch.
set -uo pipefail
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$SCRIPT_DIR" && cd "$(git rev-parse --git-common-dir)" && cd .. && pwd)
if [ "${1:-}" = "--adopt" ]; then
  WT="$ROOT/worktrees/$2"; M="$ROOT/worktrees/$2-merge"
  [ -d "$M" ] || { echo "no scratch merge at $M" >&2; exit 1; }
  SHA=$(git -C "$M" rev-parse HEAD)
  [ -z "$(git -C "$WT" status --porcelain)" ] || { echo "$WT is not clean; refusing" >&2; exit 1; }
  git -C "$WT" merge --ff-only "$SHA" >/dev/null || { echo "branch worktree cannot fast-forward to ${SHA:0:7}" >&2; exit 1; }
  git -C "$ROOT" worktree remove --force "$M" && git -C "$ROOT" worktree prune
  echo "adopted ${SHA:0:7} into $2 ($(git -C "$WT" branch --show-current)); scratch removed"; exit 0
fi
WT="$ROOT/worktrees/$1"; M="$ROOT/worktrees/$1-merge"
DEFAULT=$(git -C "$ROOT" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || { git -C "$ROOT" remote set-head origin -a >/dev/null 2>&1; git -C "$ROOT" symbolic-ref --short refs/remotes/origin/HEAD; })
BASE=${2:-$DEFAULT}
git -C "$ROOT" fetch -q origin
H=$(git -C "$WT" rev-parse HEAD); B=$(git -C "$ROOT" rev-parse "$BASE")
[ -z "$(git -C "$WT" status --porcelain)" ] || { echo "$WT is not clean; refusing" >&2; exit 1; }
if git -C "$ROOT" merge-base --is-ancestor "$B" "$H"; then echo "nothing to merge: $BASE (${B:0:7}) is already in ${H:0:7}"; exit 0; fi
if git -C "$ROOT" merge-base --is-ancestor "$H" "$B"; then echo "${H:0:7} is already inside $BASE (${B:0:7}): the branch has landed or is behind with nothing of its own; fast-forward the worktree by hand if you still need it"; exit 0; fi
if ! AUTO=$(git -C "$ROOT" merge-tree --write-tree "$H" "$B" 2>/dev/null); then
  echo "conflicts merging $BASE (${B:0:7}) into ${H:0:7}; this is a merge round:" >&2
  git -C "$ROOT" merge-tree --write-tree "$H" "$B" 2>&1 | grep -E "^CONFLICT" >&2; exit 2
fi
[ -d "$M" ] && { git -C "$ROOT" worktree remove --force "$M"; rm -rf "$M"; }
git -C "$ROOT" worktree add -q --detach "$M" "$H" || exit 1
# Link install dirs so the suite can run in the scratch.
(cd "$WT" && find . -maxdepth 3 \( -name .venv -o -name node_modules \) \( -type d -o -type l \)) | while IFS= read -r d; do
  mkdir -p "$(dirname "$M/$d")"
  [ -e "$M/$d" ] || ln -s "$WT/$d" "$M/$d"
done
git -C "$M" merge --no-edit -m "Merge $BASE (${B:0:7}) into $(git -C "$WT" branch --show-current)

An automatic merge: git combined both sides with no conflict, and the tree
equals git merge-tree's. Gated by the orchestrator's captured suite on this tree." "$B" >/dev/null || { echo "merge failed in $M" >&2; exit 1; }
SHA=$(git -C "$M" rev-parse HEAD)
[ "$(git -C "$M" rev-parse "$SHA^{tree}")" = "$AUTO" ] || { echo "tree of ${SHA:0:7} differs from the automatic merge; refusing" >&2; exit 1; }
echo "automatic merge ${SHA:0:7} of $BASE (${B:0:7}) into ${H:0:7} at $M (tree == merge-tree). Capture the suite on $1-merge, then: automerge.sh --adopt $1"
