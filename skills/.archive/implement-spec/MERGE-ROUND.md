# Merge round

Use when the ticket's land base or final release destination advances. Continue
the implementer in its existing worktree with this prompt, filling only the
relevant details:

> `<base>` advanced to `<sha>` while this ticket was in flight. In `<worktree>`,
> fetch and merge `origin/<base>` without rewriting reviewed commits. Resolve
> conflicts according to both changes' intended behavior; blindly taking the
> union can also be wrong. Regenerate generated files using the repository's
> command. Run `<charted checks>`, commit the combined result and report the
> resolutions and evidence. Leave pushing and landing to the orchestrator.

Inspect and gate that combined commit. Refresh the base before landing; if it
moves again, repeat only the merge and verification needed for the new changes.
