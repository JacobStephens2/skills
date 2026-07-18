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
