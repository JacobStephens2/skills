#!/usr/bin/env python3
"""Generate a calm, nocturnal 60-second background bed for a captioned explainer.

Standard library only (wave, math, struct). Output: music.wav
44.1 kHz / 16-bit / stereo / exactly 60.000 s, peaks near 25% of full scale.
"""

import math
import os
import struct
import wave

SR = 44100
DURATION = 60.0
TOTAL = int(round(SR * DURATION))
BPM = 80.0
BEAT = 60.0 / BPM          # 0.75 s
CHORD_BEATS = 8            # 6 s per chord
LOOP = 4 * CHORD_BEATS * BEAT  # 24 s per loop
TARGET_PEAK = 0.25

NOTE_NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]


def hz(name, octave):
    """Equal-temperament frequency, A4 = 440 Hz."""
    midi = 12 * (octave + 1) + NOTE_NAMES.index(name)
    return 440.0 * 2.0 ** ((midi - 69) / 12.0)


# Am7 - Fmaj7 - Cmaj7 - Em7 (A minor): soft, unresolved, nocturnal.
PROGRESSION = [
    ("Am7", ("A", 2), [("A", 3), ("C", 4), ("E", 4), ("G", 4)]),
    ("Fmaj7", ("F", 2), [("F", 3), ("A", 3), ("C", 4), ("E", 4)]),
    ("Cmaj7", ("C", 2), [("E", 3), ("G", 3), ("B", 3), ("C", 4)]),
    ("Em7", ("E", 2), [("E", 3), ("G", 3), ("B", 3), ("D", 4)]),
]


def env(t, dur, attack, release):
    """Short attack / release envelope so notes never click."""
    if t < 0.0 or t > dur:
        return 0.0
    if t < attack:
        x = t / attack
    elif t > dur - release:
        x = (dur - t) / release
    else:
        return 1.0
    # raised cosine for smooth ends
    return 0.5 - 0.5 * math.cos(math.pi * max(0.0, min(1.0, x)))


def triangle(phase):
    """Band-limited-ish triangle: odd harmonics at 1/n^2, soft and warm."""
    return (
        math.sin(phase)
        - math.sin(3 * phase) / 9.0
        + math.sin(5 * phase) / 25.0
        - math.sin(7 * phase) / 49.0
    )


left = [0.0] * TOTAL
right = [0.0] * TOTAL


def add(freq, start, dur, amp, pan=0.5, wave_fn=math.sin,
        attack=0.05, release=None, detune=0.0, vib=0.0):
    """Mix one note into the buffers."""
    if release is None:
        release = min(0.35, dur * 0.5)
    attack = min(attack, dur * 0.45)
    release = min(release, dur * 0.5)
    i0 = int(start * SR)
    n = int(dur * SR)
    if i0 >= TOTAL:
        return
    w = 2.0 * math.pi * freq
    wl = 2.0 * math.pi * (freq * (1.0 - detune))
    wr = 2.0 * math.pi * (freq * (1.0 + detune))
    gl = amp * math.sqrt(1.0 - pan)
    gr = amp * math.sqrt(pan)
    for k in range(n):
        i = i0 + k
        if i >= TOTAL:
            break
        t = k / SR
        e = env(t, dur, attack, release)
        if e <= 0.0:
            continue
        # slow vibrato keeps sustained pads from sounding frozen
        m = vib * math.sin(2.0 * math.pi * 0.17 * (start + t)) if vib else 0.0
        if detune:
            left[i] += gl * e * wave_fn(wl * t + m)
            right[i] += gr * e * wave_fn(wr * t - m)
        else:
            s = e * wave_fn(w * t + m)
            left[i] += gl * s
            right[i] += gr * s


n_chords = int(math.ceil(DURATION / (CHORD_BEATS * BEAT))) + 1

for ci in range(n_chords):
    start = ci * CHORD_BEATS * BEAT
    if start >= DURATION:
        break
    name, bass, voices = PROGRESSION[ci % 4]
    loop_index = int(start // LOOP)
    chord_dur = min(CHORD_BEATS * BEAT, DURATION - start)

    # --- pad: sustained chord, sine tones, gently spread across the stereo field
    for vi, (nm, oc) in enumerate(voices):
        pan = 0.18 + 0.64 * (vi / max(1, len(voices) - 1))
        add(hz(nm, oc), start, chord_dur + 0.4, 0.085, pan=pan,
            wave_fn=math.sin, attack=0.7, release=1.0, detune=0.0012, vib=0.004)

    # --- light pulse on the beat (soft triangle blip, low in the mix)
    for b in range(CHORD_BEATS):
        bt = start + b * BEAT
        if bt >= DURATION:
            break
        accent = 1.0 if b % 4 == 0 else 0.62
        add(hz("A", 5), bt, 0.16, 0.030 * accent, pan=0.5,
            wave_fn=triangle, attack=0.012, release=0.14)

    # --- evolution: soft bass enters after the first loop
    if loop_index >= 1:
        bn, bo = bass
        add(hz(bn, bo), start, chord_dur + 0.3, 0.090, pan=0.5,
            wave_fn=math.sin, attack=0.25, release=0.8, vib=0.002)

    # --- evolution: sparse arpeggio joins in the second loop onward
    if loop_index >= 1:
        order = [0, 2, 1, 3, 2, 3, 1, 2]
        for b in range(CHORD_BEATS):
            bt = start + b * BEAT
            if bt >= DURATION:
                break
            nm, oc = voices[order[b % len(order)]]
            pan = 0.32 if b % 2 == 0 else 0.68
            add(hz(nm, oc + 1), bt, 0.52,
                0.040 * (0.8 if loop_index == 1 else 1.0), pan=pan,
                wave_fn=triangle, attack=0.03, release=0.34)


# --- global fades: 1 s in, 2 s out
fade_in = int(1.0 * SR)
fade_out = int(2.0 * SR)
for i in range(fade_in):
    g = 0.5 - 0.5 * math.cos(math.pi * i / fade_in)
    left[i] *= g
    right[i] *= g
for k in range(fade_out):
    i = TOTAL - 1 - k
    g = 0.5 - 0.5 * math.cos(math.pi * k / fade_out)
    left[i] *= g
    right[i] *= g

# --- normalize to the target peak (about a quarter of full scale)
peak = max(max(abs(v) for v in left), max(abs(v) for v in right))
gain = (TARGET_PEAK / peak) if peak > 0 else 1.0

out = bytearray()
full = 32767
for i in range(TOTAL):
    l = int(round(max(-1.0, min(1.0, left[i] * gain)) * full))
    r = int(round(max(-1.0, min(1.0, right[i] * gain)) * full))
    out += struct.pack("<hh", l, r)

path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "music.wav")
with wave.open(path, "wb") as w:
    w.setnchannels(2)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(bytes(out))

print("wrote %s" % path)
print("frames=%d duration=%.3fs peak=%.4f (%.1f dBFS)"
      % (TOTAL, TOTAL / SR, TARGET_PEAK, 20 * math.log10(TARGET_PEAK)))
print("progression: Am7 - Fmaj7 - Cmaj7 - Em7 @ %.0f BPM (%.0fs loop)"
      % (BPM, LOOP))
