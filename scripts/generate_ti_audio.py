#!/usr/bin/env python3
"""Generate original TI SFX + looping BGM (WAV, CC BY-NC)."""
from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

SFX = Path("shared/audio/sfx")
BGM = Path("games/treasure-island/audio")
RATE = 22050


def write_wav(path: Path, samples: list[float], rate: int = RATE) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	with wave.open(str(path), "w") as w:
		w.setnchannels(1)
		w.setsampwidth(2)
		w.setframerate(rate)
		frames = bytearray()
		for s in samples:
			v = max(-1.0, min(1.0, s))
			frames += struct.pack("<h", int(v * 32767))
		w.writeframes(frames)
	print("wrote", path, len(samples) / rate, "s")


def tone(
	freq: float,
	dur: float,
	vol: float = 0.35,
	wave_kind: str = "square",
	decay: bool = True,
) -> list[float]:
	n = int(RATE * dur)
	out: list[float] = []
	for i in range(n):
		t = i / RATE
		phase = 2.0 * math.pi * freq * t
		if wave_kind == "sine":
			v = math.sin(phase)
		elif wave_kind == "tri":
			v = 2.0 * abs(2.0 * ((t * freq) % 1.0) - 1.0) - 1.0
		else:
			v = 1.0 if math.sin(phase) >= 0.0 else -1.0
		env = 1.0
		if decay:
			env = max(0.0, 1.0 - t / dur)
		out.append(v * vol * env)
	return out


def silence(dur: float) -> list[float]:
	return [0.0] * int(RATE * dur)


def concat(*parts: list[float]) -> list[float]:
	out: list[float] = []
	for p in parts:
		out.extend(p)
	return out


def main() -> None:
	SFX.mkdir(parents=True, exist_ok=True)
	BGM.mkdir(parents=True, exist_ok=True)

	write_wav(SFX / "jump.wav", tone(520, 0.08, 0.28, "square"))
	write_wav(
		SFX / "pickup.wav",
		concat(tone(660, 0.06, 0.3, "sine"), tone(880, 0.08, 0.28, "sine")),
	)
	write_wav(SFX / "drop.wav", tone(220, 0.1, 0.25, "tri"))
	write_wav(
		SFX / "use.wav",
		concat(tone(400, 0.05, 0.28, "square"), tone(600, 0.07, 0.28, "square")),
	)
	write_wav(
		SFX / "death.wav",
		concat(tone(180, 0.15, 0.35, "square"), tone(90, 0.25, 0.3, "tri")),
	)
	write_wav(
		SFX / "win.wav",
		concat(
			tone(523, 0.12, 0.3, "sine"),
			tone(659, 0.12, 0.3, "sine"),
			tone(784, 0.18, 0.32, "sine"),
			tone(1046, 0.28, 0.28, "sine"),
		),
	)
	write_wav(SFX / "ui_click.wav", tone(740, 0.04, 0.22, "sine", decay=True))

	# Short cozy chiptune loop (~8s) — C major arpeggio + bass
	melody_notes = [
		(261.63, 0.22),
		(329.63, 0.22),
		(392.00, 0.22),
		(523.25, 0.22),
		(392.00, 0.22),
		(329.63, 0.22),
		(293.66, 0.22),
		(329.63, 0.22),
		(349.23, 0.22),
		(392.00, 0.22),
		(440.00, 0.22),
		(523.25, 0.44),
		(440.00, 0.22),
		(392.00, 0.22),
		(349.23, 0.22),
		(329.63, 0.44),
	]
	bass_notes = [
		(130.81, 0.44),
		(146.83, 0.44),
		(164.81, 0.44),
		(174.61, 0.44),
		(130.81, 0.44),
		(196.00, 0.44),
		(174.61, 0.44),
		(146.83, 0.44),
	]
	mel: list[float] = []
	for freq, dur in melody_notes:
		mel.extend(tone(freq, dur, 0.18, "square", decay=True))
		mel.extend(silence(0.02))
	bass: list[float] = []
	for freq, dur in bass_notes:
		bass.extend(tone(freq, dur, 0.12, "tri", decay=False))
	# Align lengths
	n = max(len(mel), len(bass))
	mel.extend([0.0] * (n - len(mel)))
	bass.extend([0.0] * (n - len(bass)))
	mix = [m + b for m, b in zip(mel, bass)]
	# Soft fade ends for loop seam
	fade = int(RATE * 0.05)
	for i in range(fade):
		k = i / fade
		mix[i] *= k
		mix[-(i + 1)] *= k
	write_wav(BGM / "theme.wav", mix)
	print("audio generation complete")


if __name__ == "__main__":
	main()
