---
name: adjudicate-adversarial-review
description: Adjudicate an adversarial review of a plan you authored, verify every finding against evidence, and produce a complete revised plan. Use when asked to adjudicate, triage, respond to, or resolve adversarial-review or red-team findings; accept, reject, or defer reviewer feedback; reconcile a plan with a cross-model (Agent B) review; or revise a plan after an adversarial review, pre-mortem, or stress-test.
---

# Adjudicate Adversarial Review

You wrote the original plan below. Agent B, from a different model family, performed an
adversarial review.

Your task is to adjudicate the review and revise the plan. Two failure modes disqualify the
output equally: defending the original plan merely because you authored it, and accepting
findings merely because they were presented confidently. Evidence decides every disposition;
neither author nor reviewer holds authority.

## Inputs

- Original plan: [PATH OR PASTE]
- Adversarial review: [PATH OR PASTE]
- Governing requirements/specification: [PATHS OR PASTE]
- Repository or system context: [PATHS, IF APPLICABLE]

If the governing requirements are missing, reconstruct intent from the plan and repository, but
label every inferred constraint as inferred; do not invent requirements to settle a dispute.
Keep the work read-only except for the revised plan and any artifact the user explicitly asks
you to write.

## Adjudication workflow

### 1. Re-establish intent

Read the original requirements and constraints before evaluating the review. Identify the
plan's objective, non-negotiable requirements, assumptions, and success criteria. Adjudicate
against these — not against the plan's prose and not against the review's framing. If the
review and the plan disagree about what the requirements say, the requirements win.

### 2. Verify every finding

Assign each finding a stable ID if the review did not (B1, B2, ...). For each finding:

- Locate the affected part of the plan. If it cannot be located, that is evidence about the
  finding, not a reason to skip it.
- Check the claim against the requirements, repository, documentation, tests, APIs, and other
  available evidence. Prefer repository evidence and primary documentation over the review's
  assertions, the plan's assertions, or memory. Verify current product, platform, API,
  pricing, policy, or compatibility claims against current authoritative sources.
- Determine whether the proposed failure scenario is realistic end to end, not merely
  well narrated.
- Check whether the review misunderstood an explicit constraint, attacked a documented and
  accepted trade-off, or introduced unnecessary scope.
- Re-derive severity from the evidence. Do not treat the reviewer's severity, confidence, or
  recommendation as authoritative — and do not treat your original design intent as
  authoritative either.
- Label anything that cannot be established as **needs verification**; that usually indicates
  DEFER, not ACCEPT or REJECT.

### 3. Assign a disposition

Classify every finding as exactly one of:

- **ACCEPT** — Correct and requires a plan change.
- **PARTIALLY ACCEPT** — Valid concern, but the diagnosis, severity, or proposed remedy is
  incomplete or excessive.
- **REJECT** — Incorrect, irrelevant, contradicted by evidence, or based on a misunderstanding.
- **DEFER** — Potentially valid but cannot be resolved without a named decision, experiment,
  measurement, or stakeholder input. Every DEFER must name its closure mechanism and owner; a
  DEFER without one is an unfinished adjudication.
- **DUPLICATE** — Substantively covered by another finding; point to the finding that carries
  the fix.

For every finding, establish:

- Finding ID
- Disposition
- Verified severity: critical, high, medium, or low
- Evidence
- Reasoning summary
- Effect on the plan
- Exact corrective action, if any

Do not silently omit any finding.

Use these severity definitions, matching the adversarial-review skill:

- **Critical:** Prevents the plan from achieving a core outcome, makes the recommended path
  infeasible, or creates an unacceptable security, safety, or data-loss risk.
- **High:** Likely to cause material failure, outage, bypass, rework, or major requirement
  loss.
- **Medium:** Meaningful design or operational gap likely to create avoidable rework or
  degraded behavior, but not an immediate blocker.
- **Low:** Limited-impact ambiguity, maintainability issue, or refinement with a contained
  failure radius.

### 4. Apply adjudication heuristics

Use these transferable checks:

- Confidence, severity labels, and vivid failure narratives are claims, not evidence.
- A finding that restates a trade-off the requirements explicitly accept is a REJECT — cite
  where it was accepted.
- A finding correct about the symptom but wrong about the cause is a PARTIALLY ACCEPT with a
  corrected diagnosis; fixing the reviewer's stated cause would leave the defect in place.
- A valid defect does not validate its proposed remedy. Accept the defect and reject a remedy
  that adds architecture, abstractions, fallback paths, or scope beyond what fixes it.
- A reviewer misreading can still expose a real clarity defect: reject the finding, then fix
  the ambiguity that invited it.
- Failing to refute a finding is not the same as confirming it; check what evidence supports
  the plan's side before rejecting.
- An open question is not a defect unless the plan commits money, migration, or architecture
  before resolving it.
- PARTIALLY ACCEPT is a verdict about a genuinely split finding, not a compromise to appear
  balanced. Do not split the difference; skewed accept or reject counts are fine when the
  evidence is skewed.
- Two findings sharing a root cause get one fix: one carries the disposition, the other is
  DUPLICATE.

### 5. Look beyond the review

After adjudicating Agent B's findings, independently inspect the original plan for important
problems Agent B missed — the reviewer's coverage is not proof of absence. Check at least the
lenses the review skipped or treated thinly: correctness, completeness, feasibility, failure
domains, security and privacy, reliability and operations, performance and cost, concurrency
and time, migration and rollback, validation, and complexity. Label these as NEW findings
(NEW1, NEW2, ...) and evaluate them with the same evidence standard and dispositions. Do not
manufacture NEW findings to appear thorough; "None" is an acceptable answer.

### 6. Resolve interactions

Check whether accepting one finding invalidates another step, creates a new dependency,
changes sequencing, or introduces new risks. Re-check earlier dispositions after later ones:
an accepted change can moot, strengthen, or contradict a prior finding. Prefer the smallest
change that fully resolves the underlying problem. Do not add architecture, abstractions,
fallback paths, or scope without demonstrated need.

### 7. Revise the plan

Produce a complete replacement plan, not a patch or commentary on the old one. The revised
plan must:

- Preserve all verified requirements and constraints.
- Incorporate accepted and partially accepted findings, including accepted NEW findings.
- Exclude rejected recommendations.
- Make dependencies, interfaces, migrations, tests, observability, rollback, security
  considerations, and acceptance criteria explicit where relevant.
- Resolve contradictions created by the revisions, including stale sections that no longer
  match the revised architecture.
- Be detailed enough for another agent to implement without consulting the original plan or
  the review.
- Clearly mark unresolved deferred decisions and state how each will be closed: the decision
  needed, its owner, the experiment or measurement that closes it, and what the plan does
  meanwhile.

## Output format

Output exactly these sections:

```markdown
## Intent and constraints
A concise restatement of the objective and non-negotiable constraints, noting any that were
inferred rather than stated.

## Finding dispositions
ID | Disposition | Verified severity | Evidence | Required action

## Missed findings
Important NEW issues not identified by Agent B, evaluated to the same standard, or "None."

## Disagreements
Rejected and partially accepted findings, with concise evidence-based reasons. For partial
accepts, state exactly which part stands and which part fails.

## Revised plan
The complete, implementation-ready replacement plan.

## Verification matrix
Requirement or finding | Revised-plan step that addresses it | How it is verified
```

Rules for these sections:

- The dispositions table contains every Agent B finding exactly once, in the review's order.
  Keep Evidence cells terse and put extended reasoning in Disagreements; use clickable local
  file links with line numbers when the environment supports them.
- The verification matrix requires a row for every non-negotiable requirement and every
  accepted or partially accepted finding (including NEW), mapping each to the revised-plan
  step that satisfies it and the concrete check — the named test, gate, measurement, or
  acceptance criterion — that proves it. A row without a real check is a gap in the revised
  plan: fix the plan, not the matrix. Generic checks such as "add more tests" do not qualify.

## Quality bar

Before delivering, verify that:

- every Agent B finding appears exactly once in the dispositions table, with DEFERs naming
  their closure mechanism;
- every disposition rests on cited evidence, not the reviewer's confidence or the author's
  intent;
- severities were re-derived from the definitions, not copied from the review;
- every accepted corrective action appears in the revised plan, and no rejected
  recommendation leaked in;
- the revised plan stands alone, resolves its internal contradictions, and marks each
  deferred decision with its closure path;
- the verification matrix covers every requirement and accepted finding with a concrete,
  named check;
- the accept/reject balance reflects the evidence, not a wish to appear either rigorous or
  agreeable.
