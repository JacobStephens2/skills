# Access problems and incomplete retrieval

- **Missing key:** use an already connected Granola MCP or ask the user to
  provision `GRANOLA_API_KEY` through their normal secret/launcher mechanism.
  MCP uses its own OAuth connection; an API key is not an MCP login.
- **No match:** report the searched window and accessible results. Absence from
  this API response does not prove a meeting was not recorded. Check date,
  title, account/access scope, and whether the note has finished processing.
- **Missing/empty transcript:** the helper preserves `note.json` and exits with
  an explicit error. Use a supplied transcript or an available authenticated
  connector; identify the substitution.
- **401/403:** resolve the credential or scope; repeating the same request will
  not fix access. **429:** wait for the server's indicated retry interval, or
  pause and report the limit; avoid a polling loop.
- **Network/sandbox failure:** use the environment's normal network approval
  path. The helper does not bypass it or switch to an undocumented endpoint.
- **Oversized transcripts:** the helper falls back to the documented
  [paginated endpoint](https://docs.granola.ai/api-reference/get-transcript).
  If pagination fails, saved pages are partial evidence; `transcript.txt` and
  a success receipt are produced only after all pages have been retrieved.

Official references, checked September 15, 2026:
[API access](https://docs.granola.ai/help-center/sharing/integrations/granola-api),
[List Notes](https://docs.granola.ai/api-reference/list-notes),
[Get Note](https://docs.granola.ai/api-reference/get-note).
Consult these when responses differ from the helper's expected schema.
