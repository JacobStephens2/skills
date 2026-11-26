# Open Scholarly APIs & Canonical Primary Sources

Use these free, scriptable APIs and canonical repositories first when equivalent to browser retrieval, and to locate open full text, replication chains, and primary texts across domains.

## Optional Environment Variables

Set any of the following in your environment to unlock higher rate limits, daily budgets, or authenticated endpoints:

- `$OPENALEX_API_KEY` — OpenAlex `Authorization: Bearer` header (`$1.00/day` budget vs. `$0.10/day` anonymous, `30 RPS`, cursor paging).
- `$SEMANTIC_SCHOLAR_API_KEY` — Semantic Scholar Graph API (`x-api-key: ...` header).
- `$NCBI_API_KEY` — NCBI PubMed E-utilities (`&api_key=...`, `10 req/sec`).
- `$COURTLISTENER_API_TOKEN` — CourtListener REST API v4 (`Authorization: Token ...` header).
- `$RESEARCH_EMAIL` — Polite-pool identifier for Unpaywall (`?email=`) and Crossref (`mailto:`).

## 1. Citation Graphs, Replication Tracking & Open Full Text

Essential for **Step 3 (Disconfirming & Replication Pass)** and finding legal open-access full text:

- **OpenAlex API** (`https://api.openalex.org/works`):
  - **Authentication:** Pass `Authorization: Bearer $OPENALEX_API_KEY` (or `?api_key=...`) — never commit keys to git. Fall back to anonymous singleton lookups if unset.
  - **Daily budgets & rate limits (free account key, resets midnight UTC):** **`$1.00/day`** budget, **`30 RPS`**, required for cursor paging past page 1. Singleton DOI/ID lookups (`/works/https://doi.org/<doi>`) are **free**; list + filter queries cost `$0.0001`/call (`$0.10/1k`); full-text/semantic searches cost `$0.001`/call (`$1.00/1k`); cached PDF/content downloads cost `$0.01`/call (~100/day free). Check quota via `GET https://api.openalex.org/rate-limit`.
  - **Budget conservation:** Use `per_page=100`, `select=...` to trim payloads, and `|`-batched DOI/ID filters (`?filter=doi:...|...`).
  - **Key fields for disconfirming passes:** `is_retracted`, `cited_by_count`, `cited_by_api_url` (retrieve newer critiques, replications, and errata), `referenced_works`, and `open_access.oa_url` / `best_oa_location.pdf_url`.
- **Semantic Scholar Graph API** (`https://api.semanticscholar.org/graph/v1/paper/DOI:<doi>?fields=title,year,citationCount,influentialCitationCount,openAccessPdf`):
  - Pass `x-api-key: $SEMANTIC_SCHOLAR_API_KEY` when set and throttle to `>= 1.1s` between requests (free key tier is `1 RPS`; burst calls trigger `HTTP 429`).
  - Fetch citing intents on the citations sub-endpoint (`https://api.semanticscholar.org/graph/v1/paper/DOI:<doi>/citations?fields=intents,isInfluential,citingPaper.title,citingPaper.year&limit=100` — requesting `citations.intents` directly on `/paper/{id}` returns `HTTP 400`) to locate `methodology` / `result` papers that challenge or re-test an anchor claim.
- **Crossref API** (`https://api.crossref.org/works/<doi>`):
  - Canonical bibliographic metadata, `update-to` retraction/correction links, and publisher text-mining/license URLs.
- **Unpaywall API** (`https://api.unpaywall.org/v2/<doi>?email=<email>`):
  - Legal green/gold open-access PDF lookup for otherwise paywalled DOIs.

## 2. Biomedical, Clinical Psychology & Trial Registries

- **PubMed E-utilities** (`https://eutils.ncbi.nlm.nih.gov/entrez/eutils/`): `esearch.fcgi` + `efetch.fcgi` for verified `PMID` metadata and abstracts (append `&api_key=$NCBI_API_KEY` when set for `10 req/sec`).
- **Europe PMC REST API** (`https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=<q>&format=json` and `https://www.ebi.ac.uk/europepmc/webservices/rest/<PMCID>/fullTextXML`):
  - Scriptable open-access **full-text XML** across PMC, preprints, and life/behavioral sciences. Resolve DOIs via OpenAlex first if `DOI:"..."` quoted search misses; for publisher deposits whose XML returns abstract-only (e.g., some *PNAS* articles), read `https://pmc.ncbi.nlm.nih.gov/articles/<PMCID>/` HTML or the Unpaywall OA URL.
- **Cochrane Library** (`https://www.cochranelibrary.com/`) & **Campbell Collaboration** (`https://www.campbellcollaboration.org/`):
  - Systematic reviews and meta-analyses. Cochrane abstracts and plain-language summaries are free; many full Cochrane reviews and all Campbell reviews are open access (check `PMC` / `Unpaywall` via DOI).
- **PsyArXiv / OSF Preprints** (`https://osf.io/preprints/psyarxiv`):
  - Preprints, null-result manuscripts, and registered reports in clinical/social psychology.
- **ClinicalTrials.gov API v2** (`https://clinicaltrials.gov/api/v2/studies?query.term=<q>`):
  - Detect unpublished null trials, primary-outcome switching, and sample deviations in clinical interventions.

## 3. Philosophy, Classics & Humanities Primaries

- **Stanford Encyclopedia of Philosophy (SEP)** (`https://plato.stanford.edu/`) & **Internet Encyclopedia of Philosophy (IEP)** (`https://iep.utm.edu/`): Peer-reviewed living reference works in philosophy, ethics, logic, and philosophy of religion.
- **PhilPapers** (`https://philpapers.org/`) & **PhilArchive** (`https://philarchive.org/`): Philosophy and humanities index with open-access preprints.
- **Canonical Classics & Texts:** **Perseus Digital Library** (`https://www.perseus.tufts.edu/`), **Christian Classics Ethereal Library (CCEL)** (`https://www.ccel.org/`), **Sefaria** (`https://www.sefaria.org/`).

## 4. Law, Statutes & Case Law

- **Federal & State Case Law:** **CourtListener / Free Law Project** (`https://www.courtlistener.com/api/rest/v4/`, pass `Authorization: Token $COURTLISTENER_API_TOKEN` when set) for published judicial opinions and dockets; **Cornell LII** (`https://www.law.cornell.edu/`) for federal statutes, U.S. Code, and Supreme Court opinions.
- **Statutes & Administrative Codes:** Consult the official state legislature or national statutory portal directly when verifying statutory text.

## 5. Books & Archival Works

- **Internet Archive / Open Library** (`https://archive.org/` / `https://openlibrary.org/`): Controlled digital lending and inside-book full-text search to verify exact quotes and page numbers.
- **HathiTrust Digital Library** (`https://www.hathitrust.org/`) · **Project Gutenberg** (`https://www.gutenberg.org/`) · **Standard Ebooks** (`https://standardebooks.org/`).
