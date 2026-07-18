# Adjudication: adversarial review of `plan-application`

- **Plan:** [plan-application/SKILL.md](../SKILL.md), pre-revision content at commit `3d27037`
  (unchanged since `d31f373`).
- **Review:** [adversarial-review-2026-07-18.md](adversarial-review-2026-07-18.md) (Agent B).
- **Preflight:** 6 findings inventoried, assigned B1–B6 in the review's order. Every location the
  review cites resolves against the plan revision at `3d27037`; no version skew. References of
  the form `@3d27037:N` are line numbers in the pre-revision plan
  (`git show 3d27037:plan-application/SKILL.md`); bare `SKILL.md:N` references are the revised
  file. Sibling-skill citations are pinned to `@3d27037` because both siblings were revised
  concurrently in other sessions.

## Intent and constraints

The artifact under adjudication is itself a skill prompt: `plan-application/SKILL.md` instructs
an agent to produce rigorous, implementation-ready engineering plans. Non-negotiable
constraints:

1. **(Stated, [README.md:12](../../README.md))** Produced plans must be implementation-ready,
   with measurable requirements, verification gates, and rollback paths.
2. **(Inferred from [README.md:16–17](../../README.md))** The skill chains with
   `adversarial-review` and `adjudicate-adversarial-review`; its output must be consumable by
   them.
3. **(Stated, README install instructions)** The file must remain a valid SKILL.md —
   `name`/`description` frontmatter, usable as an LLM prompt in Codex and Claude Code.
4. **(Stated, `@3d27037:140-142` and `:154-155`)** Depth scales to the project; nothing may
   exist only to appear thorough. Accepted remedies must not turn the skill into bureaucracy.
5. **(Stated, `@3d27037:8-10`)** Every claim in a produced plan is supported, explicitly
   assumed, or explicitly gated.

No separate requirements specification exists; constraints 2–5 were reconstructed from the
repository and are labeled accordingly.

## Finding dispositions

| ID | Disposition | Severity | Evidence | Required action |
|---|---|---|---|---|
| B1 | PARTIALLY ACCEPT | High | Old quality bar checked only testability (`@3d27037:148`); nothing forced requirement→phase→verification mapping, so a documented, testable requirement could ship in no phase — major requirement loss. The downstream adjudicate skill demands exactly this matrix ([adjudicate-adversarial-review/SKILL.md:260–265](../../adjudicate-adversarial-review/SKILL.md#L260)). Remedy partly excessive: universal per-requirement owner and design-component columns exceed what fixes the defect at small scale. | Stable IDs ([SKILL.md:50–52](../SKILL.md#L50)); every ID assigned to a phase ([SKILL.md:101–103](../SKILL.md#L101)); traceability matrix ([SKILL.md:119–121](../SKILL.md#L119)); quality-bar gate ([SKILL.md:193–194](../SKILL.md#L193)). Unmapped IDs become gated open questions. Owner column dropped; owners remain on open questions (output template §8). |
| B2 | ACCEPT | High | Old trust-boundary bullet covered only normal-path authn/authz/data lifecycle (`@3d27037:61-62`), while the chain's own reviewer attacks recovery bypasses, trusted-actor abuse, key management, and incident response (`adversarial-review/SKILL.md@3d27037:58-59`) — plans from this skill were systematically blind to surfaces its sibling attacks. The remedy is already conditional and carries a "not material" escape. | Conditional threat-model bullet covering actors, assets, entry points, abuse cases (recovery, admin/support paths, trusted insiders), secrets/keys, audit events, responder, and per-threat control + named verification or accepted residual risk ([SKILL.md:77–85](../SKILL.md#L77)); output template §4 ([SKILL.md:161](../SKILL.md#L161)); quality-bar gate ([SKILL.md:198–199](../SKILL.md#L198)). Content is mandatory; table format is author's choice. |
| B3 | PARTIALLY ACCEPT | Medium | Confirmed gaps: no instructions-file discovery (sibling mandates it, `adversarial-review/SKILL.md@3d27037:16`), no conflict precedence, no citation preservation (`@3d27037:14-25`, output format `@3d27037:119-121`). But repo inspection and primary-source verification were already mandatory (`@3d27037:17-22`), so the residual failure is avoidable rework, not likely material failure — severity re-derived High→Medium. Mandatory standalone evidence ledger for every plan rejected as scope beyond the fix. | Instructions-first step ([SKILL.md:16–18](../SKILL.md#L16)); source + verification date beside decisions ([SKILL.md:24–26](../SKILL.md#L24)); precedence rule with recorded conflict outcomes ([SKILL.md:27–29](../SKILL.md#L27)); rationale citations ([SKILL.md:61–62](../SKILL.md#L61)); quality-bar gate ([SKILL.md:196–197](../SKILL.md#L196)). |
| B4 | PARTIALLY ACCEPT | Medium | `@3d27037:152` required "rollback and abort paths … for every irreversible or user-facing step" — definitionally impossible for irreversible steps, inviting fictional rollback prose. Workflow `@3d27037:80-82` already probed reversibility, so the defect lived in the checklist: Medium, not blocking. Three-case recovery semantics, point of no return, and demonstrated restore accepted; universal per-step recovery owner and RTO rejected (ownership is covered at plan level in operations; RTO belongs where an availability NFR exists, which section 2 already forces to be measurable). | Migration step rewritten: classify every step; reversible → rollback path, irreversible → point of no return + abort criteria before it + restoration/compensation/forward recovery after it; destructive data changes require backup with demonstrated restore ([SKILL.md:106–111](../SKILL.md#L106)). Quality-bar item rewritten to match ([SKILL.md:202–204](../SKILL.md#L202)). |
| B5 | ACCEPT | Medium | Outcome was stated without measurement (`@3d27037:31`); launch criteria were technical-only (`@3d27037:92`); the frontmatter advertises PRDs and roadmaps ([SKILL.md:3](../SKILL.md#L3)), where success metrics are a standard component. | One to three success metrics with baseline, target, and measurement window, distinct from launch criteria ([SKILL.md:39–41](../SKILL.md#L39)); post-launch review naming when metrics are read and who decides continue/iterate/stop ([SKILL.md:125–126](../SKILL.md#L125)); quality-bar gate ([SKILL.md:205–206](../SKILL.md#L205)). Instrumentation ownership folds into observability/operations rather than a separate field. |
| B6 | PARTIALLY ACCEPT | Medium | Confirmed: the directory holds only `SKILL.md` and `agents/openai.yaml` — no fixtures or evaluations — while `@3d27037:157` guaranteed adversarial-review survival with no test behind the claim. The in-scope defect is the untestable guarantee; the fixture corpus is repo infrastructure that cannot be delivered inside a SKILL.md revision. | Applied: guarantee recast as an externally checked bar — the review artifact, not the checklist, is the evidence ([SKILL.md:211–212](../SKILL.md#L211)). Deferred component — owner: Jacob; closure: decide whether to build the six-scenario fixture corpus (greenfield, brownfield, irreversible migration, security-sensitive multi-tenant, build-vs-buy, underspecified request) scored against the quality bar; meanwhile every SKILL.md revision re-enters the adversarial-review → adjudicate chain (as this revision did). Worst-case if never built: medium. |
| NEW1 | ACCEPT | Low | The skill delivered plans only as chat output: no save location, naming, or persistence instruction existed anywhere in `@3d27037`. The README promises the skills chain ([README.md:16–17](../../README.md)), and `adversarial-review` takes a file/directory target and has a full artifact protocol (`adversarial-review/SKILL.md@3d27037:138-155`); a chat-only plan breaks the chain without manual copying. Contained impact — a user can ask for a file — hence Low. | Artifact instructions added: reuse `plans/`, `docs/plans/`, or `design/` when present, else create `plans/`; collision-safe `<application-name>-plan.md` naming; stated inline fallback when no repository exists ([SKILL.md:179–183](../SKILL.md#L179)). |

## Missed findings

**NEW1 — The plan is never saved as an artifact, breaking the advertised chain** (ACCEPT, Low;
adjudicated in the table above). Agent B's own workflow consumed the plan as a file path and its
sibling skill mandates artifact persistence, yet the review never noticed that `plan-application`
produces no file at all. Fixed at [SKILL.md:179–183](../SKILL.md#L179).

No other NEW findings. Lenses checked beyond the review's coverage: feasibility of the
verification mandate in offline environments (already handled by the assumption/open-question
gate, now explicit at [SKILL.md:30–32](../SKILL.md#L30)), frontmatter/format compliance
(unchanged and parsing), concurrency/complexity (not material for a prompt document).

## Disagreements

- **B1 — stands:** no end-to-end coverage proof existed; the traceability matrix and ID mandate
  are accepted. **Fails:** requiring an owner and a design-component mapping for every
  requirement at every scale — bureaucracy the skill's own bar forbids (`@3d27037:154-155`);
  owners already attach to open questions, and design linkage is forced only where a
  load-bearing decision exists.
- **B3 — stands:** instructions-file discovery, source precedence, and preserved citations.
  **Fails:** the mandatory standalone evidence ledger for all plans, and the High severity —
  repo inspection and primary-source verification were already mandatory (`@3d27037:17-22`),
  so the residual gap causes avoidable rework (Medium). Citations-beside-decisions achieves the
  ledger's reconstruction goal without a new artifact.
- **B4 — stands:** the checklist contradiction and the three-case recovery semantics, point of
  no return, and demonstrated restore. **Fails:** universal per-step recovery owner and
  recovery-time objective — ownership is already assigned in operations
  ([SKILL.md:127](../SKILL.md#L127)), and an RTO is only meaningful where an availability NFR
  exists, which section 2 already forces into measurable form.
- **B6 — stands:** the behavioral claim was untested and no regression fixtures exist.
  **Fails as an in-scope remedy:** the fixture suite cannot be delivered inside the SKILL.md
  revision; the overclaim is fixed in the document and the suite is deferred with a named owner
  and closure path (see dispositions table).

## Readiness

**READY.** Every accepted and partially accepted corrective action is incorporated in the
revised [SKILL.md](../SKILL.md). There are no DEFER dispositions; the single deferred decision
(B6's fixture corpus, owner Jacob) has a worst-case impact of medium, which does not gate
readiness. No steps are blocked.

## Revised plan

Applied to [plan-application/SKILL.md](../SKILL.md); the file is the canonical copy. Full
content:

````markdown
---
name: plan-application
description: Produce a rigorous, implementation-ready plan for building an application, feature, service, or system. Use when asked to plan, scope, design, or architect an application; draft a technical design, PRD, roadmap, or build plan; break work into phases and milestones; evaluate build-versus-buy; or turn an idea or requirements document into an executable engineering plan with verification gates, rollout, and rollback.
---

# Plan Application

Produce a plan a skeptical senior engineer would approve. A plan is a set of decisions with
evidence, not a list of aspirations. Every claim in the plan should be supported, explicitly
assumed, or explicitly gated on verification — never silently guessed.

## Planning workflow

### 1. Establish context and evidence

1. If a repository exists, read its applicable instructions first — `AGENTS.md`, `CLAUDE.md`,
   `CONTRIBUTING`, and similar governing documents — before other artifacts; they constrain
   every decision that follows.
2. Read the source material: the request, requirements documents, prior designs, and any linked
   references.
3. Inspect the surfaces the plan will touch: current architecture, tests, configuration,
   deployment, schemas, and operational docs. Do not plan against an imagined codebase when the
   real one can be read.
4. For current platform, API, pricing, compatibility, or policy claims that a decision depends
   on, verify against current authoritative primary sources rather than memory, and record the
   source and verification date beside the decision the claim supports.
5. When sources conflict, resolve by precedence — explicit user direction, then repository
   instructions, then verified current primary sources, then prior designs, then memory — and
   record which source won and why beside the affected decision.
6. Identify what is genuinely unknown or unverifiable from here. Ask the user only about
   decisions that materially change the plan and cannot be resolved from evidence or sensible
   defaults; record everything else as an assumption or an open question with a resolution gate.

### 2. Define the outcome and requirements

Establish, in writing:

- the intended outcome, target users, and the smallest version that delivers real value;
- one to three success metrics that would show the outcome was achieved — each with a baseline
  (or "none measured"), a target, and a measurement window. These are post-launch measures of
  value, distinct from the technical launch criteria in section 6;
- functional requirements, stated as observable behavior;
- nonfunctional requirements with measurable bounds — "handles 500 concurrent users at p95 under
  300 ms," not "fast and scalable." "Immediate," "reliable," "secure," and "scalable" are not
  requirements until they have numbers, budgets, or testable criteria;
- explicit non-goals, so scope creep has something to be measured against;
- constraints: budget, deadline, team size and skills, platform mandates, compliance obligations,
  and existing systems that must keep working.

Give every functional and nonfunctional requirement a stable ID (FR-1, NFR-1, ...). The IDs are
load-bearing: sections 5 and 6 map each one to a delivery phase and a verification, and an
unmapped ID is a defect.

### 3. Make the load-bearing design decisions

For each decision that is expensive to reverse — language and framework, data store, hosting,
authentication approach, multi-tenancy model, third-party dependencies:

1. Name 2–3 realistic alternatives, including the boring default and, where relevant, buy instead
   of build.
2. Choose one and record the rationale in a sentence or two, citing the evidence it rests on when
   that evidence is external or time-sensitive. Prefer the simplest option that meets the stated
   requirements; reject speculative generality and components with no requirement behind them.
3. For build-versus-buy, confirm the product satisfies the exact invariant needed — not an
   advertised workflow that resembles it — and note the exit strategy if the vendor fails.
4. When a decision depends on an unverified claim, do not commit. Insert a gate: a spike, trial,
   or measurement that must pass before money, migration, or architecture is committed.

### 4. Describe the architecture

Cover, at whatever depth the project warrants:

- components and their responsibilities, with the boundaries between them;
- data model: core entities, ownership, lifecycle, and anything that grows without bound;
- trust boundaries: where authentication and authorization are enforced, what is validated at each
  boundary, and how sensitive data is stored, retained, and deleted;
- threat model, when the system involves authentication, sensitive or regulated data,
  multi-tenancy, privileged or administrative roles, payments, or untrusted input: the actors and
  the assets they can reach, entry points, and abuse cases — including account recovery,
  administrative and support paths, and abuse by trusted insiders — plus secrets and key
  management, the audit events that must be recorded, and who responds when a control fails.
  Every identified threat needs a control and a named verification, or an explicitly accepted
  residual risk. A low-risk system may instead record "threat model: not material" with a
  sentence of justification;
- external dependencies and failure domains: what happens when each dependency is slow, down, or
  returns garbage, and whether the system fails open or closed;
- concurrency and time: races, retries, idempotency, offline or stale clients, timezones;
- the paths most likely to hurt: hot paths, expensive queries, rate limits, and realistic cost.

Skip a category only by stating it is not a material concern for this system, not by omission.

### 5. Sequence the work into phases

Structure delivery so risk is retired early and every phase ends in something verifiable:

1. Order phases by risk, not convenience: the assumption most likely to sink the project gets
   validated first, ideally by a thin end-to-end slice through the whole stack.
2. Give each phase a concrete deliverable and an acceptance gate: what must demonstrably work —
   named tests passing, a measurable threshold met, a demo path exercisable — before the next
   phase begins. An effort estimate is not an acceptance criterion.
3. Assign every requirement ID to the phase that delivers it. A requirement no phase delivers is
   a defect: re-plan the phases, or convert it to a gated open question that blocks the phase
   where it belongs.
4. Make dependencies between phases explicit, and flag work that can proceed in parallel.
5. For changes to a live system, plan the migration explicitly: compatibility between old and
   new, data transformation, staged rollout, and safe abort criteria. Classify every step as
   reversible or irreversible. Reversible steps get a rollback path that has actually been
   thought through. Irreversible steps cannot have one: mark the point of no return, define the
   abort criteria that apply before it, and define restoration, compensation, or forward
   recovery after it. A destructive data change requires a backup with a demonstrated restore
   before cutover.
6. Keep estimates honest: give ranges, state what they assume, and mark low-confidence estimates
   as such rather than laundering guesses into commitments.

### 6. Plan validation and operations

- Testing: name the levels that matter for this system (unit, integration, end-to-end,
  load, upgrade/rollback) and the specific scenarios each must cover — not "add tests."
- Traceability: a matrix mapping every requirement ID to the phase that delivers it and the
  named test, gate, or measurement that verifies it. An unmapped row becomes a gated open
  question, not a blank cell.
- Observability: the logs, metrics, and alerts needed to tell that the system works in production,
  and who gets paged when it does not.
- Launch criteria: the measurable conditions under which the application ships.
- Post-launch review: when the success metrics from section 2 will be read against their targets,
  and who decides whether to continue, iterate, or stop.
- Operations: backup and restore, dependency upgrades, supportability, and ownership after launch.

### 7. Run a pre-mortem before delivering

Assume the project failed six months in. Write down the three to five most plausible causal
stories — technical, organizational, or economic. For each, either change the plan to address it
or add an explicit early-warning signal and mitigation. Then reread the plan for internal
contradictions: later sections that quietly break earlier decisions, or stale text left normative
after a revision.

## Output format

Deliver the plan as a single markdown document:

```markdown
# Plan: <application name>

## 1. Summary
Two to four sentences: what is being built, for whom, and the chosen approach.

## 2. Outcome and requirements
### Success metrics (baseline, target, measurement window)
### Functional (FR-n)
### Nonfunctional (NFR-n, with measurable bounds)
### Non-goals
### Constraints and assumptions

## 3. Design decisions
One entry per load-bearing decision: choice, alternatives considered, rationale with its
supporting evidence. Mark unresolved decisions **gated** with the verification step that
resolves them.

## 4. Architecture
Components, data model, trust boundaries, threat model (or "not material because ..."),
dependencies and failure handling.

## 5. Delivery phases
One section per phase: goal, scope, requirement IDs delivered, deliverable, acceptance gate,
dependencies, estimate (with confidence). Include migration, rollout, and the
reversible/irreversible classification with recovery paths where applicable.

## 6. Validation and operations
Tests, traceability matrix, observability, launch criteria, post-launch review, operational
ownership.

## 7. Risks and pre-mortem
Top risks with mitigations or early-warning signals.

## 8. Open questions
Each with an owner, a resolution gate, and what is blocked until it is resolved.
```

Save the plan as a Markdown file in the target repository so the next skill in the chain can
review and revise it in place: reuse an established location such as `plans/`, `docs/plans/`, or
`design/` when one exists, otherwise create `plans/` under the target root. Name it
`<application-name>-plan.md`, appending `-2`, `-3` rather than overwriting a prior plan. If there
is no repository, deliver the plan inline and say so.

Scale the depth to the project: a weekend prototype does not need a compliance section, a threat
model, or an instrumented success metric — but it still needs requirements, a first slice, and a
definition of done, and it must say which sections are intentionally thin and why.

## Quality bar

Before delivering, verify that:

- every requirement has a stable ID, is testable, and — via the traceability matrix — maps to a
  delivery phase and a named verification, or is a gated open question;
- every nonfunctional requirement has a measurable bound;
- every load-bearing decision names its alternatives and rationale, cites its external or
  time-sensitive evidence, or is explicitly gated;
- the threat-model triggers in section 4 were checked, and the plan contains either a threat
  model with verified controls or an explicit "not material" justification;
- no phase depends on an unverified assumption without a gate in front of it;
- the first phase retires the biggest risk, not the easiest task;
- every migration or user-facing rollout step is classified reversible or irreversible;
  reversible steps have rollback paths, irreversible steps have abort criteria before the point
  of no return and a recovery path after it;
- success metrics are distinct from launch criteria and carry baselines, targets, and
  measurement windows;
- open questions are tracked with owners and gates, not scattered as hedges through the text;
- the plan contains nothing that exists only to appear thorough — every section changes what the
  builder would do next.

This bar is what an adversarial review will test. The review artifact, not this checklist, is
the evidence that a given plan meets it.
````

**Deferred decision (from B6):** whether to build the six-scenario fixture corpus for regression
evaluation of this skill. Owner: Jacob. Closure: a recorded decision (repo issue or README note);
if built, outputs are scored against the quality bar with the release gate "no omitted critical
requirement, no ungated load-bearing assumption." Meanwhile, every revision of this SKILL.md
re-enters the adversarial-review → adjudicate chain, as this revision did. This is repo
infrastructure and intentionally does not appear inside the SKILL.md itself.

## Verification matrix

| Requirement, finding, or gate | Revised-plan step that addresses it | How it is verified |
|---|---|---|
| R1 (stated): plans are implementation-ready with measurable requirements, gates, and rollback ([README.md:12](../../README.md)) | Workflow §§1–7 plus the quality bar ([SKILL.md:189–212](../SKILL.md#L189)) | A fresh adversarial-review pass over this revised SKILL.md reports no critical or high finding on requirements, gates, or recovery surfaces — the chain is the named check |
| R2 (inferred): output must chain into `adversarial-review` and `adjudicate-adversarial-review` ([README.md:16–17](../../README.md)) | Plan saved as a repo file ([SKILL.md:179–183](../SKILL.md#L179)); traceability matrix in §6 ([SKILL.md:119–121](../SKILL.md#L119)) | A produced plan exists at a file path a reviewer can target, and its matrix provides the row-per-requirement data the adjudicate skill's verification matrix demands |
| R3 (stated): valid SKILL.md packaging | Frontmatter preserved verbatim ([SKILL.md:1–4](../SKILL.md#L1)) | Skill loader parses the frontmatter — the skill is listed with this description in a live session |
| R4 (stated): depth scales; no bureaucracy | Scaling paragraph names the new heavy sections as skippable-with-statement ([SKILL.md:185–187](../SKILL.md#L185)); anti-thoroughness bar retained ([SKILL.md:208–209](../SKILL.md#L208)) | The prototype carve-out explicitly exempts threat model and instrumented metrics, so the accepted findings cannot force them on small projects |
| B1: requirement traceability | IDs ([SKILL.md:50–52](../SKILL.md#L50)); phase assignment ([SKILL.md:101–103](../SKILL.md#L101)); matrix ([SKILL.md:119–121](../SKILL.md#L119)) | Quality-bar item at [SKILL.md:193–194](../SKILL.md#L193) fails any plan with an unmapped requirement ID |
| B2: threat model beyond trust boundaries | Conditional threat-model bullet ([SKILL.md:77–85](../SKILL.md#L77)); template §4 ([SKILL.md:161](../SKILL.md#L161)) | Quality-bar item at [SKILL.md:198–199](../SKILL.md#L198) requires a threat model with verified controls or a justified "not material" |
| B3: evidence governance | Instructions-first ([SKILL.md:16–18](../SKILL.md#L16)); precedence and recorded conflicts ([SKILL.md:24–29](../SKILL.md#L24)); decision citations ([SKILL.md:61–62](../SKILL.md#L61)) | Quality-bar item at [SKILL.md:196–197](../SKILL.md#L196) requires each load-bearing decision to cite its evidence or be gated |
| B4: recovery semantics | Reversible/irreversible classification, point of no return, restore proof ([SKILL.md:106–111](../SKILL.md#L106)) | Quality-bar item at [SKILL.md:202–204](../SKILL.md#L202); structural check: `grep "rollback and abort paths" SKILL.md` returns nothing — the contradictory demand is gone |
| B5: outcome metrics | Success metrics ([SKILL.md:39–41](../SKILL.md#L39)); post-launch review ([SKILL.md:125–126](../SKILL.md#L125)) | Quality-bar item at [SKILL.md:205–206](../SKILL.md#L205) requires baselines, targets, and windows distinct from launch criteria |
| B6 (accepted part): untestable guarantee | Bar recast as externally checked ([SKILL.md:211–212](../SKILL.md#L211)) | Structural check: `grep "should survive" SKILL.md` returns nothing; the evidence of meeting the bar is the review artifact, not self-assertion |
| B6 (deferred gate): fixture corpus | Deferred-decision note in this adjudication (above) | Closure: Jacob's recorded build/no-build decision; interim check: each SKILL.md revision passes back through the adversarial-review → adjudicate chain |
| NEW1: plan persistence | Artifact-saving instructions ([SKILL.md:179–183](../SKILL.md#L179)) | The instruction names the location convention, collision-safe filename, and the stated inline fallback when no repository exists |
