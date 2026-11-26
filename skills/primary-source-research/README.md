# primary-source-research

A 5-step anti-sycophancy research protocol for AI agents:

1. **Blind framing & competing hypotheses** (`H1`, `H0`, and an opposing steelman before any search).
2. **Primary-source escalation** (scriptable open scholarly APIs first, then authenticated library/reader accounts if configured).
3. **Mandatory disconfirming & replication pass** (citation graphs for failed replications, retractions, null results, and design/sample constraints).
4. **Blind single-dissenter audit** (one fresh-context subagent running a concise steelman + perspective-flip check).
5. **Epistemically partitioned output** (`(A)` directly observed extractive evidence with depth tags, `(B)` counter-evidence & limits, `(C)` bounded inference).

## Optional API Environment Variables

For higher rate limits and authenticated endpoints in [`references/open-apis-and-sources.md`](references/open-apis-and-sources.md):

- `OPENALEX_API_KEY`
- `SEMANTIC_SCHOLAR_API_KEY`
- `NCBI_API_KEY`
- `COURTLISTENER_API_TOKEN`
- `RESEARCH_EMAIL`

---

## Building a Private Accounts Overlay (`accounts-research`)

If you have personal or institutional subscriptions (public library portals, academic databases, eBook lenders, digital news passes, or personal eReader libraries), keep your **site URLs, card/institution identifiers, quotas, and browser notes in a separate private repo** as a thin overlay skill rather than duplicating this protocol.

### 1. Minimal Private `SKILL.md` Skeleton

```markdown
---
name: accounts-research
description: Authenticated library and reader accounts overlay paired with the primary-source-research skill. Use when retrieving paywalled journals, books, or library databases during primary-source research.
---

# Authenticated Accounts Research Overlay

Follow the `primary-source-research` skill for the 5-step anti-sycophancy protocol and open scholarly APIs. Invoke this overlay during Step 2 (full-text escalation) and Step 3 (disconfirming checks) when open APIs hit a paywall or require logged-in library/reader access.

## Source Router & Account Guardrails

| Source | Best Use | Quota & Side-Effect Guardrails | Reference |
|---|---|---|---|
| **Public / University Library Portal** | Peer-reviewed journals, reference books, regional news | Read-only HTML first; log out of concurrent-user-capped databases immediately after use. | `references/library-databases.md` |
| **Journal Archive** (e.g., JSTOR / alumni portal) | Humanities, history, philosophy, older social-science journals | Read online in-browser; reserve monthly PDF download quotas for explicit user requests. | `references/browser-sources.md` |
| **Library eBook Lender** (e.g., OverDrive / Libby) | Full nonfiction/academic monographs & magazines | Preview via **"Read a sample"** first (`0` loan cost); confirm with the user before borrowing or placing holds. | `references/browser-sources.md` |
| **Personal eReader Library** | Verifying quotes/pages in books you already own | Prefer in-book search snippets over flipping pages when reading position sync matters. | `references/browser-sources.md` |
| **Specialty / News Databases** | Trade/tech books, financial reports, news archives | Check per-vendor pass rules and skip onsite-only databases when working remotely. | `references/library-databases.md` |
```

### 2. Recommended Guardrails for Your Private Overlay

- **Quotas & side effects:** Always preview eBook samples before spending loan slots, read articles online before spending monthly PDF download caps, never make pay-per-article purchases without explicit approval, and release seats immediately on concurrent-user-limited databases.
- **Anti-bot / CAPTCHA gates:** Never attempt to solve or bypass CAPTCHAs or anti-bot checks—stop and let the human sign in directly.
- **Secrets & PII hygiene:** Never commit library card numbers, PINs, emails, API keys, passwords, or session cookies to git. Inject API keys at runtime via environment variables (or a secrets launcher) and keep browser auth inside your normal browser profile.
