# Tickets that require rollout

A code merge may prepare a release without completing it. Use this branch of the
workflow only when the ticket requires deployment, migration, provider setup or
external activation. Keep that ticket open through its actual acceptance checks.

## Chart the phases

Record each required phase, its environment, evidence and authorized actor:

1. **Preparation:** reviewed code, configuration procedure, migration plan and
   recovery procedure. A preparation PR uses `Refs #<ticket>`, not a closing line.
2. **Release:** combined candidate merged to its destination under normal branch
   policy, with applicable CI and required reviews satisfied.
3. **Deployment:** actual code, storage, configuration and access are ready on the
   intended target, verified through the normal deployment mechanism.
4. **Activation and smoke:** the external path is enabled only after its receiving
   and permission boundaries work; controlled end-to-end checks establish the
   ticket's outcome.

Omit phases the ticket does not require. A phase cannot waive an open blocker
within its own scope. Separating a merge from activation does not authorize
merging a branch held for a spec conflict.

## Refresh before acting

Record the live revision, environment/database identity, migration ledger and
hashes, relevant permission sources, provider routes and pending deliveries.
Refresh these immediately before the dependent action: another operator may have
deployed while review ran. Derive pending work from current state, preserving
later grants and revocations rather than replaying an old plan.

Apply the environment's migration, deletion and deployment rules to what will
actually execute. Complete the concrete, reviewable preparation before requesting
any still-required approval. Distinguish code release, business acceptance and
public activation; authorization for one does not silently decide the others.

## Observe and recover

Exercise the real path with authorized testers and controlled data. Provider
acceptance is not recipient delivery or placement; an empty callback is not
persistence; skipped tests are not coverage. Record stable message/attempt IDs,
timestamps at relevant boundaries, and artifact hashes when byte integrity
matters. Reconcile an ambiguous result before retrying a send or provider mutation.

Keep temporary access and route changes in the chart with exact restoration
steps. Restore temporary access before handoff; retain intake needed for accepted
or delayed traffic. After external work may have been accepted, a generic code
rollback can remove its receiver. Recovery must preserve compatible processing,
accepted data, retry keys and required configuration. Describe backup/restore
limits according to observed evidence, without claiming an unperformed restore.

Close the ticket only after the required rollout and smoke evidence exists and
remaining human decisions are resolved. If blocked, hand off the ready artifact,
exact next action and current live state; leave the spec open.
