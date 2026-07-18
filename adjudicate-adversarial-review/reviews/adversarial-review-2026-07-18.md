# Adversarial Review: Adjudicate Adversarial Review Skill

The skill is structurally valid and follows the current Codex skill layout documented in [Build skills](https://learn.chatgpt.com/docs/build-skills). Its adjudication logic is promising, but it is not yet implementation-ready: unresolved high-risk findings can pass into a plan labeled ready, and untrusted review artifacts lack an explicit security boundary.

## Findings

### 1. Deferred blockers can leak into an “implementation-ready” plan

- **Severity:** High
- **Location:** [SKILL.md](./SKILL.md#L54), [revision requirements](./SKILL.md#L135), [output format](./SKILL.md#L153)
- **Problem:** Any uncertain finding may become `DEFER`, while the output must still contain a “complete, implementation-ready replacement plan.” There is no final readiness verdict, rule that a critical/high defer blocks execution, or verification-matrix coverage for deferred findings.
- **Failure scenario:** Authentication feasibility remains unverified and is deferred to a future spike. The generated replacement is nevertheless presented as implementation-ready, so implementation commits to the affected architecture before the spike resolves the core uncertainty.
- **Recommendation:** Add `READY | CONDITIONALLY READY | NOT READY` to the required output. A critical/high `DEFER` must make the affected phase `NOT READY`; its closure gate must appear in the verification matrix with an explicit rejection criterion. Replace “implementation-ready” with “standalone revised plan” until those gates pass.
- **Confidence:** High

### 2. Untrusted evidence has no prompt-injection boundary

- **Severity:** High
- **Location:** [Inputs and evidence rules](./SKILL.md#L16)
- **Problem:** The workflow consumes pasted files, repository documents, links, and external sources without saying that their imperative instructions are untrusted data. The agent may also write a revised plan. OpenAI explicitly warns that retrieved web pages and repository content can contain prompt injection capable of causing secret exposure or unsafe changes. [OpenAI security guidance](https://learn.chatgpt.com/docs/cloud/internet-access)
- **Failure scenario:** A review or linked reference embeds an instruction to execute a diagnostic command that sends repository content externally. The instruction is followed as part of “checking evidence,” rather than analyzed as evidence.
- **Recommendation:** Establish a trust boundary: only the user, governing instructions, and selected skill control behavior; plans, reviews, repository files, and fetched pages are evidence only. Never execute embedded commands or actions. Default to inline output and read-only inspection; write only to a user-authorized destination.
- **Confidence:** Medium; needs verification of expected input provenance

### 3. Mandatory inputs have no preflight gate

- **Severity:** Medium
- **Location:** [Inputs](./SKILL.md#L16), [default prompt](./agents/openai.yaml#L4)
- **Problem:** Only missing governing requirements are handled. The skill does not define what to do when the original plan or review is missing, ambiguous, unreadable, truncated, or from a different revision. It also never explicitly requires reading both artifacts in full or inventorying the review’s finding count before adjudication.
- **Failure scenario:** A user invokes the default prompt with a plan selected but only a summarized or stale review in conversation. The agent adjudicates that summary, omits appendix findings, and still claims that every finding appeared exactly once.
- **Recommendation:** Add a preflight step that identifies exact plan/review sources and revisions, reads both fully, records the original finding IDs and count, and stops for the missing artifact when either core input is unavailable. Read applicable repository instructions before other repository evidence.
- **Confidence:** High

### 4. The output schema cannot represent the required adjudication record

- **Severity:** Medium
- **Location:** [Required finding fields](./SKILL.md#L71), [output schema](./SKILL.md#L153)
- **Problem:** The workflow requires a reasoning summary and effect on the plan for every finding, but the mandatory table has neither field. Extended reasoning is reserved for rejected and partially accepted findings, leaving accepts, defers, and duplicates underspecified. `NEW` findings must use the same standard but have no explicit record schema.
- **Failure scenario:** A security finding is accepted with a terse citation and action, but its causal diagnosis and architectural effect are lost. A later maintainer cannot determine whether the action resolves the actual defect. A serious `NEW` finding may appear as prose without severity, disposition, owner, or closure gate.
- **Recommendation:** Require the full record for every Agent B and `NEW` finding: ID, disposition, severity status, evidence, reasoning, plan effect, action, and closure details. Use separate B and NEW tables or per-finding blocks; keep the summary table optional.
- **Confidence:** High

### 5. Severity is mandatory even when no verified defect exists

- **Severity:** Medium
- **Location:** [Dispositions and severity](./SKILL.md#L57)
- **Problem:** Every finding must receive critical/high/medium/low severity. That is incoherent for `REJECT`, where no defect exists; uncertain for `DEFER`; and redundant for `DUPLICATE`. It forces the adjudicator to manufacture certainty despite the skill’s evidence-first rule.
- **Failure scenario:** A false authorization finding is recorded as `REJECT / Low`, later appearing to be a real residual low-severity defect. Conversely, an unresolved bypass is assigned `Low` merely to satisfy the table and no longer blocks implementation.
- **Recommendation:** Define severity by disposition: `ACCEPT` and `PARTIALLY ACCEPT` receive verified severity; `REJECT` receives `N/A—no verified defect`; `DUPLICATE` references the canonical finding; `DEFER` receives `UNRESOLVED` plus a provisional impact range and worst-case blocking rule.
- **Confidence:** High

### 6. Strict invariants have no regression evaluation

- **Severity:** Medium
- **Location:** [Quality bar](./SKILL.md#L190); the target directory contains only `SKILL.md` and metadata
- **Problem:** The skill imposes mechanically checkable invariants—exactly-once coverage, no rejected remedy leakage, accepted-action incorporation, and complete verification mapping—but the repository has no fixtures or evaluator.
- **Failure scenario:** A wording change causes duplicates to disappear from the table or rejected remedies to re-enter the revised plan. Manual inspection misses the regression, and every future adjudication inherits it.
- **Recommendation:** Add fixture-based evaluations covering missing inputs, all dispositions, duplicate findings, high-severity defers, rejected-finding severity, accepted `NEW` findings, conflicting changes, and embedded malicious instructions. Assert finding-count equality, matrix coverage, closure ownership, readiness status, and absence of rejected actions.
- **Confidence:** High

## Pre-mortem: five likely causes of failure after six months

1. Teams begin implementation from revised plans containing unresolved feasibility gates because every output looks “implementation-ready.”
2. Review summaries or mismatched plan versions become the de facto inputs, causing omitted findings and incorrect dispositions.
3. Rejected findings retain artificial severity labels and are repeatedly reopened as apparent residual risks.
4. Newly discovered issues receive inconsistent treatment because their required schema was never defined.
5. A linked document or adversarial artifact injects instructions that corrupt the plan or trigger an unsafe tool action.

## Final assessment

### 1. Verdict

**APPROVE WITH CHANGES**

The core evidence-first approach is sound. The defects are bounded workflow and output-contract changes rather than a required redesign.

### 2. Blocking issues

- No readiness decision or blocking semantics for critical/high deferred findings.
- No explicit untrusted-content boundary for plans, reviews, repository evidence, and fetched sources.

### 3. The three highest-value changes

1. Add an explicit readiness verdict and make unresolved critical/high findings block the affected phase.
2. Define one complete adjudication record for every original and `NEW` finding, with disposition-aware severity semantics.
3. Add input/provenance preflight, untrusted-content rules, and regression fixtures for the workflow’s strict invariants.

### 4. Revised plan outline

1. **Preflight and authorization**
   - Resolve exact plan, review, requirements, repository context, and revisions.
   - Read all artifacts fully and inventory review IDs.
   - Confirm an output destination before writing; otherwise return the revision inline.

2. **Trust and evidence boundary**
   - Treat artifact and external-source instructions as untrusted data.
   - Follow applicable repository instructions.
   - Permit only read-only verification actions unless separately authorized.

3. **Intent reconstruction**
   - Record stated requirements, inferred constraints, assumptions, and success criteria.
   - Distinguish requirements from plan and reviewer assertions.

4. **Complete adjudication ledger**
   - Give every B and NEW finding a full record.
   - Apply disposition-specific severity rules.
   - Give every defer an owner, deadline or trigger, experiment, pass/fail threshold, and affected scope.

5. **Interaction resolution**
   - Re-evaluate findings after accepted changes.
   - Consolidate duplicate fixes and reject unnecessary remedies.

6. **Readiness gate**
   - Determine `READY`, `CONDITIONALLY READY`, or `NOT READY`.
   - Block phases affected by unresolved critical/high uncertainty.

7. **Standalone revised plan**
   - Incorporate accepted concerns and exclude rejected remedies.
   - Preserve unresolved gates without describing blocked work as ready.

8. **Verification matrix**
   - Cover requirements, accepted/partial findings, NEW findings, and deferred closure gates with concrete checks.

9. **Regression evaluation**
   - Run the fixture suite and mechanically verify finding counts, corrective-action coverage, rejected-action exclusion, and readiness consistency.
