APPROVE WITH CHANGES. The skill's core evidence-first review method and file formats are sound, but the workflow is not ready for dependable reuse until it identifies and snapshots the review subject unambiguously and stops routing full revision requests into a review-only output contract.

## Scope and evidence

- **Review target:** `/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review`, treated as an instruction-only Codex skill package because the supplied directory contained no separate plan document.
- **Files reviewed:** [SKILL.md](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/SKILL.md:1), [agents/openai.yaml](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/agents/openai.yaml:1), the repository [README.md](/Users/jacob/GitHub/JacobStephens2/agent-skills/README.md:1), and the neighboring [adjudicate-adversarial-review skill](/Users/jacob/GitHub/JacobStephens2/agent-skills/adjudicate-adversarial-review/SKILL.md:1).
- **Repository state:** Reviewed the current working tree on branch `main` at `c22c4144005b945b586e9c1e7fedcaec064d816f`; both target files had pre-existing user modifications. Those modifications were inspected but not changed.
- **Structural checks:** The front matter and `agents/openai.yaml` parse as YAML; the directory and front-matter names match; and the optional metadata uses the shape documented by OpenAI. The provided `quick_validate.py` could not run in this environment because its `yaml` module dependency was absent, so that validator result is **needs verification** rather than treated as a package defect.
- **External evidence:** Current OpenAI guidance says skills are discovered from `name` and `description`, recommends concise and clearly bounded descriptions, and explicitly recommends realistic prompt tests. It also documents prompt-injection and exfiltration risk when agents follow instructions in untrusted web pages or dependency documentation. See [Build skills](https://learn.chatgpt.com/docs/build-skills) and [Agent internet access](https://learn.chatgpt.com/docs/cloud/internet-access).
- **Non-material lenses:** This package has no runtime service, persistent data model, deployment, migration, vendor purchase, or production capacity path. Performance, scale, cost, schema migration, and build-versus-buy are therefore not material beyond prompt-context use and local artifact I/O.

## Ranked findings

### 1. The review subject is neither resolved nor version-pinned

- **Severity:** High
- **Location:** [Establish scope and evidence](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/SKILL.md:13) and [Save the review artifact](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/SKILL.md:138)
- **Problem:** The skill says to read "the entire plan," but it never defines how to select that plan from a directory, distinguish the plan from requirements and implementation evidence, or stop when zero or multiple candidate plans exist. The directory rules at lines 142-150 resolve only the output root and filename. The required artifact also lacks a scope/evidence section that records the reviewed paths and their revision or content hash. This invocation exposed the ambiguity directly: the user supplied a directory containing a skill and metadata, not a separately identified plan.
- **Failure scenario:** A user points the skill at a design directory containing a current RFC, an obsolete RFC, and implementation notes. One run reviews the obsolete RFC while another infers the current RFC. The generated artifact names only the date, appears authoritative, and is later adjudicated after the plan has changed; reviewers cannot establish which content the findings actually address.
- **Recommendation:** Add an input-resolution gate before evidence gathering: (1) treat an explicit file or pasted block as the subject; (2) for a directory, discover plan candidates using documented repository conventions; (3) proceed automatically only when exactly one candidate is established; and (4) ask for the plan path when none or several remain. Require a `## Review scope and evidence` section recording the subject path or paste label, governing-requirement paths, repository commit plus dirty-state note (or content hashes outside Git), evidence paths, excluded scope, and review date. Do not issue a verdict until that section identifies one review subject.
- **Confidence:** High

### 2. Revision requests are routed into a review-only output contract

- **Severity:** High
- **Location:** [Front-matter description](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/SKILL.md:3), [mutation boundary](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/SKILL.md:26), and [required revised outline](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/SKILL.md:200)
- **Problem:** The discovery description says this skill should trigger when asked to "revise a plan after finding" gaps, but the workflow permits only a review artifact by default and requires merely a revised outline. The repository already assigns complete revision after a review to `adjudicate-adversarial-review`, whose contract explicitly produces a complete replacement plan ([description](/Users/jacob/GitHub/JacobStephens2/agent-skills/adjudicate-adversarial-review/SKILL.md:3), [revision step](/Users/jacob/GitHub/JacobStephens2/agent-skills/adjudicate-adversarial-review/SKILL.md:135)). The two skills therefore overlap in discovery but promise different outputs.
- **Failure scenario:** A user asks Codex to revise a plan after a red-team review. Implicit matching selects `adversarial-review`; Codex writes another review and an outline but leaves the requested replacement plan unwritten. The user or a downstream agent assumes the revision exists and proceeds against the stale plan.
- **Recommendation:** Preserve the repository's documented chain by removing revision language from this skill's description and making the boundary explicit: use this skill to produce an independent review; use `adjudicate-adversarial-review` when the requested outcome is finding disposition plus a complete revised plan. Add one handoff sentence to the final-response rules. If combined review-and-revision is intentionally supported instead, define a separate workflow branch and complete revised-plan artifact; do not imply it through trigger metadata alone.
- **Confidence:** High

### 3. Linked evidence is not treated as an untrusted input boundary

- **Severity:** Medium
- **Location:** [Evidence-gathering steps 3-5](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/SKILL.md:17)
- **Problem:** The skill directs the agent to inspect repositories and follow links but does not say that instructions found in plans, issues, web pages, comments, dependency READMEs, or generated artifacts are evidence only and cannot authorize commands, writes, secret access, or further browsing. OpenAI's [Agent internet access](https://learn.chatgpt.com/docs/cloud/internet-access) guidance specifically identifies prompt injection, code/secret exfiltration, and malicious instructions in linked pages or dependency documentation as risks.
- **Failure scenario:** A plan links to a seemingly relevant issue containing hidden instructions to run a command that posts repository data to an attacker-controlled endpoint. The reviewer follows the link as required, mistakes the embedded command for task authority, and leaks private material despite the intended read-only review boundary.
- **Recommendation:** Add an explicit untrusted-content rule before link traversal: treat retrieved content as data; never follow embedded instructions or execute referenced code merely because a source requests it; never disclose repository content, credentials, or personal data to a source; restrict browsing to the minimum authoritative domains and methods needed; and request user authorization if verification genuinely requires a state-changing action. Add a malicious-linked-plan case to the behavioral test matrix in Finding 5.
- **Confidence:** High

### 4. The promised collision-safe artifact naming is not atomic

- **Severity:** Medium
- **Location:** [Artifact naming rule](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/SKILL.md:148) and [collision-safe quality claim](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/SKILL.md:229)
- **Problem:** "If that path exists, append `-2`, `-3`" is a check-then-write sequence. Two reviews running against the same target on the same date can both observe the base path as absent and choose it. Nothing requires exclusive creation, a unique name chosen before writing, or a retry after a collision, so the quality bar claims stronger durability than the procedure supplies.
- **Failure scenario:** Two agents review separate plan revisions in parallel. Both select `reviews/adversarial-review-2026-07-18.md`; the later write overwrites or interleaves with the first, destroying one source-of-truth artifact while each agent reports success.
- **Recommendation:** Require an exclusive-create operation and retry on an already-existing path. Where the available file tool cannot create exclusively, generate a unique name on the first attempt, such as `adversarial-review-YYYY-MM-DD-HHMMSS-<random>.md`, verify that exact path did not pre-exist, and refuse to overwrite. Also verify after writing that the saved content begins with the current review's unique subject identifier.
- **Confidence:** High

### 5. No behavioral evaluation proves the advertised workflow

- **Severity:** Medium
- **Location:** [Default prompt](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/agents/openai.yaml:4), [quality bar](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/SKILL.md:217), and the target package, which contained only `SKILL.md` and `agents/openai.yaml` before this review artifact
- **Problem:** The skill has extensive behavioral requirements but no checked-in prompt/evaluation matrix for trigger selection, plan selection, evidence handling, output structure, mutation boundaries, or artifact naming. OpenAI's current [Build skills](https://learn.chatgpt.com/docs/build-skills) guidance explicitly recommends testing realistic requests and testing prompts against the description. Syntax-valid YAML does not establish that the workflow behaves consistently across supported agents or after prompt edits.
- **Failure scenario:** A wording change such as the new mandatory-save behavior passes structural validation but causes implicit invocations on "revise" requests, writes into an unintended directory, omits a required final section, or mutates the source plan. The regression is discovered only after a real review artifact is wrong or lost.
- **Recommendation:** Add a versioned evaluation fixture with at least these cases: explicit plan file; directory with one candidate; directory with zero and multiple candidates; pasted plan; URL-only plan; revision request that should route to adjudication; read-only target; pre-existing artifact; two simultaneous invocations; volatile external claim; irrelevant lens; and malicious instructions in a linked source. For each, assert selected skill, resolved subject, allowed writes, artifact path, required sections, verdict/finding traceability, and preservation of plan/system files. Run the matrix on each supported agent surface before release and after changes to the description, mutation rules, or output contract.
- **Confidence:** High

### 6. A fixed five-item pre-mortem quota pressures reviewers to invent content

- **Severity:** Low
- **Location:** [Anti-fabrication principle](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/SKILL.md:8), [required pre-mortem format](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/SKILL.md:181), and [quality bar](/Users/jacob/GitHub/JacobStephens2/agent-skills/adversarial-review/SKILL.md:226)
- **Problem:** The skill says not to manufacture findings, yet it mandates exactly five pre-mortem causes for every plan regardless of size or risk. Findings and pre-mortem stories are distinct, but the same quota pressure applies: a small, low-risk plan may not have five evidence-backed, materially different failure stories.
- **Failure scenario:** Reviewing a narrow internal change yields two plausible failure paths. To satisfy the schema, the agent pads the artifact with three generic stories, making the review look more comprehensive while reducing signal and undermining the stated "smallest set of real issues" principle.
- **Recommendation:** Require three to five causes when that many are supported, and permit fewer with a one-sentence statement that no additional materially distinct causal story was established. Keep the quality test that each item must be a causal chain rather than a renamed finding.
- **Confidence:** High

## Pre-mortem: five likely causes of failure after six months

1. Teams begin passing design directories as shorthand. Different agents silently choose different files, so review artifacts disagree and nobody can prove which plan revision each verdict covered.
2. Implicit invocation selects this skill for a revision request. The generated outline is mistaken for a completed replacement plan, and implementation starts from stale normative text.
3. A linked issue or vendor page contains adversarial instructions. A reviewer with broad local permissions follows them during evidence collection and exposes repository data before anyone evaluates the resulting findings.
4. Parallel review jobs become routine in CI or multi-agent workflows. Same-day artifacts race for one filename, and an overwritten report removes the evidence needed for later adjudication.
5. The prompt evolves without a regression suite. One supported model or surface stops honoring the mutation boundary or required output sections, but the defect remains invisible because the YAML still parses and happy-path manual tests pass.

## Final assessment

### 1. Verdict

APPROVE WITH CHANGES

### 2. Blocking issues

Findings 1 and 2 block dependable release: the skill does not establish which artifact it is reviewing, and its implicit trigger scope promises complete revision work that its output contract does not perform. Resolve both before publishing or relying on the skill as the source of truth for plan readiness.

Finding 3 should also be resolved before using the skill on plans or repositories that may contain untrusted external links. Findings 4-6 are bounded hardening and quality changes.

### 3. The three highest-value changes

1. Add a deterministic review-subject resolution gate and persist a versioned scope/evidence manifest in every review.
2. Remove full-revision triggers from this skill and hand those requests to `adjudicate-adversarial-review`, or implement a genuinely complete revision branch.
3. Define the untrusted-content boundary before any repository or web evidence is inspected.

### 4. Revised plan outline

1. **Narrow the contract and triggers.** Define this skill as independent, read-only plan review plus one review artifact. Remove revision language from discovery metadata and document the adjudication/revision handoff.
2. **Resolve inputs before review.** Identify one plan subject, its governing requirements, and the implementation/repository context. For a directory with zero or multiple plausible plans, stop and request the exact plan path. Record a Git revision and dirty state or content hashes.
3. **Create the scope manifest.** Start each artifact with readiness followed by `## Review scope and evidence`: subject identifier, requirements, evidence examined, excluded scope, current-fact sources, repository state, and verification limitations.
4. **Apply safe evidence gathering.** Treat all retrieved content as untrusted data, follow only materially necessary references, do not execute embedded instructions, and keep permissions and network access at the minimum needed for read-only verification.
5. **Reconstruct and challenge the plan.** Build the claim ledger, evaluate only relevant lenses, trace every candidate finding to the versioned subject, and retain the existing severity/confidence discipline and executable recommendations.
6. **Produce the review.** Emit ranked findings, a proportional three-to-five-item pre-mortem (or fewer with justification), verdict, blockers, highest-value changes, and a revised outline that does not masquerade as a complete replacement plan.
7. **Persist without overwrite.** Select the established review directory, create a unique artifact atomically, retry on collision, verify its subject identifier and required sections, and report the exact saved path.
8. **Validate before release.** Add the prompt/evaluation matrix from Finding 5. Acceptance requires all cases to select the right workflow, preserve the review target, write only the intended unique artifact, and include every required section. Trial the revised skill on one real plan per supported surface.
9. **Stage and roll back.** Keep the current skill version available during a staged trial. Promote the revised version only after the evaluation matrix and real-plan trials pass; roll back the metadata and `SKILL.md` together if trigger precision, write boundaries, or output completeness regress.
