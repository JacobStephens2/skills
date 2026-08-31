# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Before exploring, read these

- **`implement-spec/CONTEXT.md`** when the work is that skill.
- **`implement-spec/docs/adr/`** for decisions in that skill, when the directory exists.
- **`CONTEXT-MAP.md`** at the repo root if it exists later: it would point at one `CONTEXT.md` per skill.

If a listed file doesn't exist, **proceed silently**. Don't flag its absence; don't suggest creating it upfront. `/domain-modeling` (via `/grill-with-docs`) creates files lazily when terms or decisions resolve.

There is no root `CONTEXT.md`. Do not invent one.

## File structure

This repo is a kit of skills. Today one skill has a glossary:

```
/
├── implement-spec/
│   ├── CONTEXT.md
│   └── docs/adr/          ← create lazily with the first ADR
└── docs/
    └── agents/            ← this file
```

A root `CONTEXT-MAP.md` is added only when a second skill gets a glossary.

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in the relevant `CONTEXT.md`. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal: either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders), but worth reopening because…_
