"""Offline behavior checks; all meeting data and credentials below are synthetic."""

import argparse
from contextlib import redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch, MagicMock
from urllib.error import HTTPError
from urllib.parse import parse_qs, urlparse

spec = importlib.util.spec_from_file_location("granola", Path(__file__).parents[1] / "scripts/granola.py")
granola = importlib.util.module_from_spec(spec)
spec.loader.exec_module(granola)
NOTE_ID = "not_00000000000000"
SEGMENT = {"text": "First line.\nSecond line — yes.", "start_time": "2026-01-27T15:30:00Z",
           "end_time": "2026-01-27T15:30:03Z", "speaker": {"attribution": "them", "source": "speaker"}}


def response(data):
    return data, json.dumps(data, ensure_ascii=False).encode()


class GranolaTests(unittest.TestCase):
    def test_list_filters_after_all_pages(self):
        pages = [response({"notes": [{"id": "a", "title": "Other"}], "hasMore": True, "cursor": "next"}),
                 response({"notes": [{"id": "b", "title": "PROJECT review"}], "hasMore": False, "cursor": None})]
        args = argparse.Namespace(after="2026-01-26", before="2026-01-29", title="project", max_pages=20)
        calls = []
        def fetch(path, params):
            calls.append((path, dict(params)))
            return pages.pop(0)
        output = io.StringIO()
        with patch.object(granola, "request", side_effect=fetch), redirect_stdout(output):
            granola.list_notes(args)
        result = json.loads(output.getvalue())
        self.assertEqual(result["scanned"], 2)
        self.assertEqual([n["id"] for n in result["notes"]], ["b"])
        self.assertEqual(calls[1][1]["cursor"], "next")

    def test_repeated_cursor_fails(self):
        page = response({"notes": [], "hasMore": True, "cursor": "same"})
        with patch.object(granola, "request", return_value=page):
            with self.assertRaisesRegex(RuntimeError, "incomplete"):
                list(granola.pages("/notes", {}, "notes", 20))

    def test_page_limit_fails_instead_of_claiming_complete(self):
        page = response({"notes": [], "hasMore": True, "cursor": "next"})
        with patch.object(granola, "request", return_value=page):
            with self.assertRaisesRegex(RuntimeError, "Page limit"):
                list(granola.pages("/notes", {}, "notes", 1))

    def test_get_preserves_raw_response_text_and_speakers(self):
        note, raw = response({"id": NOTE_ID, "transcript": [SEGMENT]})
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "result"
            args = argparse.Namespace(note_id=NOTE_ID, out_dir=str(out), max_pages=100)
            with patch.object(granola, "request", return_value=(note, raw)), redirect_stdout(io.StringIO()):
                granola.get_note(args)
            self.assertEqual((out / "note.json").read_bytes(), raw)
            text = (out / "transcript.txt").read_text()
            self.assertIn(SEGMENT["text"], text)
            self.assertIn('"attribution": "them"', text)
            self.assertIn("T001", text)
            self.assertIn(SEGMENT["start_time"], text)
            with self.assertRaisesRegex(RuntimeError, "new output directory"):
                granola.get_note(args)

    def test_oversized_transcript_fetches_all_pages(self):
        replies = [granola.TranscriptTooLarge(), response({"id": NOTE_ID}),
                   response({"transcript": [SEGMENT], "hasMore": True, "cursor": "second"}),
                   response({"transcript": [SEGMENT], "hasMore": False, "cursor": None})]
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "result"
            args = argparse.Namespace(note_id=NOTE_ID, out_dir=str(out), max_pages=100)
            with patch.object(granola, "request", side_effect=replies), redirect_stdout(io.StringIO()):
                granola.get_note(args)
            self.assertTrue((out / "transcript-page-002.json").exists())
            self.assertIn("T002", (out / "transcript.txt").read_text())

    def test_missing_transcript_preserves_note_without_success_artifact(self):
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "result"
            args = argparse.Namespace(note_id=NOTE_ID, out_dir=str(out), max_pages=100)
            with patch.object(granola, "request", return_value=response({"transcript": None})):
                with self.assertRaisesRegex(RuntimeError, "No transcript"):
                    granola.get_note(args)
            self.assertTrue((out / "note.json").exists())
            self.assertFalse((out / "transcript.txt").exists())

    def test_request_uses_official_host_and_environment_auth(self):
        opener = MagicMock()
        opener.open.return_value.__enter__.return_value.read.return_value = b'{}'
        with patch.dict(os.environ, {"GRANOLA_API_KEY": "unit-test-token"}), \
             patch.object(granola.urllib.request, "build_opener", return_value=opener):
            granola.request("/notes/" + NOTE_ID, {"include": "transcript"})
        req = opener.open.call_args.args[0]
        self.assertEqual(urlparse(req.full_url).hostname, "public-api.granola.ai")
        self.assertEqual(req.get_header("Authorization"), "Bearer unit-test-token")
        self.assertEqual(parse_qs(urlparse(req.full_url).query), {"include": ["transcript"]})

    def test_http_errors_do_not_disclose_body_or_credential(self):
        error = HTTPError("https://public-api.granola.ai", 401, "Unauthorized", {}, io.BytesIO(b"private-response"))
        opener = MagicMock()
        opener.open.side_effect = error
        with patch.dict(os.environ, {"GRANOLA_API_KEY": "unit-test-token"}), \
             patch.object(granola.urllib.request, "build_opener", return_value=opener):
            with self.assertRaises(RuntimeError) as caught:
                granola.request("/notes", {})
        self.assertNotIn("private-response", str(caught.exception))
        self.assertNotIn("unit-test-token", str(caught.exception))

    def test_missing_key_makes_no_network_call(self):
        with patch.dict(os.environ, {}, clear=True), patch.object(granola.urllib.request, "build_opener") as opener:
            with self.assertRaisesRegex(RuntimeError, "missing"):
                granola.request("/notes", {})
            opener.assert_not_called()


if __name__ == "__main__":
    unittest.main()
