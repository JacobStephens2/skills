#!/usr/bin/env python3
"""Read Granola notes using GRANOLA_API_KEY; keep transcript output file-backed."""

import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

BASE_URL = "https://public-api.granola.ai/v1"


class TranscriptTooLarge(RuntimeError):
    pass


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        # Keep the bearer credential on the explicitly selected API host.
        return None


def request(path, params):
    key = os.environ.get("GRANOLA_API_KEY")
    if not key:
        raise RuntimeError("GRANOLA_API_KEY is missing from this process's environment.")
    url = BASE_URL + path + "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"Authorization": "Bearer " + key})
    try:
        with urllib.request.build_opener(NoRedirect).open(req, timeout=30) as response:
            raw = response.read()
    except urllib.error.HTTPError as exc:
        body = exc.read()
        if b"TRANSCRIPT_TOO_LARGE" in body:
            raise TranscriptTooLarge(
                "TRANSCRIPT_TOO_LARGE: use the documented paginated transcript endpoint."
            ) from None
        message = {
            401: "check the API credential",
            403: "check the key's note access scope",
            404: "check the API note ID, access, and note processing status",
            429: "rate limited; respect Retry-After before retrying",
        }.get(exc.code, "check the official API documentation and service status")
        retry = exc.headers.get("Retry-After", "") if exc.headers else ""
        if exc.code == 429 and retry.isdecimal():
            message += f" ({retry} seconds)"
        # Never print response bodies: they may include private data.
        raise RuntimeError(f"Granola HTTP {exc.code}: {message}.") from None
    except (urllib.error.URLError, TimeoutError):
        raise RuntimeError(
            "Granola network request failed; check network access and sandbox permissions."
        ) from None
    try:
        data = json.loads(raw)
    except (ValueError, UnicodeError):
        raise RuntimeError("Granola returned invalid JSON.") from None
    if not isinstance(data, dict):
        raise RuntimeError("Unexpected API response; expected a JSON object.")
    return data, raw


def pages(path, params, field, max_pages):
    params, seen = dict(params), set()
    for _ in range(max_pages):
        data, raw = request(path, params)
        if not isinstance(data.get(field), list) or not isinstance(data.get("hasMore"), bool):
            raise RuntimeError("Unexpected page schema; retrieval completeness is unknown.")
        yield data[field], raw
        if not data["hasMore"]:
            return
        cursor = data.get("cursor")
        if not isinstance(cursor, str) or not cursor or cursor in seen:
            raise RuntimeError("Pagination did not advance; retrieval is incomplete.")
        seen.add(cursor)
        params["cursor"] = cursor
    raise RuntimeError("Page limit reached; narrow the window or raise --max-pages.")


def list_notes(args):
    params = {"created_after": args.after, "created_before": args.before, "page_size": 30}
    notes = []
    for batch, _raw in pages("/notes", params, "notes", args.max_pages):
        notes.extend(batch)
    matches = [n for n in notes if args.title.casefold() in (n.get("title") or "").casefold()]
    fields = ("id", "title", "created_at", "updated_at")
    print(json.dumps({"complete": True, "scanned": len(notes), "notes": [
        {field: n.get(field) for field in fields} for n in matches
    ]}, ensure_ascii=False, indent=2))


def get_note(args):
    if not re.fullmatch(r"not_[A-Za-z0-9]{14}", args.note_id):
        raise RuntimeError("Use the not_ ID returned by list, not a share-link UUID.")
    out = Path(args.out_dir).expanduser()
    if out.exists():
        raise RuntimeError("Choose a new output directory; existing files are not overwritten.")
    paginated = False
    try:
        note, raw = request(f"/notes/{args.note_id}", {"include": "transcript"})
    except TranscriptTooLarge:
        note, raw = request(f"/notes/{args.note_id}", {})
        paginated = True
    out.mkdir(parents=True, mode=0o700)
    (out / "note.json").write_bytes(raw)
    segments = note.get("transcript")
    if paginated:
        segments = []
        for index, (batch, page_raw) in enumerate(pages(
            f"/notes/{args.note_id}/transcript", {"page_size": 100},
            "transcript", args.max_pages
        ), 1):
            (out / f"transcript-page-{index:03}.json").write_bytes(page_raw)
            segments.extend(batch)
    if not isinstance(segments, list) or not segments:
        raise RuntimeError(f"No transcript returned; original response saved to {out / 'note.json'}.")
    if any(not isinstance(s, dict) or not isinstance(s.get("text"), str) for s in segments):
        raise RuntimeError(f"Unexpected transcript schema; original response saved to {out / 'note.json'}.")
    header = [
        "Title: " + str(note.get("title")),
        "Note ID: " + args.note_id,
        "URL: " + str(note.get("web_url")),
        "Retrieved: " + datetime.now(timezone.utc).isoformat(),
        "Speaker objects are source labels; names are not inferred.",
    ]
    blocks = ["\n".join(header)]
    for index, segment in enumerate(segments, 1):
        speaker = json.dumps(segment.get("speaker"), ensure_ascii=False)
        blocks.append(
            f"T{index:03} [{segment.get('start_time')} — {segment.get('end_time')}] {speaker}\n"
            + segment["text"]
        )
    (out / "transcript.txt").write_text("\n\n".join(blocks) + "\n", encoding="utf-8")
    print(json.dumps({"note_id": args.note_id, "segments": len(segments),
                      "note_json": str(out / "note.json"),
                      "transcript": str(out / "transcript.txt")}, indent=2))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    listing = commands.add_parser("list", help="Find notes within a creation-date window")
    listing.add_argument("--after", required=True, help="API created_after date or timestamp")
    listing.add_argument("--before", required=True, help="API created_before date or timestamp")
    listing.add_argument("--title", default="", help="Case-insensitive title substring")
    listing.add_argument("--max-pages", type=int, default=20)
    listing.set_defaults(run=list_notes)
    get = commands.add_parser("get", help="Save a transcript and original API responses")
    get.add_argument("note_id")
    get.add_argument("--out-dir", required=True)
    get.add_argument("--max-pages", type=int, default=100)
    get.set_defaults(run=get_note)
    args = parser.parse_args()
    try:
        args.run(args)
    except (RuntimeError, OSError) as exc:
        print(str(exc), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
