#!/usr/bin/env python3
"""Original animated egg hero: bold gloves, boots, face, and tumbling poses."""
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
	new_canvas,
	outline,
	pixel_eye,
	pixel_line,
	px,
	save,
	upscale_nearest,
)

DIZZY = REPO_ROOT / "shared/sprites/dizzy"
SRC_W, SRC_H = 22, 28
SCALE = 2  # 44×56: original-like proportions in the doubled 512×384 viewport.


def blank() -> Image.Image:
	return new_canvas(SRC_W, SRC_H)


def _egg_layer(
	cx: float = 10.5,
	cy: float = 11.5,
	rx: float = 7.2,
	ry: float = 9.6,
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
			if x <= cx - 4 or y >= cy + 6:
				color = EGG_SH
			elif x >= cx + 2 and y <= cy - 2:
				color = EGG_HI
			px(layer, x, y, color)
	# Hand-placed reflective clusters keep the shell glossy but palette-limited.
	px(layer, int(cx + 3), int(cy - 6), GLOVE_HI)
	px(layer, int(cx + 4), int(cy - 5), EGG_HI)
	px(layer, int(cx - 4), int(cy + 4), EGG_SH)
	outline(layer, EGG_EDGE, diagonal=False)
	return layer


def body(
	im: Image.Image,
	y_off: int = 0,
	rx: float = 7.2,
	ry: float = 9.6,
	cy: float = 11.5,
) -> None:
	im.alpha_composite(_egg_layer(10.5, cy + y_off, rx, ry))


def face_three_quarter(im: Image.Image, y_off: int = 0) -> None:
	"""Author the hero facing right; runtime mirroring supplies the left pose."""
	# Equal oval eyes avoid the old bar-like face. Pupils and a small profile
	# nose carry direction, then runtime mirroring supplies a true left gaze.
	pixel_eye(im, 5, 6 + y_off, look=1)
	pixel_eye(im, 11, 6 + y_off, look=1)
	fill_rect(im, 16, 12 + y_off, 17, 13 + y_off, EGG_EDGE)
	px(im, 16, 12 + y_off, EGG_HI)
	px(im, 15, 13 + y_off, (235, 105, 70))
	for x, y in [(9, 14), (10, 15), (11, 16), (12, 16), (13, 16), (14, 15), (15, 14)]:
		px(im, x, y + y_off, SMILE)
	px(im, 12, 15 + y_off, (244, 92, 66))


def arm(im: Image.Image, start: tuple[int, int], end: tuple[int, int]) -> None:
	pixel_line(im, [start, end], EGG_EDGE, 3)
	pixel_line(im, [start, end], EGG, 1)


def glove(im: Image.Image, cx: int, cy: int, facing: int) -> None:
	layer = blank()
	fill_ellipse(layer, (cx - 2, cy - 2, cx + 2, cy + 2), GLOVE)
	fill_rect(layer, cx - 1, cy - 2, cx + 1, cy - 1, GLOVE_HI)
	# Three tiny finger tips give the hand a mitten/glove read, not a white bar.
	for offset in (-1, 0, 1):
		px(layer, cx + facing * 2, cy + offset, GLOVE_SH if offset == 1 else GLOVE)
	outline(layer, INK_BLUE, diagonal=False)
	im.alpha_composite(layer)


def boot(im: Image.Image, ankle_x: int, y: int, direction: int) -> None:
	layer = blank()
	fill_rect(layer, ankle_x - 1, y, ankle_x + 1, y + 2, BOOT)
	if direction > 0:
		fill_rect(layer, ankle_x, y + 1, ankle_x + 4, y + 3, BOOT)
		fill_rect(layer, ankle_x + 1, y + 1, ankle_x + 3, y + 1, BOOT_HI)
		fill_rect(layer, ankle_x + 1, y + 3, ankle_x + 4, y + 3, BOOT_DK)
	else:
		fill_rect(layer, ankle_x - 4, y + 1, ankle_x, y + 3, BOOT)
		fill_rect(layer, ankle_x - 3, y + 1, ankle_x - 1, y + 1, BOOT_HI)
		fill_rect(layer, ankle_x - 4, y + 3, ankle_x - 1, y + 3, BOOT_DK)
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
	body(im, y_off)
	face_three_quarter(im, y_off)
	arm(im, (4, 13 + y_off), left_hand)
	arm(im, (17, 13 + y_off), right_hand)
	glove(im, *left_hand, -1)
	glove(im, *right_hand, 1)
	boot(im, *left_boot)
	boot(im, *right_boot)
	return im


def jump_pose() -> Image.Image:
	im = blank()
	body(im, -2)
	face_three_quarter(im, -2)
	arm(im, (5, 10), (2, 6))
	arm(im, (16, 10), (19, 6))
	glove(im, 2, 6, -1)
	glove(im, 19, 6, 1)
	# Knees and feet pull inward, making the airborne silhouette unmistakable.
	pixel_line(im, [(8, 18), (7, 20)], EGG_EDGE, 2)
	pixel_line(im, [(13, 18), (14, 20)], EGG_EDGE, 2)
	boot(im, 7, 20, 1)
	boot(im, 14, 20, 1)
	return im


def roll_pose(frame: int) -> Image.Image:
	"""Upright authored pose; the Godot renderer rotates the complete character."""
	im = blank()
	body(im, -1)
	face_three_quarter(im, -1)
	if frame == 0:
		# Wide opposing limbs make the silhouette readable while it rotates.
		arm(im, (4, 12), (2, 7))
		arm(im, (17, 12), (19, 17))
		glove(im, 2, 7, -1)
		glove(im, 19, 17, 1)
		pixel_line(im, [(8, 18), (6, 21)], EGG_EDGE, 2)
		pixel_line(im, [(13, 18), (15, 21)], EGG_EDGE, 2)
		boot(im, 6, 21, -1)
		boot(im, 15, 21, 1)
	else:
		arm(im, (4, 12), (2, 17))
		arm(im, (17, 12), (19, 7))
		glove(im, 2, 17, -1)
		glove(im, 19, 7, 1)
		# A tucked second pose gives the spin life without changing its centre.
		pixel_line(im, [(8, 18), (8, 20)], EGG_EDGE, 2)
		pixel_line(im, [(13, 18), (13, 20)], EGG_EDGE, 2)
		boot(im, 8, 20, 1)
		boot(im, 13, 20, -1)
	return im


def export(name: str, im: Image.Image) -> None:
	save(upscale_nearest(im, SCALE), DIZZY / f"{name}.png")


def main() -> None:
	DIZZY.mkdir(parents=True, exist_ok=True)
	frames = {
		"idle": _standing_pose((2, 16), (19, 16), (7, 22, 1), (14, 22, 1)),
		"walk_a": _standing_pose((2, 12), (19, 17), (6, 22, 1), (14, 23, 1), -1),
		"walk_b": _standing_pose((2, 17), (19, 12), (7, 23, 1), (15, 22, 1)),
		"jump": jump_pose(),
		"roll_a": roll_pose(0),
		"roll_b": roll_pose(1),
	}
	for name, frame in frames.items():
		export(name, frame)
	print("dizzy done")


if __name__ == "__main__":
	main()
