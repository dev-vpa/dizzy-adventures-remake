#!/usr/bin/env python3
"""Original animated egg hero: bold gloves, boots, face, and tumbling poses.

Authored on a 44×56 logical grid, drawn native at 88×112 for the 1024×768 viewport.
"""
from __future__ import annotations

from PIL import Image

from ti_art_lib import (
	BOOT,
	BOOT_DK,
	BOOT_HI,
	EGG,
	EGG_EDGE,
	EGG_HI,
	EGG_SH,
	GLOVE,
	GLOVE_HI,
	GLOVE_SH,
	INK_BLUE,
	REPO_ROOT,
	SMILE,
	fill_ellipse,
	fill_rect,
	logical_canvas,
	outline,
	paint_scale,
	pixel_line,
	px,
	save,
)

DIZZY = REPO_ROOT / "shared/sprites/dizzy"
SRC_W, SRC_H = 44, 56
NATIVE_SCALE = 2  # Native export 88×112.


def blank() -> Image.Image:
	return logical_canvas(SRC_W, SRC_H)


def _eye(im: Image.Image, x: int, y: int, look: int = 0) -> None:
	"""Calm 9×7 stepped oval eye with a directional pupil (2× classic eye)."""
	look = max(-1, min(1, int(look)))
	# White oval
	fill_rect(im, x + 2, y, x + 6, y, (248, 248, 252))
	fill_rect(im, x + 1, y + 1, x + 7, y + 4, (248, 248, 252))
	fill_rect(im, x + 2, y + 5, x + 6, y + 6, (248, 248, 252))
	# Soft inner highlight
	fill_rect(im, x + 2, y + 2, x + 6, y + 4, GLOVE_HI)
	# Pupil + tiny gleam
	pupil_x = x + 4 + look * 2
	fill_rect(im, pupil_x, y + 2, pupil_x + 1, y + 4, INK_BLUE)
	px(im, pupil_x, y + 2, (40, 48, 72))
	px(im, pupil_x + 1, y + 3, GLOVE_HI)


def _egg_layer(
	cx: float = 21.0,
	cy: float = 23.0,
	rx: float = 14.4,
	ry: float = 19.2,
) -> Image.Image:
	layer = blank()
	for y in range(SRC_H):
		for x in range(SRC_W):
			nx = (x - cx) / rx
			ny = (y - cy) / ry
			distance = nx * nx + ny * ny
			if distance > 1.0:
				continue
			color = EGG
			if x <= cx - 8 or y >= cy + 12:
				color = EGG_SH
			elif x >= cx + 4 and y <= cy - 4:
				color = EGG_HI
			# Soft mid-tone band for roundness at the finer grid.
			elif distance > 0.72 and x < cx:
				color = EGG_SH
			elif distance < 0.18 and x > cx and y < cy:
				color = EGG_HI
			px(layer, x, y, color)
	# Glossy reflective clusters (palette-limited).
	px(layer, int(cx + 6), int(cy - 12), GLOVE_HI)
	px(layer, int(cx + 7), int(cy - 11), EGG_HI)
	px(layer, int(cx + 5), int(cy - 10), EGG_HI)
	px(layer, int(cx - 8), int(cy + 8), EGG_SH)
	px(layer, int(cx - 7), int(cy + 9), EGG_SH)
	outline(layer, EGG_EDGE, diagonal=False)
	return layer


def body(
	im: Image.Image,
	y_off: int = 0,
	rx: float = 14.4,
	ry: float = 19.2,
	cy: float = 23.0,
) -> None:
	im.alpha_composite(_egg_layer(21.0, cy + y_off, rx, ry))


def face_three_quarter(im: Image.Image, y_off: int = 0) -> None:
	"""Author the hero facing right; runtime mirroring supplies the left pose."""
	_eye(im, 12, 14 + y_off, look=1)
	_eye(im, 24, 14 + y_off, look=1)
	# Soft cheek / nose profile
	fill_rect(im, 32, 24 + y_off, 34, 26 + y_off, EGG_EDGE)
	px(im, 32, 24 + y_off, EGG_HI)
	px(im, 33, 24 + y_off, EGG_HI)
	px(im, 30, 26 + y_off, (235, 105, 70))
	px(im, 31, 26 + y_off, (235, 105, 70))
	# Smile curve
	for x, y in [
		(18, 28),
		(19, 29),
		(20, 30),
		(21, 31),
		(22, 32),
		(23, 32),
		(24, 32),
		(25, 31),
		(26, 30),
		(27, 29),
		(28, 28),
	]:
		px(im, x, y + y_off, SMILE)
	px(im, 22, 30 + y_off, (244, 92, 66))
	px(im, 23, 30 + y_off, (244, 92, 66))
	px(im, 24, 30 + y_off, (244, 92, 66))
	px(im, 22, 31 + y_off, (244, 92, 66))
	px(im, 23, 31 + y_off, (244, 92, 66))


def arm(im: Image.Image, start: tuple[int, int], end: tuple[int, int]) -> None:
	pixel_line(im, [start, end], EGG_EDGE, 5)
	pixel_line(im, [start, end], EGG, 2)


def glove(im: Image.Image, cx: int, cy: int, facing: int) -> None:
	layer = blank()
	fill_ellipse(layer, (cx - 4, cy - 4, cx + 4, cy + 4), GLOVE)
	fill_rect(layer, cx - 2, cy - 4, cx + 2, cy - 2, GLOVE_HI)
	# Finger tips — mitten read, not a white bar.
	for offset in (-2, 0, 2):
		px(layer, cx + facing * 4, cy + offset, GLOVE_SH if offset == 2 else GLOVE)
		px(layer, cx + facing * 3, cy + offset, GLOVE)
	outline(layer, INK_BLUE, diagonal=False)
	im.alpha_composite(layer)


def boot(im: Image.Image, ankle_x: int, y: int, direction: int) -> None:
	layer = blank()
	fill_rect(layer, ankle_x - 2, y, ankle_x + 2, y + 4, BOOT)
	if direction > 0:
		fill_rect(layer, ankle_x, y + 2, ankle_x + 8, y + 6, BOOT)
		fill_rect(layer, ankle_x + 2, y + 2, ankle_x + 6, y + 2, BOOT_HI)
		fill_rect(layer, ankle_x + 2, y + 6, ankle_x + 8, y + 6, BOOT_DK)
	else:
		fill_rect(layer, ankle_x - 8, y + 2, ankle_x, y + 6, BOOT)
		fill_rect(layer, ankle_x - 6, y + 2, ankle_x - 2, y + 2, BOOT_HI)
		fill_rect(layer, ankle_x - 8, y + 6, ankle_x - 2, y + 6, BOOT_DK)
	outline(layer, BOOT_DK, diagonal=False)
	im.alpha_composite(layer)


def _standing_pose(
	left_hand: tuple[int, int],
	right_hand: tuple[int, int],
	left_boot: tuple[int, int, int],
	right_boot: tuple[int, int, int],
	y_off: int = 0,
) -> Image.Image:
	im = blank()
	# In this right-facing three-quarter pose the screen-right arm is farther
	# from the viewer, so its shoulder disappears behind the shell. Mirroring
	# preserves the same depth order when Dizzy faces left.
	arm(im, (34, 26 + y_off), right_hand)
	glove(im, *right_hand, 1)
	body(im, y_off)
	face_three_quarter(im, y_off)
	arm(im, (8, 26 + y_off), left_hand)
	glove(im, *left_hand, -1)
	boot(im, *left_boot)
	boot(im, *right_boot)
	return im


def jump_pose() -> Image.Image:
	im = blank()
	body(im, -4)
	face_three_quarter(im, -4)
	arm(im, (10, 20), (4, 12))
	arm(im, (32, 20), (38, 12))
	glove(im, 4, 12, -1)
	glove(im, 38, 12, 1)
	pixel_line(im, [(16, 36), (14, 40)], EGG_EDGE, 4)
	pixel_line(im, [(26, 36), (28, 40)], EGG_EDGE, 4)
	boot(im, 14, 40, 1)
	boot(im, 28, 40, 1)
	return im


def roll_pose(frame: int) -> Image.Image:
	"""Upright authored pose; the Godot renderer rotates the complete character."""
	im = blank()
	body(im, -2)
	face_three_quarter(im, -2)
	if frame == 0:
		arm(im, (8, 24), (4, 14))
		arm(im, (34, 24), (38, 34))
		glove(im, 4, 14, -1)
		glove(im, 38, 34, 1)
		pixel_line(im, [(16, 36), (12, 42)], EGG_EDGE, 4)
		pixel_line(im, [(26, 36), (30, 42)], EGG_EDGE, 4)
		boot(im, 12, 42, -1)
		boot(im, 30, 42, 1)
	else:
		arm(im, (8, 24), (4, 34))
		arm(im, (34, 24), (38, 14))
		glove(im, 4, 34, -1)
		glove(im, 38, 14, 1)
		pixel_line(im, [(16, 36), (16, 40)], EGG_EDGE, 4)
		pixel_line(im, [(26, 36), (26, 40)], EGG_EDGE, 4)
		boot(im, 16, 40, 1)
		boot(im, 26, 40, -1)
	return im


def export(name: str, im: Image.Image) -> None:
	save(im, DIZZY / f"{name}.png")


def main() -> None:
	DIZZY.mkdir(parents=True, exist_ok=True)
	with paint_scale(NATIVE_SCALE):
		frames = {
			"idle": _standing_pose((4, 32), (38, 32), (14, 44, 1), (28, 44, 1)),
			"walk_a": _standing_pose((4, 24), (38, 34), (12, 44, 1), (28, 46, 1), -2),
			"walk_b": _standing_pose((4, 34), (38, 24), (14, 46, 1), (30, 44, 1)),
			"jump": jump_pose(),
			"roll_a": roll_pose(0),
			"roll_b": roll_pose(1),
		}
		for name, frame in frames.items():
			export(name, frame)
	print("dizzy done")


if __name__ == "__main__":
	main()
