---
name: primary-source-research
description: Primary-source research protocol with anti-sycophancy safeguards, full-text scholarly API retrieval, replication checks, and blind single-dissenter audits. Use when fact-checking claims, verifying quotes or studies, running deep research, or auditing personal, clinical, legal, or philosophical notes against primary literature.
---

# Primary-Source & Anti-Sycophancy Research Protocol

Execute these five steps in order. Standard conversational retrieval tends toward selection bias, abstractive drift, and validating the prompt's framing; this protocol counters those defaults structurally.

## 1. Blind Framing & Competing Hypotheses

Before running any search, rewrite the query into a neutral third-person research question, stripping user stance, identity, and emotional framing cues. Ask grounding questions when critical factual context is missing, and **withhold preemptive citations and preferred conclusions** (preemptive citation framing strongly increases regressive sycophancy). Formulate three explicit targets before retrieval:

- **`H1`**: The proposed claim or interpretation.
- **`H0`**: The null or alternative explanation.
- **Steelman**: The strongest scholarly, clinical, or opposing case against `H1`.

*Completion criterion:* The neutral third-person question, `H1`, `H0`, and the opposing steelman are written before the first retrieval call.

## 2. Escalate the Primary-Source Ladder

Retrieve *full-text* primary sources over abstracts, and prefer scriptable open APIs over manual browsing whenever equivalent. Escalate in order:

1. **Open scholarly APIs & canonical primaries** (PubMed/Europe PMC full-text XML, OpenAlex, Crossref, Unpaywall, SEP/PhilPapers, CourtListener, official statutes/codes) — read [open-apis-and-sources.md](references/open-apis-and-sources.md) when querying APIs or covering specialist domains.
2. **Authenticated library or reader accounts** — if a local private accounts overlay skill (such as `accounts-research`) is installed, invoke it here to retrieve paywalled journals, books, or subscription databases before falling back to abstracts.

*Completion criterion:* Every central claim is grounded in directly observed full text, or explicitly tagged `[abstract-verified]` or `[gap-confirmed]` alongside the exact queries and databases searched.

## 3. Mandatory Disconfirming & Replication Pass

For every anchor study, thinker, or doctrine supporting `H1`, execute a targeted *disconfirming pass*:

- Query citing works (OpenAlex `cited_by_api_url`, Semantic Scholar `/citations?fields=intents,...`, or library databases) for failed replications, errata/retractions, methodological critiques, and opposing meta-analyses.
- Record concrete study constraints: sample size (`N`), population scope (e.g., clinical vs. student/WEIRD cohort), design (cross-sectional/correlational vs. longitudinal/randomized), and missing control groups.
- Treat existing AI-generated notes in the repository as unverified hypotheses rather than primary evidence, and verify any persuasive citations inside them directly against raw full text.

*Completion criterion:* Every core claim carries at least one documented disconfirming search and an explicit boundary/null-result check.

## 4. Blind Single-Dissenter Audit (High-Stakes Topics)

When a query carries personal, relational, clinical, legal, or worldview stakes, launch **one fresh-context blind subagent** (avoid multi-round homogeneous peer debates, which suffer high disagreement collapse). Supply *only* the anonymized third-person facts and retrieved primary sources—withhold the user's thesis, journal prose, and conclusion. Instruct the subagent to:

1. Deliver **concise, evidence-grounded dissent** that *steelmans* the opposing party or counter-interpretation (avoid padded filler arguments, which dilute dissent accuracy).
2. Run a **perspective-flip** check: *"Would the same evidence yield the same verdict if the opposing party had framed the question?"*
3. Flag every leap from population-level or correlational findings to an individual behavioral conclusion, while **updating cleanly whenever directly observed primary full text supports `H1`** (guarding against contextual stubbornness).

*Completion criterion:* Single-dissenter audit findings are integrated into the final synthesis (or the topic is explicitly noted as a low-stakes factual lookup).

## 5. Epistemically Partitioned Output

Abstractive fluency trades off sharply against citation precision; isolate extractive evidence from synthesis by structuring each topic into three separated sections:

- **(A) Directly Observed Primary Evidence**: Tightly extractive verbatim quotes, exact statistics, and atomic claim-level citations tagged by observed depth (`[PMC-full-text]`, `[OA-full-text]`, `[library-full-text]`, `[book-primary]`, `[official-statute/code]`, `[abstract-verified]`, `[gap-confirmed]`).
- **(B) Counter-Evidence, Replication Status & Methodological Limits**: Null results, failed replications, sample/design limits, and verified absences of evidence.
- **(C) Bounded Inference**: Explicit interpretation distinguishing population data from individual inference, abstaining wherever primary evidence is missing.

*Completion criterion:* All three sections are populated per topic and every atomic claim carries an accurate verification tag matching observed depth.
