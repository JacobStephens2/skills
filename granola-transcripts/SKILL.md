---
name: granola-transcripts
description: Retrieve Granola meeting transcripts through the API. Use when a task needs meeting quotes, decisions, or verification of a Granola summary.
---

# Granola transcripts

Use the official API when `GRANOLA_API_KEY` is available. The bundled Python 3
helper lists notes and saves the full note response plus a readable transcript.
It needs no third-party packages. Resolve `scripts/granola.py` relative to this
skill directory, not the user's working directory.

## 1. Find the meeting

Check key availability without showing its value:

```bash
python3 -c 'import os; print("GRANOLA_API_KEY: " + ("set" if os.getenv("GRANOLA_API_KEY") else "missing"))'
```

If the user launched the agent through an environment-loading wrapper, inspect
the current environment first; another launch is unnecessary when the key is
already present. Keep the key in the environment rather than command arguments,
logs, files, or chat. For missing credentials, use the access reference below.

List a bounded date window and inspect titles and creation times:

```bash
python3 /path/to/granola-transcripts/scripts/granola.py list \
  --after 2026-01-26 --before 2026-01-29 --title 'project'
```

`--title` is an optional case-insensitive substring filter applied locally after
pagination. The helper follows `hasMore`/`cursor` until complete and errors if
its page limit is reached; an incomplete search is not an absence finding.

Date filters refer to **note creation**, not scheduled meeting time. For “this
morning,” establish the user's date/timezone, search a window padded around
UTC boundaries, then match the note's calendar event, attendees, and transcript
timestamps. Widen the window if a note may have been created in advance.
Resolve multiple plausible meetings from that metadata or ask the user.

Use the `not_…` ID returned by the API. A UUID in a `notes.granola.ai/t/…` share
link or `/d/…` document link is not the API note ID. Locate it through the note
list and confirm using `web_url` and meeting metadata rather than substituting
that UUID in the API path. A public summary page is not a transcript.

## 2. Retrieve and read

```bash
python3 /path/to/granola-transcripts/scripts/granola.py get \
  not_XXXXXXXXXXXXXX --out-dir /tmp/granola-meeting
```

Choose a **new** output directory outside the skill/repository; results may
contain private notes and attendee details. Copy evidence into the user's
project only when the task calls for it. The command uses
`GET /v1/notes/{note_id}?include=transcript`, writes the original response to
`note.json`, and writes all segments to `transcript.txt`. Oversized transcripts
are fetched in cursor pages, preserved as `transcript-page-001.json`, etc. Console output is a
small receipt with paths and segment count. Search/read those files in chunks
instead of dumping the whole JSON into a tool result and losing it to truncation.

The readable transcript preserves source text, ISO timestamps, speaker objects,
and one-based `T001` segment numbers. Keep the original JSON as the source.
`me`/`them` and microphone/speaker indicate capture attribution, not reliably
named people; `them` can include multiple participants. Identify names only
when supported, and label contextual speaker mapping as inference. Calendar
attendees alone do not establish who said a line.

## 3. Use the evidence

Verify material quotations and decisions in surrounding turns.
Keep transcript evidence, generated summaries, user recollections, and your
interpretation distinct. Preserve proposed examples as proposals rather than
commitments. Cite `web_url` with timestamp/segment references where useful.

Completion: the requested meeting is matched, its complete transcript is saved,
and the answer identifies its source. If retrieval is incomplete, state exactly
what was retrieved and what remains unavailable.

For a missing key, no matching note, or a retrieval error, read
[Access problems and incomplete retrieval](references/access-and-errors.md).
