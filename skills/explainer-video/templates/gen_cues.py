"""Write cues/NN.js and plan.json from voice/NN.json (ElevenLabs alignment).

Pacing, in seconds: HEAD before the first line (music only), LEAD before each later line,
HOLD after each line, END after the last (music only). Cue words are lowercase with
punctuation and hyphens stripped, apostrophes kept: "non-deterministic" -> "nondeterministic".
"""
import json, math, subprocess

FPS = 30
HEAD, LEAD, HOLD, END = 2.0, 0.6, 1.4, 3.0
lines = json.load(open("narration.json"))
plan = []
for i, l in enumerate(lines):
    s = l["scene"]
    a = json.load(open(f"voice/{s}.json"))["alignment"]
    words, w, ws = [], "", 0.0
    for c, t in zip(a["characters"], a["character_start_times_seconds"]):
        if c.isspace():
            if w: words.append((w, ws)); w = ""
        else:
            if not w: ws = t
            w += c
    if w: words.append((w, ws))
    voice = float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", f"voice/{s}.mp3"]))
    lead = HEAD if i == 0 else LEAD
    tail = END if i == len(lines) - 1 else HOLD
    length = math.ceil((lead + voice + tail) * FPS) / FPS
    cues = [["".join(ch for ch in w.lower() if ch.isalnum() or ch == "'"), round(lead + t, 3), w] for w, t in words]
    open(f"cues/{s}.js", "w").write(
        f"// Generated: narration word start times in scene seconds (lead {lead}s). Do not edit.\n"
        f"window.NARRATION = {json.dumps({'scene': s, 'title': l['title'], 'length': length, 'voiceStart': lead, 'voiceEnd': round(lead + voice, 3), 'text': l['text'], 'words': cues})};\n")
    plan.append({"scene": s, "title": l["title"], "length": length, "voice": voice, "lead": lead})
json.dump(plan, open("plan.json", "w"), indent=1)
print(round(sum(p["length"] for p in plan), 2))
