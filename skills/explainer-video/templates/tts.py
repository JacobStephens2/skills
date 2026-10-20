"""Generate narration per scene with ElevenLabs, with character timestamps.

usage: python3 -I tts.py <narration.json> <out_dir> <voice_id> [model_id] [scene ...]
Reads ELEVENLABS_API_KEY from the environment (e.g. injected by a secrets wrapper). Never prints it.
Writes <out_dir>/<scene>.mp3 and <out_dir>/<scene>.json (alignment + text).
"""
import base64, json, os, sys, urllib.request, urllib.error

src, out, voice = sys.argv[1], sys.argv[2], sys.argv[3]
model = sys.argv[4] if len(sys.argv) > 4 else "eleven_multilingual_v2"
only = set(sys.argv[5:])
key = os.environ["ELEVENLABS_API_KEY"]
lines = json.load(open(src))
os.makedirs(out, exist_ok=True)

for i, line in enumerate(lines):
    if only and line["scene"] not in only:
        continue
    body = {
        "text": line["text"],
        "model_id": model,
        "voice_settings": {"stability": 0.55, "similarity_boost": 0.75, "style": 0.15, "use_speaker_boost": True, "speed": 1.0},
        # Neighbouring lines keep intonation continuous across separately generated scenes.
        "previous_text": lines[i - 1]["text"] if i > 0 else None,
        "next_text": lines[i + 1]["text"] if i + 1 < len(lines) else None,
    }
    req = urllib.request.Request(
        f"https://api.elevenlabs.io/v1/text-to-speech/{voice}/with-timestamps?output_format=mp3_44100_128",
        data=json.dumps(body).encode(), headers={"xi-api-key": key, "Content-Type": "application/json"})
    try:
        res = json.load(urllib.request.urlopen(req, timeout=120))
    except urllib.error.HTTPError as e:
        print(line["scene"], "HTTP", e.code, e.read()[:300].decode(errors="replace"))
        sys.exit(1)
    open(f"{out}/{line['scene']}.mp3", "wb").write(base64.b64decode(res["audio_base64"]))
    json.dump({"text": line["text"], "alignment": res.get("normalized_alignment") or res.get("alignment")},
              open(f"{out}/{line['scene']}.json", "w"))
    print(line["scene"], "ok")
