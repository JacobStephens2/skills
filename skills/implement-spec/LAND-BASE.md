# Integration branches

Use this when the requested workflow lands tickets on an integration branch.
Check its rules and the final destination's rules during charting. Protection
alone does not authorize routing around review through a new branch.

Reuse the named integration ref, or create the agreed ref from the default
branch. Cut ticket worktrees from its latest tip and target ticket PRs there.
Delete individual ticket branches after landing; retain the shared integration
branch until its release is complete.

A merge to an integration branch does not trigger GitHub's default-branch issue
closure. Close completed implementation tickets explicitly when the agreed
workflow uses that milestone. Keep release tickets open for their own acceptance
criteria; use reference-only PR bodies while required rollout is outstanding.

Before the staging-to-default release PR, merge the current destination branch
into the candidate, preserve its changes, and gate the combined tree. The PR must
carry that tested tree. If an approving review is required, prepare the complete
PR and request the review; neither staging nor green CI waives that requirement.

After each merge, fetch and fast-forward the checkout that holds the land base.
Watch the post-merge checks configured for that branch: integration branches can
have their own CI. After the release merge, follow ROLLOUT.md when actual
deployment or activation is part of the ticket.
