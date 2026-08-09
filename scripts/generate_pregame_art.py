#!/usr/bin/env python3
"""Generate original pixel art for menus, boot splash, and game selection."""
from __future__ import annotations

import random
from collections.abc import Sequence

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
	GOLD,
	GOLD_DK,
	GOLD_HI,
	INK,
	INK_BLUE,
	LEAF,
	LEAF_DK,
	REPO_ROOT,
	SAND_DARK,
	SAND_DRY,
	SAND_HI,
	SAND_MID,
	SEA_DEEP,
	SEA_FOAM,
	SEA_LIGHT,
	SEA_MID,
	SUN,
	TRUNK,
	TRUNK_DK,
	dither_vgrad,
	draw_palm,
	fill_ellipse,
	fill_polygon,
	fill_rect,
	new_canvas,
	outline,
	pixel_eye,
	pixel_line,
	px,
	save,
	speckles,
	upscale_nearest,
)

SHARED_ART = REPO_ROOT / "shared/ui/art"
TI_ICONS = REPO_ROOT / "games/treasure-island/art/icons"

SOURCE_SIZE = (256, 192)
NIGHT_TOP = (20, 17, 45)
NIGHT_MID = (38, 47, 89)
NIGHT_HORIZON = (92, 72, 105)
PANEL = (22, 18, 42)
PANEL_HI = (48, 37, 63)

GLYPHS: dict[str, tuple[str, ...]] = {
	"A": ("01110", "10001", "10001", "11111", "10001", "10001", "10001"),
	"D": ("11110", "10001", "10001", "10001", "10001", "10001", "11110"),
	"E": ("11111", "10000", "10000", "11110", "10000", "10000", "11111"),
	"G": ("01110", "10001", "10000", "10111", "10001", "10001", "01110"),
	"I": ("11111", "00100", "00100", "00100", "00100", "00100", "11111"),
	"L": ("10000", "10000", "10000", "10000", "10000", "10000", "11111"),
	"N": ("10001", "11001", "10101", "10101", "10011", "10001", "10001"),
	"O": ("01110", "10001", "10001", "10001", "10001", "10001", "01110"),
	"R": ("11110", "10001", "10001", "11110", "10100", "10010", "10001"),
	"S": ("01111", "10000", "10000", "01110", "00001", "00001", "11110"),
	"T": ("11111", "00100", "00100", "00100", "00100", "00100", "00100"),
	"U": ("10001", "10001", "10001", "10001", "10001", "10001", "01110"),
	"V": ("10001", "10001", "10001", "10001", "10001", "01010", "00100"),
	"Y": ("10001", "10001", "01010", "00100", "00100", "00100", "00100"),
	"Z": ("11111", "00001", "00010", "00100", "01000", "10000", "11111"),
	" ": ("00000",) * 7,
}


def _draw_stars(im: Image.Image, rng: random.Random) -> None:
	for _ in range(66):
		x = rng.randrange(5, im.width - 5)
		y = rng.randrange(5, 112)
		if 62 < x < 194 and 42 < y < 104:
			continue
		color = rng.choice((GOLD_HI, SAND_HI, (176, 196, 220)))
		px(im, x, y, color)
		if rng.random() < 0.13:
			px(im, x - 1, y, color)
			px(im, x + 1, y, color)
			px(im, x, y - 1, color)
			px(im, x, y + 1, color)


def _draw_sea(im: Image.Image) -> None:
	fill_rect(im, 0, 120, 255, 159, SEA_DEEP)
	fill_rect(im, 0, 126, 255, 145, (24, 72, 129))
	fill_rect(im, 0, 146, 255, 159, SEA_MID)
	for row, y in enumerate(range(126, 158, 6)):
		offset = (row * 9) % 22
		for x in range(-24 + offset, 256, 32):
			pixel_line(
				im,
				[(max(0, x), y + 1), (min(255, x + 9), y), (min(255, x + 18), y + 1)],
				SEA_LIGHT if row % 2 == 0 else SEA_FOAM,
			)
	fill_rect(im, 0, 158, 255, 160, SEA_FOAM)


def _draw_sand(im: Image.Image, rng: random.Random) -> None:
	fill_rect(im, 0, 161, 255, 191, SAND_MID)
	fill_rect(im, 0, 164, 255, 191, SAND_DRY)
	fill_rect(im, 0, 164, 255, 165, SAND_HI)
	speckles(
		im,
		0,
		167,
		256,
		192,
		(SAND_HI, SAND_MID, SAND_DARK),
		0.018,
		rng,
		(1, 2),
	)


def _draw_frame(im: Image.Image) -> None:
	pixel_line(im, [(0, 0), (255, 0), (255, 191), (0, 191), (0, 0)], INK, 2)
	for x, y, sx, sy in [
		(4, 4, 1, 1),
		(251, 4, -1, 1),
		(4, 187, 1, -1),
		(251, 187, -1, -1),
	]:
		pixel_line(im, [(x, y + 7 * sy), (x, y), (x + 7 * sx, y)], GOLD_DK, 2)
		px(im, x + 3 * sx, y + 3 * sy, GOLD_HI)


def menu_night_source() -> Image.Image:
	rng = random.Random(1987)
	im = new_canvas(*SOURCE_SIZE, NIGHT_TOP)
	dither_vgrad(im, 0, 121, NIGHT_TOP, NIGHT_HORIZON, levels=7)
	_draw_stars(im, rng)

	# A chunky moon and tiny cloud bank frame the central UI without competing.
	fill_ellipse(im, (210, 13, 234, 37), (255, 228, 135))
	fill_ellipse(im, (215, 11, 235, 32), NIGHT_MID)
	fill_rect(im, 171, 49, 196, 51, (72, 76, 121))
	fill_rect(im, 177, 46, 190, 50, (92, 94, 139))
	fill_rect(im, 182, 44, 187, 48, (116, 113, 151))

	# Sunset seam, ocean, and shore keep the three old ColorRects recognisable
	# while replacing them with one authored, cohesive pixel backdrop.
	fill_rect(im, 0, 116, 255, 119, (171, 91, 72))
	fill_rect(im, 0, 118, 255, 120, (232, 139, 77))
	_draw_sea(im)
	_draw_sand(im, rng)
	draw_palm(im, 25, 169, 0.72)
	draw_palm(im, 238, 171, 0.82, mirror=True)
	_draw_frame(im)
	return im


def _text_width(text: str, scale: int) -> int:
	return max(0, (len(text) * 6 - 1) * scale)


def _draw_text(
	im: Image.Image,
	text: str,
	y: int,
	scale: int,
	color: Sequence[int],
	shadow: Sequence[int] = INK,
) -> None:
	x0 = (im.width - _text_width(text, scale)) // 2
	for index, letter in enumerate(text):
		glyph = GLYPHS[letter]
		base_x = x0 + index * 6 * scale
		for gy, row in enumerate(glyph):
			for gx, bit in enumerate(row):
				if bit != "1":
					continue
				x = base_x + gx * scale
				yy = y + gy * scale
				fill_rect(im, x + scale, yy + scale, x + scale * 2 - 1, yy + scale * 2 - 1, shadow)
				fill_rect(im, x, yy, x + scale - 1, yy + scale - 1, color)


def menu_dizzy_source() -> Image.Image:
	"""Friendly symmetric mascot for menus; gameplay keeps its directional face."""
	im = new_canvas(22, 28)

	# Limbs sit behind the shell and mirror exactly around its centre.
	pixel_line(im, [(5, 13), (2, 16)], EGG_EDGE, 3)
	pixel_line(im, [(5, 13), (2, 16)], EGG, 1)
	pixel_line(im, [(16, 13), (19, 16)], EGG_EDGE, 3)
	pixel_line(im, [(16, 13), (19, 16)], EGG, 1)
	fill_ellipse(im, (-1, 14, 5, 20), INK_BLUE)
	fill_ellipse(im, (0, 14, 4, 19), GLOVE)
	fill_rect(im, 1, 14, 3, 15, GLOVE_HI)
	fill_ellipse(im, (16, 14, 22, 20), INK_BLUE)
	fill_ellipse(im, (17, 14, 21, 19), GLOVE)
	fill_rect(im, 18, 14, 20, 15, GLOVE_HI)

	fill_polygon(im, [(5, 19), (9, 19), (10, 22), (10, 26), (2, 26), (2, 22)], BOOT_DK)
	fill_polygon(im, [(5, 20), (8, 20), (9, 22), (9, 24), (3, 24), (3, 22)], BOOT)
	fill_rect(im, 4, 21, 7, 21, BOOT_HI)
	fill_polygon(im, [(12, 19), (16, 19), (19, 22), (19, 26), (11, 26), (11, 22)], BOOT_DK)
	fill_polygon(im, [(13, 20), (16, 20), (18, 22), (18, 24), (12, 24), (12, 22)], BOOT)
	fill_rect(im, 14, 21, 17, 21, BOOT_HI)

	body_layer = new_canvas(22, 28)
	cx, cy, rx, ry = 10.5, 11.0, 7.5, 10.5
	for y in range(24):
		for x in range(22):
			nx = (x - cx) / rx
			ny = (y - cy) / ry
			if nx * nx + ny * ny > 1.0:
				continue
			color = EGG
			if x <= 5 or y >= 19:
				color = EGG_SH
			elif x >= 13 and y <= 6:
				color = EGG_HI
			px(body_layer, x, y, color)
	outline(body_layer, EGG_EDGE, diagonal=False)
	im.alpha_composite(body_layer)

	# Matching stepped ovals keep the greeting pose friendly and front-facing.
	pixel_eye(im, 5, 6)
	pixel_eye(im, 11, 6)
	fill_rect(im, 10, 12, 11, 12, EGG_EDGE)
	pixel_line(im, [(8, 14), (10, 16), (11, 16), (13, 14)], EGG_EDGE)
	px(im, 10, 15, BOOT_HI)
	px(im, 11, 15, BOOT_HI)
	return im


def _draw_mini_dizzy(im: Image.Image, cx: int, top: int) -> None:
	im.alpha_composite(menu_dizzy_source(), (cx - 11, top))


def boot_splash_source() -> Image.Image:
	im = menu_night_source()
	fill_rect(im, 63, 41, 192, 155, INK)
	fill_rect(im, 66, 44, 189, 152, PANEL_HI)
	fill_rect(im, 69, 47, 186, 149, PANEL)
	for x, y in ((70, 48), (185, 48), (70, 148), (185, 148)):
		fill_rect(im, x - 1, y - 1, x + 1, y + 1, GOLD_DK)

	_draw_text(im, "DIZZY", 55, 3, GOLD_HI)
	_draw_text(im, "ADVENTURES", 80, 1, SAND_HI, INK_BLUE)
	_draw_mini_dizzy(im, 128, 94)

	fill_rect(im, 91, 132, 164, 143, INK_BLUE)
	fill_rect(im, 93, 134, 162, 141, (43, 35, 58))
	for index in range(8):
		x = 95 + index * 8
		color = GOLD_HI if index % 2 == 0 else BOOT_HI
		fill_rect(im, x, 136, x + 5, 139, color)
	return im


def victory_escape_source() -> Image.Image:
	"""Dawn escape tableau for the completed Treasure Island adventure."""
	rng = random.Random(1989)
	im = new_canvas(*SOURCE_SIZE, (35, 25, 64))
	dither_vgrad(im, 0, 111, (35, 25, 64), (236, 126, 77), levels=8)

	# The last stars fade above a warm sunrise and distant island silhouettes.
	for _ in range(30):
		x = rng.randrange(7, 249)
		y = rng.randrange(7, 67)
		color = rng.choice((GOLD_HI, SAND_HI, (178, 194, 221)))
		px(im, x, y, color)
		if rng.random() < 0.12:
			px(im, x + 1, y, color)
	fill_ellipse(im, (205, 66, 225, 86), SUN)
	fill_ellipse(im, (209, 69, 222, 82), GOLD_HI)
	fill_rect(im, 14, 72, 52, 74, (91, 70, 106))
	fill_rect(im, 23, 69, 45, 73, (124, 85, 112))
	fill_rect(im, 31, 67, 39, 70, (151, 98, 116))

	fill_rect(im, 0, 105, 255, 191, SEA_DEEP)
	fill_rect(im, 0, 111, 255, 144, (28, 75, 125))
	fill_rect(im, 0, 145, 255, 191, SEA_MID)
	fill_polygon(im, [(0, 107), (23, 96), (55, 101), (77, 111), (0, 114)], INK_BLUE)
	fill_polygon(im, [(183, 109), (208, 97), (241, 99), (255, 106), (255, 114)], INK_BLUE)
	draw_palm(im, 24, 104, 0.42)
	draw_palm(im, 235, 103, 0.38, mirror=True)

	# Broken, offset wavelets keep the broad water bands visibly hand-authored.
	for row, y in enumerate(range(114, 190, 7)):
		offset = (row * 11) % 29
		for x in range(-25 + offset, 256, 38):
			color = SEA_LIGHT if row % 3 else SEA_FOAM
			pixel_line(im, [(max(0, x), y + 1), (min(255, x + 10), y)], color)
	for y, half_width in ((112, 4), (119, 7), (127, 11), (136, 16), (147, 22)):
		fill_rect(im, 215 - half_width, y, 215 + half_width, y, GOLD_HI)

	# The repaired boat is the reward: motor, windscreen, wake, and Dizzy aboard.
	fill_ellipse(im, (63, 166, 197, 178), SEA_DEEP)
	pixel_line(im, [(54, 171), (87, 168), (112, 172)], SEA_FOAM, 2)
	pixel_line(im, [(171, 169), (204, 166), (231, 168)], SEA_FOAM, 2)
	fill_polygon(im, [(60, 146), (198, 146), (183, 170), (85, 172), (68, 163)], INK)
	fill_polygon(im, [(65, 149), (193, 149), (179, 166), (87, 168), (72, 160)], TRUNK_DK)
	fill_polygon(im, [(74, 150), (188, 150), (177, 160), (91, 163)], BOOT)
	fill_polygon(im, [(82, 151), (184, 151), (176, 155), (88, 157)], BOOT_HI)
	fill_rect(im, 79, 143, 187, 148, INK)
	fill_rect(im, 83, 140, 183, 145, SAND_DRY)
	fill_rect(im, 88, 140, 178, 141, SAND_HI)

	# Windscreen and a tiny pennant sell motion without obscuring the hero.
	fill_polygon(im, [(149, 139), (158, 126), (176, 126), (183, 139)], INK)
	fill_polygon(im, [(153, 137), (160, 129), (174, 129), (178, 137)], SEA_LIGHT)
	pixel_line(im, [(185, 143), (185, 115)], INK, 2)
	fill_polygon(im, [(187, 116), (202, 121), (187, 125)], GOLD)
	fill_polygon(im, [(187, 117), (198, 121), (187, 121)], GOLD_HI)
	fill_rect(im, 54, 146, 65, 162, INK)
	fill_rect(im, 56, 148, 63, 157, PANEL_HI)
	fill_rect(im, 52, 158, 64, 164, INK_BLUE)

	im.alpha_composite(menu_dizzy_source(), (106, 115))
	fill_rect(im, 107, 141, 128, 147, SAND_DRY)
	fill_rect(im, 108, 141, 127, 142, SAND_HI)

	_draw_frame(im)
	return im


def treasure_island_icon_source() -> Image.Image:
	im = new_canvas(24, 24, NIGHT_TOP)
	dither_vgrad(im, 0, 14, NIGHT_TOP, (69, 93, 148), levels=4)
	fill_rect(im, 0, 14, 23, 23, SEA_DEEP)
	for x in range(0, 24, 6):
		fill_rect(im, x, 16 + (x // 6) % 2, min(23, x + 3), 16 + (x // 6) % 2, SEA_LIGHT)
	fill_polygon(im, [(3, 15), (7, 11), (16, 11), (21, 15), (18, 17), (5, 17)], SAND_DARK)
	fill_polygon(im, [(5, 14), (8, 10), (16, 10), (19, 14)], SAND_HI)

	pixel_line(im, [(10, 12), (10, 8), (11, 5)], TRUNK_DK, 2)
	pixel_line(im, [(11, 6), (7, 4), (5, 5)], LEAF_DK, 2)
	pixel_line(im, [(11, 6), (14, 3), (17, 4)], LEAF, 2)
	pixel_line(im, [(11, 6), (16, 7), (18, 9)], LEAF_DK, 2)

	fill_ellipse(im, (4, 8, 8, 14), EGG_EDGE)
	fill_ellipse(im, (5, 9, 7, 13), EGG)
	px(im, 7, 10, INK)
	fill_rect(im, 4, 14, 6, 15, BOOT)
	fill_rect(im, 7, 14, 9, 15, BOOT)

	fill_ellipse(im, (17, 7, 21, 11), GOLD_DK)
	fill_ellipse(im, (18, 7, 20, 10), GOLD)
	px(im, 19, 8, GOLD_HI)
	return im


def main() -> None:
	save(upscale_nearest(menu_night_source(), 4), SHARED_ART / "menu_night.png")
	save(upscale_nearest(boot_splash_source(), 4), SHARED_ART / "boot_splash.png")
	save(upscale_nearest(menu_dizzy_source(), 4), SHARED_ART / "menu_dizzy.png")
	save(upscale_nearest(victory_escape_source(), 4), SHARED_ART / "victory_escape.png")
	save(upscale_nearest(treasure_island_icon_source(), 4), TI_ICONS / "select_ti.png")
	print("pre-game art done")


if __name__ == "__main__":
	main()
