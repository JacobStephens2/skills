"""Assemble the clarity cut from out/NN.mp4 and voice/NN.mp3.

Writes final/explainer.mp4 (narration; music only in the unnarrated head and tail),
final/explainer.vtt (captions from the narration's word timings), and final/index.html
(a <video controls> player with the captions as a toggleable track).
"""
import json, os, re, subprocess

here = os.path.dirname(os.path.abspath(__file__))
os.chdir(here)
plan = json.load(open("plan.json"))
music = os.path.join(here, "music.wav")  # from music.py

# The narration spells numbers and initialisms for the voice; captions show the written form.
# Each pair is applied to every caption's text, e.g. ("T D D", "TDD"), ("seven ninety-four", "#794").
CAPTION_FIXES = []
# Spoken phrases whose full stop is not a sentence end, so no caption breaks inside them, e.g. "a.m. Eastern".
NO_BREAK = []

def run(*args):
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", *args], check=True)

t = 0.0
for p in plan:
    p["start"] = t
    t += p["length"]
total = t

with open("final/concat.txt", "w") as f:
    for p in plan:
        f.write(f"file '{here}/out/{p['scene']}.mp4'\n")
run("-f", "concat", "-safe", "0", "-i", "final/concat.txt", "-c", "copy", "final/silent.mp4")

inputs, filters = [], []
for n, p in enumerate(plan):
    inputs += ["-i", f"voice/{p['scene']}.mp3"]
    ms = round((p["start"] + p["lead"]) * 1000)
    filters.append(f"[{n}]aresample=48000,pan=stereo|c0=c0|c1=c0,adelay={ms}|{ms}[v{n}]")
m = len(plan)
inputs += ["-i", music]
head_end = plan[0]["lead"]
last = plan[-1]
tail_start = last["start"] + last["lead"] + last["voice"] + 0.3
tail_len = total - tail_start
filters.append(f"[{m}]asplit[mh][mt]")
filters.append(f"[mh]atrim=0:{head_end:.3f},afade=t=out:st={head_end - 1.0:.3f}:d=1.0,aresample=48000,volume=-4dB[head]")
ms = round(tail_start * 1000)
filters.append(f"[mt]atrim=24:{24 + tail_len:.3f},asetpts=PTS-STARTPTS,afade=t=in:d=0.8,afade=t=out:st={tail_len - 1.5:.3f}:d=1.5,"
               f"aresample=48000,volume=-4dB,adelay={ms}|{ms}[tail]")
mix = "".join(f"[v{n}]" for n in range(m)) + "[head][tail]"
filters.append(f"{mix}amix=inputs={m + 2}:normalize=0:duration=longest,apad,atrim=0:{total:.3f},loudnorm=I=-16:TP=-1.5:LRA=11[a]")
run(*inputs, "-filter_complex", ";".join(filters), "-map", "[a]", "-ar", "48000", "-c:a", "pcm_s16le", "final/audio.wav")
run("-i", "final/silent.mp4", "-i", "final/audio.wav", "-map", "0:v", "-map", "1:a", "-c:v", "copy", "-c:a", "aac", "-b:a", "192k",
    "-movflags", "+faststart", "-shortest", "final/explainer.mp4")

# Captions: one cue per sentence (or clause, past ~84 characters), timed from the word starts.
def stamp(s):
    h, s = divmod(s, 3600); m, s = divmod(s, 60)
    return f"{int(h):02d}:{int(m):02d}:{s:06.3f}"

vtt = ["WEBVTT", ""]
for p in plan:
    a = json.load(open(f"voice/{p['scene']}.json"))["alignment"]
    chars, starts, ends = a["characters"], a["character_start_times_seconds"], a["character_end_times_seconds"]
    off = p["start"] + p["lead"]
    spoken = "".join(chars)
    keep = {m.start() + j for phrase in NO_BREAK for m in re.finditer(re.escape(phrase), spoken)
            for j, ch in enumerate(phrase[:-1]) if ch in ".?!"}
    buf, b0 = "", None
    for i, c in enumerate(chars):
        if b0 is None and not c.isspace():
            b0 = starts[i]
        buf += c
        stop = c in ".?!" and i not in keep and (i + 1 == len(chars) or chars[i + 1].isspace())
        soft = c in ",:" and len(buf.strip()) > 84 - 30 and (i + 1 == len(chars) or chars[i + 1].isspace())
        if stop or soft or i + 1 == len(chars):
            text = buf.strip()
            for spoken_form, written in CAPTION_FIXES:
                text = text.replace(spoken_form, written)
            if text:
                words, lines, line = text.split(), [], ""
                for w in words:  # wrap to two lines of at most ~42 characters
                    if line and len(line) + 1 + len(w) > 42:
                        lines.append(line); line = w
                    else:
                        line = f"{line} {w}".strip()
                lines.append(line)
                vtt += [f"{stamp(off + b0)} --> {stamp(off + ends[i] + 0.25)}", *lines, ""]
            buf, b0 = "", None
open("final/explainer.vtt", "w").write("\n".join(vtt))

open("final/index.html", "w").write("""<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1"><title>Explainer</title>
<style>body{margin:0;background:#0F1115;display:grid;place-items:center;min-height:100vh}
video{width:min(100vw,1600px);max-height:100vh;background:#000}</style></head><body>
<video controls preload="metadata" poster="poster.jpg" src="explainer.mp4">
  <track kind="captions" srclang="en" label="English" src="explainer.vtt">
</video></body></html>
""")
print(f"final/explainer.mp4 {total:.2f}s; captions {sum(1 for l in vtt if '-->' in l)} cues")
