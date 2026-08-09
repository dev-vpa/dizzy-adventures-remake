#!/usr/bin/env python3
"""Original homage Dizzy frames — egg hero, not a Codemasters rip."""
from __future__ import annotations

from pathlib import Path

from PIL import Image

from ti_art_lib import (
	REPO_ROOT,
	BOOT,
	BOOT_HI,
	EGG,
	EGG_HI,
	EGG_SH,
	EYE,
	GLOVE,
	SMILE,
	px,
	save,
)

DIZZY = REPO_ROOT / "shared/sprites/dizzy"
SRC_W, SRC_H = 20, 26
SCALE = 3  # -> 60×78


def blank() -> Image.Image:
	return Image.new("RGBA", (SRC_W, SRC_H), (0, 0, 0, 0))


def egg_body(im: Image.Image, y_off: int = 0) -> None:
	# soft oval body
	for y in range(4 + y_off, 20 + y_off):
		for x in range(3, 17):
			cx, cy = 9.5, 11.5 + y_off
			nx = (x - cx) / 6.8
			ny = (y - cy) / 8.2
			if nx * nx + ny * ny <= 1.0:
				if x <= 6:
					c = EGG_SH
				elif x >= 13:
					c = EGG_HI
				else:
					c = EGG
				px(im, x, y, c)
	# highlight
	for y in range(6 + y_off, 10 + y_off):
		for x in range(11, 15):
			if im.getpixel((x, y))[3]:
				px(im, x, y, EGG_HI)


def face(im: Image.Image, y_off: int = 0) -> None:
	# eyes
	px(im, 7, 10 + y_off, EYE)
	px(im, 8, 10 + y_off, EYE)
	px(im, 11, 10 + y_off, EYE)
	px(im, 12, 10 + y_off, EYE)
	# brows
	px(im, 7, 9 + y_off, EGG_SH)
	px(im, 12, 9 + y_off, EGG_SH)
	# smile
	px(im, 8, 13 + y_off, SMILE)
	px(im, 9, 14 + y_off, SMILE)
	px(im, 10, 14 + y_off, SMILE)
	px(im, 11, 13 + y_off, SMILE)


def gloves(im: Image.Image, left: int, right: int, y: int) -> None:
	for x in range(left, left + 3):
		for dy in range(2):
			px(im, x, y + dy, GLOVE)
	for x in range(right, right + 3):
		for dy in range(2):
			px(im, x, y + dy, GLOVE)


def boots(im: Image.Image, l: int, r: int, y: int) -> None:
	for x in range(l, l + 4):
		px(im, x, y, BOOT)
		px(im, x, y + 1, BOOT_HI if x < l + 2 else BOOT)
	for x in range(r, r + 4):
		px(im, x, y, BOOT)
		px(im, x, y + 1, BOOT_HI if x < r + 2 else BOOT)


def frame_idle() -> Image.Image:
	im = blank()
	egg_body(im)
	face(im)
	gloves(im, 1, 16, 14)
	boots(im, 5, 11, 21)
	return im


def frame_walk(phase: int) -> Image.Image:
	im = blank()
	egg_body(im, 0)
	face(im)
	if phase == 0:
		gloves(im, 2, 15, 13)
		boots(im, 4, 12, 21)
		# trailing boot lift
		px(im, 12, 20, BOOT)
		px(im, 13, 20, BOOT)
	else:
		gloves(im, 1, 16, 15)
		boots(im, 6, 10, 21)
		px(im, 5, 20, BOOT)
		px(im, 6, 20, BOOT)
	return im


def frame_jump() -> Image.Image:
	im = blank()
	egg_body(im, -1)
	face(im, -1)
	gloves(im, 2, 15, 11)
	# tucked boots
	boots(im, 6, 10, 18)
	return im


def frame_roll(phase: int) -> Image.Image:
	im = blank()
	# more circular / sideways egg
	for y in range(6, 20):
		for x in range(2, 18):
			cx, cy = 9.5, 13.0
			nx = (x - cx) / 7.5
			ny = (y - cy) / 6.5
			if nx * nx + ny * ny <= 1.0:
				c = EGG_HI if (phase == 0 and y < 10) or (phase == 1 and y > 15) else EGG
				if x < 5:
					c = EGG_SH
				px(im, x, y, c)
	# eye streak
	for x in range(6, 14):
		px(im, x, 12 + phase, EYE)
	# boot flash
	if phase == 0:
		boots(im, 14, 14, 14)
	else:
		gloves(im, 1, 1, 12)
	return im


def export(name: str, im: Image.Image) -> None:
	out = im.resize((SRC_W * SCALE, SRC_H * SCALE), Image.NEAREST)
	save(out, DIZZY / f"{name}.png")


def main() -> None:
	DIZZY.mkdir(parents=True, exist_ok=True)
	export("idle", frame_idle())
	export("walk_a", frame_walk(0))
	export("walk_b", frame_walk(1))
	export("jump", frame_jump())
	export("roll_a", frame_roll(0))
	export("roll_b", frame_roll(1))
	print("dizzy done")


if __name__ == "__main__":
	main()
