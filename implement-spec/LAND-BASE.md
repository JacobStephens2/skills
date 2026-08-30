# Land base

Reached when a ticket's **land base** is not the default branch: it names an integration branch, or says it is not merged independently to the default. The chart already wrote that base. This file is how landing works on it.

## Open the ref

Cut the integration ref from the default branch's tip and push it. Worktrees for tickets that land there start on that ref, not on `origin/<default>`. PRs use `--base` that ref.

Close-on-merge in a PR body fires only when the merge is to the default branch. After merging to the integration ref, close the issue by hand and say so in the close comment.

The last ticket whose land base *is* the default branch merges `origin/<default>` first - a merge round - so a sibling that landed on the default while the spec ran is in the tree. Gate that merge. Then open the PR to the default branch. Done when `git log origin/<default>..` on that branch names only the cutover and the merge of what the default gained.

## Fast-forward

After a merge, fetch and fast-forward the **land-base** ref (and any worktree that holds it). The shared checkout of the default branch moves only when a ticket actually landed there.

## Post-merge gates

A merge to an integration ref is not a merge to the default branch. CI and any post-merge gate that watches the default branch will not run for it. Watch those gates only after a merge to the default.
