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

1. Read the source material: the request, requirements documents, prior designs, and any linked
   references.
2. If a repository exists, inspect the surfaces the plan will touch: current architecture, tests,
   configuration, deployment, schemas, and operational docs. Do not plan against an imagined
   codebase when the real one can be read.
3. For current platform, API, pricing, compatibility, or policy claims that a decision depends on,
   verify against current authoritative primary sources rather than memory.
4. Identify what is genuinely unknown. Ask the user only about decisions that materially change the
   plan and cannot be resolved from evidence or sensible defaults; record everything else as an
   assumption or an open question with a resolution gate.

### 2. Define the outcome and requirements

Establish, in writing:

- the intended outcome, target users, and the smallest version that delivers real value;
- functional requirements, stated as observable behavior;
- nonfunctional requirements with measurable bounds — "handles 500 concurrent users at p95 under
  300 ms," not "fast and scalable." "Immediate," "reliable," "secure," and "scalable" are not
  requirements until they have numbers, budgets, or testable criteria;
- explicit non-goals, so scope creep has something to be measured against;
- constraints: budget, deadline, team size and skills, platform mandates, compliance obligations,
  and existing systems that must keep working.

### 3. Make the load-bearing design decisions

For each decision that is expensive to reverse — language and framework, data store, hosting,
authentication approach, multi-tenancy model, third-party dependencies:

1. Name 2–3 realistic alternatives, including the boring default and, where relevant, buy instead
   of build.
2. Choose one and record the rationale in a sentence or two. Prefer the simplest option that meets
   the stated requirements; reject speculative generality and components with no requirement behind
   them.
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
3. Make dependencies between phases explicit, and flag work that can proceed in parallel.
4. For changes to a live system, plan the migration explicitly: compatibility between old and new,
   data transformation, staged rollout, safe abort criteria, and a rollback path that has actually
   been thought through — including whether each step is reversible at all.
5. Keep estimates honest: give ranges, state what they assume, and mark low-confidence estimates
   as such rather than laundering guesses into commitments.

### 6. Plan validation and operations

- Testing: name the levels that matter for this system (unit, integration, end-to-end,
  load, upgrade/rollback) and the specific scenarios each must cover — not "add tests."
- Observability: the logs, metrics, and alerts needed to tell that the system works in production,
  and who gets paged when it does not.
- Launch criteria: the measurable conditions under which the application ships.
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

## 2. Requirements
### Functional
### Nonfunctional (with measurable bounds)
### Non-goals
### Constraints and assumptions

## 3. Design decisions
One entry per load-bearing decision: choice, alternatives considered, rationale.
Mark unresolved decisions **gated** with the verification step that resolves them.

## 4. Architecture
Components, data model, trust boundaries, dependencies and failure handling.

## 5. Delivery phases
One section per phase: goal, scope, deliverable, acceptance gate, dependencies,
estimate (with confidence). Include migration, rollout, and rollback where applicable.

## 6. Validation and operations
Tests, observability, launch criteria, operational ownership.

## 7. Risks and pre-mortem
Top risks with mitigations or early-warning signals.

## 8. Open questions
Each with an owner, a resolution gate, and what is blocked until it is resolved.
```

Scale the depth to the project: a weekend prototype does not need a compliance section, but it
still needs requirements, a first slice, and a definition of done. State when a section is
intentionally thin and why.

## Quality bar

Before delivering, verify that:

- every requirement is testable and every nonfunctional requirement has a measurable bound;
- every load-bearing decision names its alternatives and rationale, or is explicitly gated;
- no phase depends on an unverified assumption without a gate in front of it;
- the first phase retires the biggest risk, not the easiest task;
- rollback and abort paths exist for every irreversible or user-facing step;
- open questions are tracked with owners and gates, not scattered as hedges through the text;
- the plan contains nothing that exists only to appear thorough — every section changes what the
  builder would do next.

A plan meeting this bar should survive an adversarial review without critical findings.
