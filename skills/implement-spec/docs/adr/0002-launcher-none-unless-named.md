---
status: superseded by ADR-0004
---

# Launcher is none unless named

Inherit takes this session's CLI and launcher none. `va` is on a round only when the args name it; it is not inferred from PATH, env, or process ancestry. `va` execs the CLI and strips its own env, so a session already inside `va` cannot see the launcher, and guessing `va` from PATH would spawn vaulted rounds for a bare-CLI orchestrator that did not ask for them.
