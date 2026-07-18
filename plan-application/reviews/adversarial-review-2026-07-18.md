# Adversarial Review: `plan-application`

The core workflow is strong and the metadata parses correctly, but the skill is not yet
implementation-ready by its own standard. Three bounded gaps—requirements traceability, threat
modeling, and evidence governance—can still produce polished plans that omit critical constraints
or controls.

### 1. Requirements can disappear between planning sections

- **Severity:** High
- **Location:** [plan-application/SKILL.md:148](../SKILL.md#L148),
  [adjudicate-adversarial-review/SKILL.md:184](../../adjudicate-adversarial-review/SKILL.md#L184)
- **Problem:** The quality bar checks whether each written requirement is testable, but never proves
  that every requirement maps to an architectural decision, delivery phase, and acceptance test.
  The downstream adjudication skill requires exactly this verification matrix, exposing a gap in
  the planning skill.
- **Failure scenario:** A deletion requirement is documented and testable but omitted from every
  phase. All phase gates pass, the feature ships without deletion, and remediation requires a new
  data migration.
- **Recommendation:** Assign stable requirement IDs and require a matrix mapping each requirement to
  its design component or decision, delivery phase, owner, and named verification. No requirement
  may remain unmapped; unresolved rows must become gated open questions that block the affected
  phase.
- **Confidence:** High

### 2. Trust boundaries are not a threat model

- **Severity:** High
- **Location:** [plan-application/SKILL.md:61](../SKILL.md#L61),
  [adversarial-review/SKILL.md:36](../../adversarial-review/SKILL.md#L36),
  [adversarial-review/SKILL.md:58](../../adversarial-review/SKILL.md#L58)
- **Problem:** The architecture section covers normal authentication, authorization, validation,
  and data lifecycle, but does not require assets, threat actors, abuse cases, recovery bypasses,
  privileged operations, secrets and key management, auditability, or incident response.
- **Failure scenario:** Normal API authorization is correct, but an account-recovery or
  administrative workflow bypasses MFA and permits account takeover. The generated plan passes its
  stated quality bar because the ordinary trust boundaries were documented.
- **Recommendation:** For systems involving authentication, sensitive data, multi-tenancy,
  privileged actors, or untrusted input, require a threat-model table covering actor, asset, entry
  point, abuse case, control, verification test, and residual risk. Explicitly include recovery,
  administrative access, secrets/key rotation, audit events, and incident response. Permit a
  documented “not material” disposition for low-risk prototypes.
- **Confidence:** High

### 3. Evidence is gathered but not governed or preserved

- **Severity:** High
- **Location:** [plan-application/SKILL.md:16](../SKILL.md#L16),
  [plan-application/SKILL.md:21](../SKILL.md#L21),
  [adversarial-review/SKILL.md:16](../../adversarial-review/SKILL.md#L16)
- **Problem:** The workflow says to read sources and verify current claims, but does not require
  discovery of applicable repository instructions, establish precedence when sources conflict, or
  preserve citations and verification dates in the output.
- **Failure scenario:** A stale design recommends one datastore while an applicable repository
  instruction mandates another. The planner follows the stale design, and reviewers cannot
  reconstruct why because neither source authority nor supporting evidence appears in the plan.
- **Recommendation:** Add an evidence ledger containing source, authority, relevant claim or
  constraint, verification date where time-sensitive, and conflict disposition. Require applicable
  repository instructions to be read first. Cite external evidence beside each load-bearing decision
  it supports.
- **Confidence:** High

### 4. The rollback quality bar is impossible for irreversible steps

- **Severity:** Medium
- **Location:** [plan-application/SKILL.md:80](../SKILL.md#L80),
  [plan-application/SKILL.md:152](../SKILL.md#L152)
- **Problem:** The migration workflow correctly asks whether steps are reversible, but the quality
  bar then requires rollback and abort paths for every irreversible step. An irreversible action
  cannot, by definition, have a rollback path.
- **Failure scenario:** A destructive transformation is described as rollbackable to satisfy the
  checklist. The cutover corrupts data, but the purported rollback cannot reconstruct the original
  representation.
- **Recommendation:** Distinguish three cases: tested rollback for reversible changes; an abort path
  before the point of no return; and tested restoration, compensation, or forward recovery after an
  irreversible action. Require the point of no return, recovery owner, recovery-time objective, and
  proof of backup restoration.
- **Confidence:** High

### 5. Launch success is not tied to user or business outcomes

- **Severity:** Medium
- **Location:** [plan-application/SKILL.md:31](../SKILL.md#L31),
  [plan-application/SKILL.md:92](../SKILL.md#L92),
  [adversarial-review/SKILL.md:41](../../adversarial-review/SKILL.md#L41)
- **Problem:** The skill asks for an intended outcome and technical launch criteria, but not a
  measurable post-launch success metric. This is especially significant because the advertised
  scope includes PRDs and roadmaps.
- **Failure scenario:** A feature meets its latency, availability, and test gates but has negligible
  adoption or does not improve the intended workflow. Six months later, the team cannot determine
  whether to invest, revise, or retire it.
- **Recommendation:** Require one to three outcome metrics with baseline, target, measurement window,
  instrumentation owner, and an explicit continue/iterate/stop decision threshold. Keep these
  distinct from technical launch criteria.
- **Confidence:** High

### 6. The skill’s behavioral claims have no evaluation suite

- **Severity:** Medium
- **Location:** [plan-application/](../), [plan-application/SKILL.md:157](../SKILL.md#L157)
- **Problem:** The directory contains only the prompt and interface manifest. There are no fixtures
  or evaluations supporting the claim that compliant output will survive adversarial review.
  Parsing the manifest verifies packaging, not behavior.
- **Failure scenario:** A wording change causes generated plans to stop preserving evidence or
  mapping requirements to phases. The regression is published because there is no representative
  test corpus or acceptance rubric.
- **Recommendation:** Add fixtures for a greenfield prototype, brownfield feature, irreversible
  migration, security-sensitive multi-tenant service, vendor-heavy build-versus-buy decision, and
  underspecified request. Score outputs for requirement coverage, evidence provenance, gates,
  threat modeling, rollout/recovery, success metrics, and unsupported claims. Fail release on any
  omitted critical requirement or ungated load-bearing assumption.
- **Confidence:** High

## Pre-mortem: five likely causes of failure after six months

1. Teams discover late that individually well-written requirements were never assigned to
   implementation phases or tests.
2. A recovery or privileged-administration path enables a security bypass absent from the normal
   trust-boundary analysis.
3. Brownfield plans conflict with repository rules or current architecture because source authority
   was never established.
4. A destructive migration fails after its point of no return, revealing that “rollback” was prose
   rather than a demonstrated recovery mechanism.
5. Projects launch successfully by technical measures but cannot show user value, leaving teams
   unable to decide whether to continue investing.

## Final assessment

### 1. Verdict

**APPROVE WITH CHANGES**

The core approach is coherent and the fixes do not require redesigning the skill. It should not yet
be described as implementation-ready, however.

### 2. Blocking issues

Findings 1–3 block the implementation-ready claim:

- No end-to-end requirement coverage proof.
- No explicit threat-model gate for security-relevant systems.
- No authoritative evidence ledger, source precedence, or mandatory repository-instruction
  discovery.

### 3. The three highest-value changes

1. Introduce an evidence ledger, stable requirement IDs, and a
   requirement-to-design-to-phase-to-test verification matrix.
2. Add a conditional but explicit threat-model workflow covering recovery, privileged access,
   secrets, abuse cases, audit, and incident response.
3. Correct the rollback semantics and make the skill’s quality bar executable through
   representative regression evaluations.

### 4. Revised plan outline

1. **Establish governing evidence**
   - Read applicable repository instructions first.
   - Inventory sources, authority, version or verification date, conflicts, and unknowns.

2. **Define measurable outcomes**
   - State users, observable value, baseline, success targets, measurement window, non-goals, and
     constraints.

3. **Create the requirements catalog**
   - Give every functional and nonfunctional requirement a stable ID, priority, provenance,
     acceptance criterion, and owner.
   - Resolve contradictions or gate them before design commitment.

4. **Retire feasibility risks**
   - Identify platform, permission, compatibility, vendor, compliance, and operational-access
     assumptions.
   - Run spikes or trials before dependent architectural commitments.

5. **Record design decisions**
   - Capture choice, realistic alternatives, rationale, supporting evidence, exit strategy, and
     unresolved gates.

6. **Describe architecture and security**
   - Cover components, data lifecycle, failure domains, concurrency, capacity, and cost.
   - Add the risk-triggered threat model and explicit security verification.

7. **Build the verification matrix**
   - Map every requirement to its design location, delivery phase, owner, and named test or
     measurement.
   - Block progression on missing mappings.

8. **Sequence delivery and recovery**
   - Retire the largest risk first.
   - Define phase gates, dependencies, rollout thresholds, rollback for reversible changes, and
     restoration or forward recovery for irreversible changes.

9. **Define operations and success review**
   - Specify observability, paging, backup/restore proof, support ownership, incident response,
     launch criteria, and post-launch outcome review.

10. **Validate the skill**
    - Run the representative fixture suite and adversarial review rubric.
    - Reject releases containing omitted requirements, unsupported decisions, fictional rollback
      paths, or ungated security risks.
