#!/usr/bin/env python3
"""Original 256×192-style biome paintings, drawn native at 1024×768."""
from __future__ import annotations

import math
import random

from PIL import Image, ImageDraw

from ti_art_lib import (
	CLOUD_SH,
	INK,
	INK_BLUE,
	INK_BROWN,
	LEAF,
	LEAF_DK,
	LEAF_HI,
	LEAF_LIME,
	REPO_ROOT,
	ROCK,
	ROCK_DK,
	ROCK_HI,
	SAND_DARK,
	SAND_DRY,
	SAND_HI,
	SAND_MID,
	SAND_WET,
	SEA_DEEP,
	SEA_FOAM,
	SEA_LIGHT,
	SEA_MID,
	SKY_HORIZON,
	SKY_MID,
	SKY_TOP,
	SUN,
	TRUNK,
	TRUNK_DK,
	TRUNK_HI,
	WOOD,
	WOOD_DK,
	WOOD_HI,
	blend,
	dither_vgrad,
	draw_bird,
	draw_cloud,
	draw_palm,
	fill_ellipse,
	fill_polygon,
	fill_rect,
	logical_canvas,
	paint_scale,
	pixel_line,
	px,
	save,
	speckles,
)

BACKDROPS = REPO_ROOT / "games/treasure-island/art/backdrops"
W, H = 256, 192
NATIVE_SCALE = 4


def _grass_tuft(im: Image.Image, x: int, y: int, color=LEAF_DK) -> None:
	for dx, height in [(-4, 5), (-2, 8), (0, 6), (2, 9), (4, 5)]:
		pixel_line(im, [(x, y), (x + dx, y - height)], color)


def _fern(im: Image.Image, x: int, y: int, scale: int = 1) -> None:
	pixel_line(im, [(x, y), (x, y - 12 * scale)], LEAF_DK, scale)
	for step in range(2, 11, 2):
		width = max(2, (11 - step) * scale)
		yy = y - step * scale
		pixel_line(im, [(x, yy), (x - width, yy - 3 * scale)], LEAF, scale)
		pixel_line(im, [(x, yy - scale), (x + width, yy - 4 * scale)], LEAF_HI, scale)


def beach(rng: random.Random) -> Image.Image:
	im = logical_canvas(W, H, SKY_TOP)
	dither_vgrad(im, 0, 76, SKY_TOP, SKY_MID, 6)
	dither_vgrad(im, 76, 105, SKY_MID, SKY_HORIZON, 5)

	fill_ellipse(im, (25, 14, 42, 31), (238, 184, 82))
	fill_ellipse(im, (28, 17, 39, 28), SUN)
	draw_cloud(im, 67, 25, 0.85)
	draw_cloud(im, 145, 17, 0.6)
	draw_cloud(im, 211, 34, 0.75)
	draw_bird(im, 104, 46)
	draw_bird(im, 116, 40)

	dither_vgrad(im, 103, 137, SEA_MID, SEA_DEEP, 5)
	for row, color, phase in [
		(108, SEA_FOAM, 0.2),
		(116, SEA_LIGHT, 1.4),
		(124, SEA_FOAM, 2.7),
		(132, SEA_LIGHT, 4.1),
	]:
		for x in range(0, W, 3):
			y = row + int(math.sin(x * 0.12 + phase))
			if (x // 3 + row) % 4 != 0:
				pixel_line(im, [(x, y), (min(W - 1, x + 4), y)], color)

	# A quiet, original island silhouette behind the shoreline.
	fill_ellipse(im, (153, 96, 190, 107), (44, 98, 73))
	fill_polygon(im, [(160, 102), (171, 91), (184, 102)], LEAF_DK)
	fill_rect(im, 171, 97, 173, 104, TRUNK_DK)
	fill_ellipse(im, (163, 92, 181, 99), LEAF_DK)

	fill_rect(im, 0, 136, W - 1, 151, SAND_WET)
	dither_vgrad(im, 151, H, SAND_MID, SAND_DRY, 5)
	for x in range(W):
		wave_y = 136 + int(math.sin(x * 0.10) * 2)
		px(im, x, wave_y, SEA_FOAM)
		if x % 7 in (0, 1, 2):
			px(im, x, wave_y + 2, SAND_HI)
		if x % 13 == 0:
			px(im, x, 147 + int(math.sin(x * 0.07)), SAND_DARK)
	speckles(
		im,
		0,
		153,
		W,
		H,
		[SAND_DARK, SAND_WET, SAND_HI],
		0.014,
		rng,
		(1, 1, 2),
	)

	# Dune vegetation, shells, driftwood and two depth-separated palms.
	for gx in (18, 47, 79, 153, 178):
		_grass_tuft(im, gx, 166 + (gx % 3), LEAF if gx % 2 else LEAF_DK)
	pixel_line(im, [(88, 177), (107, 174), (119, 176)], TRUNK_DK, 2)
	pixel_line(im, [(90, 175), (108, 173)], TRUNK_HI)
	for sx, sy, color in [
		(34, 180, (225, 102, 74)),
		(70, 170, CLOUD_SH),
		(143, 183, (199, 90, 78)),
		(191, 174, SAND_HI),
	]:
		px(im, sx, sy, color)
		px(im, sx + 1, sy, color)
		px(im, sx, sy + 1, SAND_DARK)
	draw_palm(im, 26, 148, 0.55, mirror=True)
	draw_palm(im, 222, 181, 1.1)
	return im


def tree(rng: random.Random) -> Image.Image:
	im = logical_canvas(W, H, (25, 74, 72))
	dither_vgrad(im, 0, 102, (44, 113, 112), (21, 65, 61), 5)

	# Blue daylight holes keep the canopy from collapsing into a black void.
	for box in [(14, 8, 55, 37), (91, 4, 137, 31), (183, 10, 239, 43)]:
		fill_ellipse(im, box, (73, 139, 166))
		fill_ellipse(im, (box[0] + 5, box[1] + 3, box[2] - 8, box[3] - 5), (92, 157, 174))

	# Distant trunks and hanging vines.
	for tx, width in [(12, 5), (57, 7), (151, 6), (234, 8)]:
		fill_rect(im, tx, 28, tx + width, 160, (51, 69, 51))
		px(im, tx + 1, 35, (78, 98, 59))
	for vx, length in [(35, 67), (78, 44), (172, 65), (215, 50)]:
		pixel_line(im, [(vx, 0), (vx - 2, length // 2), (vx + 2, length)], LEAF_DK)
		if vx % 2:
			fill_ellipse(im, (vx, length - 2, vx + 3, length + 1), LEAF_HI)

	# Layered canopy clumps in three palette bands.
	canopy = [
		(2, 4, 69, 31, LEAF_DK),
		(42, -7, 118, 29, LEAF),
		(101, -4, 176, 34, LEAF_DK),
		(151, 0, 222, 31, LEAF),
		(200, 5, 267, 39, LEAF_DK),
		(16, 24, 91, 57, LEAF),
		(76, 20, 151, 58, LEAF_DK),
		(139, 25, 207, 59, LEAF),
		(191, 30, 256, 64, LEAF_DK),
	]
	for x0, y0, x1, y1, color in canopy:
		fill_ellipse(im, (x0, y0, x1, y1), color)
	for x, y in [(26, 18), (67, 9), (119, 17), (165, 12), (210, 27), (239, 18)]:
		fill_rect(im, x, y, x + 7, y + 3, LEAF_HI)
		px(im, x + 2, y, LEAF_LIME)

	# Hero trunks with branch forks and hand-placed bark clusters.
	for tx, lean in [(42, -7), (116, 6), (206, -5)]:
		fill_polygon(
			im,
			[
				(tx - 9, 166),
				(tx - 6, 47),
				(tx + lean, 34),
				(tx + 10, 48),
				(tx + 11, 166),
			],
			TRUNK_DK,
		)
		fill_polygon(
			im,
			[(tx - 5, 165), (tx - 3, 48), (tx + lean, 38), (tx + 4, 51), (tx + 5, 165)],
			TRUNK,
		)
		pixel_line(im, [(tx - 3, 158), (tx, 93), (tx + lean, 42)], TRUNK_HI, 2)
		for y in range(59, 153, 16):
			pixel_line(im, [(tx - 4, y), (tx + 4, y - 3)], TRUNK_DK, 2)
	# Branches create depth without pretending to be collision platforms.
	pixel_line(im, [(38, 76), (76, 61), (107, 62)], TRUNK_DK, 8)
	pixel_line(im, [(39, 73), (77, 58), (108, 59)], TRUNK, 4)
	pixel_line(im, [(203, 91), (172, 77), (139, 79)], TRUNK_DK, 7)
	pixel_line(im, [(202, 88), (171, 74), (140, 76)], TRUNK, 3)

	# A small distant treehouse and rope bridge.
	fill_polygon(im, [(160, 62), (177, 48), (194, 62)], (104, 61, 40))
	fill_rect(im, 163, 62, 191, 78, WOOD)
	fill_rect(im, 174, 67, 181, 78, WOOD_DK)
	fill_rect(im, 148, 80, 218, 83, WOOD_DK)
	pixel_line(im, [(144, 75), (181, 84), (223, 76)], (93, 65, 39))
	for x in range(148, 221, 8):
		pixel_line(im, [(x, 78 + abs(x - 183) // 18), (x, 84 + abs(x - 183) // 18)], WOOD_HI)

	dither_vgrad(im, 151, H, (53, 58, 39), (70, 47, 33), 4)
	speckles(im, 0, 151, W, H, [TRUNK_DK, (92, 73, 43), LEAF_DK], 0.022, rng, (1, 2))
	for fx in range(8, W, 22):
		_fern(im, fx, 180 - (fx % 7), 1)
	return im


def ocean(rng: random.Random) -> Image.Image:
	im = logical_canvas(W, H, SEA_DEEP)
	dither_vgrad(im, 0, H, (19, 70, 126), (15, 47, 91), 7)

	# Surface shimmer and broad light shafts.
	fill_rect(im, 0, 0, W - 1, 3, SEA_FOAM)
	for x in range(0, W, 11):
		pixel_line(im, [(x, 5 + (x % 3)), (min(W - 1, x + 7), 4)], SEA_LIGHT, 2)
	for points in [
		[(22, 2), (49, 2), (88, 151), (66, 151)],
		[(107, 2), (127, 2), (143, 151), (126, 151)],
		[(194, 2), (218, 2), (205, 151), (185, 151)],
	]:
		fill_polygon(im, points, blend(SEA_DEEP, SEA_LIGHT, 0.17))

	for y in range(18, 147, 16):
		for x in range((y * 3) % 17, W, 29):
			length = 4 + (x + y) % 7
			pixel_line(im, [(x, y), (min(W - 1, x + length), y - 1)], blend(SEA_MID, SEA_FOAM, 0.38))

	# Tiny distant life silhouettes add depth without competing with hazards.
	for x, y, direction in [(47, 68, 1), (184, 51, -1), (219, 104, -1)]:
		fill_ellipse(im, (x - 6, y - 2, x + 5, y + 3), blend(SEA_DEEP, INK_BLUE, 0.45))
		fill_polygon(im, [(x - 6 * direction, y), (x - 10 * direction, y - 4), (x - 10 * direction, y + 4)], INK_BLUE)

	# Bubble trails use rings rather than opaque polka dots.
	from ti_art_lib import paint_scale_value

	s = paint_scale_value()
	d = ImageDraw.Draw(im)
	for _ in range(24):
		x = rng.randrange(8, W - 8)
		y = rng.randrange(15, 145)
		radius = rng.choice((1, 1, 2, 3))
		box = (
			(x - radius) * s,
			(y - radius) * s,
			(x + radius) * s + (s - 1),
			(y + radius) * s + (s - 1),
		)
		d.ellipse(box, outline=(*SEA_FOAM, 255), width=max(1, s))
		px(im, x - radius, y - radius, (232, 245, 226))

	# Sand shelf, ripples, rocks, coral and several seaweed silhouettes.
	dither_vgrad(im, 151, H, (94, 112, 76), (128, 108, 61), 4)
	for y in (158, 169, 180, 188):
		for x in range((y * 5) % 19, W, 26):
			pixel_line(im, [(x, y), (min(W - 1, x + 11), y - 1)], (159, 139, 78))
	for x, y, rx, ry in [(21, 165, 17, 11), (72, 180, 22, 12), (170, 171, 19, 13), (233, 183, 25, 14)]:
		fill_ellipse(im, (x - rx, y - ry, x + rx, y + ry), ROCK_DK)
		fill_polygon(im, [(x - rx + 3, y), (x, y - ry), (x + rx - 3, y + 1), (x + 5, y + ry - 3)], ROCK)
		pixel_line(im, [(x - rx // 2, y - 2), (x, y - ry + 3), (x + rx // 2, y - 1)], ROCK_HI)
	for sx in (8, 49, 112, 147, 205, 248):
		for branch in (-1, 0, 1):
			pixel_line(
				im,
				[(sx, 190), (sx + branch * 3, 178), (sx - branch * 2, 164 - abs(branch) * 4)],
				(30, 105, 76) if branch else LEAF_HI,
				2,
			)
	for cx, cy, color in [(97, 180, (204, 91, 78)), (156, 186, (177, 85, 151))]:
		pixel_line(im, [(cx, cy), (cx, cy - 17)], color, 2)
		pixel_line(im, [(cx, cy - 8), (cx - 7, cy - 14)], color, 2)
		pixel_line(im, [(cx, cy - 5), (cx + 7, cy - 12)], color, 2)
	return im


def cavern(rng: random.Random) -> Image.Image:
	im = logical_canvas(W, H, (34, 29, 42))
	dither_vgrad(im, 0, H, (31, 28, 43), (64, 47, 49), 5)

	# Far wall strata and a central arch give the cave a readable silhouette.
	fill_polygon(im, [(0, 0), (41, 0), (34, 121), (20, 154), (0, 154)], (46, 39, 52))
	fill_polygon(im, [(256, 0), (214, 0), (221, 112), (238, 154), (256, 154)], (42, 37, 50))
	fill_polygon(im, [(76, 0), (180, 0), (167, 25), (91, 25)], (48, 39, 50))
	for y in (43, 76, 109, 137):
		pixel_line(im, [(40, y), (83, y - 8), (128, y - 3), (174, y - 10), (216, y)], (76, 56, 61), 2)
		for x in range(47 + y % 9, 214, 27):
			px(im, x, y - (x % 6), (111, 76, 66))

	# Irregular ceiling and stalactites.
	ceiling = [(0, 0), (256, 0), (256, 10)]
	for x in range(250, -1, -13):
		depth = 8 + (x * 7) % 22
		ceiling.append((x, depth))
	ceiling.append((0, 12))
	fill_polygon(im, ceiling, INK)
	for x in range(10, 249, 19):
		length = 8 + (x * 5) % 25
		fill_polygon(im, [(x - 4, 8), (x + 5, 8), (x + (x % 3) - 1, 8 + length)], ROCK_DK)
		pixel_line(im, [(x - 2, 10), (x, 12 + length // 2)], ROCK, 2)

	dither_vgrad(im, 151, H, (65, 52, 50), (82, 59, 49), 4)
	speckles(im, 0, 151, W, H, [(43, 38, 43), (111, 82, 62), ROCK_DK], 0.018, rng, (1, 2))
	for x, y, size in [(25, 159, 18), (118, 174, 24), (215, 163, 22)]:
		fill_ellipse(im, (x - size, y - size // 2, x + size, y + size // 2), ROCK_DK)
		fill_polygon(im, [(x - size + 3, y), (x - 3, y - size // 2), (x + size - 2, y + 2), (x + 2, y + size // 2)], ROCK)
		pixel_line(im, [(x - size // 2, y - 1), (x - 2, y - size // 2 + 2), (x + size // 2, y)], ROCK_HI)

	# Small torch: layered opaque palette rings, never a giant alpha disc.
	for radius, color in [(25, (92, 57, 49)), (17, (137, 72, 45)), (9, (202, 99, 43))]:
		fill_ellipse(im, (39 - radius, 103 - radius, 39 + radius, 103 + radius), color)
	fill_rect(im, 36, 101, 39, 120, WOOD_DK)
	fill_polygon(im, [(34, 102), (38, 90), (42, 102)], (234, 103, 37))
	fill_polygon(im, [(36, 100), (39, 94), (40, 101)], (255, 211, 80))

	# Cyan and violet mineral clusters act as restrained colour punctuation.
	for cx, cy, color, hi in [
		(78, 163, (61, 143, 161), (122, 220, 211)),
		(188, 158, (122, 76, 155), (206, 137, 195)),
	]:
		for ox, height in [(-7, 10), (-2, 19), (4, 14), (9, 8)]:
			fill_polygon(im, [(cx + ox - 3, cy), (cx + ox, cy - height), (cx + ox + 4, cy)], color)
			pixel_line(im, [(cx + ox, cy - height + 2), (cx + ox, cy - 2)], hi)
	# A narrow puddle catches a few cave colours.
	fill_ellipse(im, (135, 177, 204, 188), (42, 67, 76))
	pixel_line(im, [(145, 181), (168, 179), (192, 181)], (83, 136, 137))
	return im


def hut(rng: random.Random) -> Image.Image:
	im = logical_canvas(W, H, WOOD)
	for y in range(0, 153, 9):
		base = WOOD if (y // 9) % 2 else (157, 95, 47)
		fill_rect(im, 0, y, W - 1, y + 7, base)
		fill_rect(im, 0, y, W - 1, y, WOOD_HI)
		fill_rect(im, 0, y + 7, W - 1, y + 8, WOOD_DK)
		for x in range((y * 7) % 41, W, 48):
			fill_rect(im, x, y + 1, x + 1, y + 7, TRUNK_DK)
			px(im, x + 3, y + 3, WOOD_HI)

	# Structural beams frame the room.
	fill_rect(im, 0, 0, W - 1, 8, INK_BROWN)
	fill_rect(im, 0, 7, W - 1, 11, TRUNK_DK)
	for x in (0, 63, 126, 248):
		fill_rect(im, x, 0, min(W - 1, x + 7), 158, TRUNK_DK)
		fill_rect(im, x + 1, 0, min(W - 1, x + 2), 158, TRUNK_HI)

	# Sea-facing window with chunky frame and crossbar.
	fill_rect(im, 175, 23, 239, 85, INK_BROWN)
	fill_rect(im, 179, 27, 235, 81, WOOD_HI)
	fill_rect(im, 183, 31, 231, 77, SKY_HORIZON)
	fill_rect(im, 183, 60, 231, 77, SEA_MID)
	for x in range(184, 231, 8):
		pixel_line(im, [(x, 67 + x % 3), (min(230, x + 5), 66 + x % 3)], SEA_FOAM)
	fill_rect(im, 205, 29, 209, 79, WOOD_HI)
	fill_rect(im, 181, 52, 233, 56, WOOD_HI)
	fill_rect(im, 178, 25, 181, 83, TRUNK_HI)
	fill_rect(im, 233, 25, 237, 83, TRUNK_DK)

	# Two shelves of jars, books, rope and an old bottle.
	for sy in (91, 121):
		fill_rect(im, 15, sy, 111, sy + 5, INK_BROWN)
		fill_rect(im, 16, sy, 110, sy + 1, WOOD_HI)
	for x, y, color in [(22, 78, (78, 139, 137)), (39, 80, (184, 91, 59)), (55, 77, (200, 169, 73))]:
		fill_rect(im, x, y, x + 9, 90, color)
		fill_rect(im, x + 2, y - 3, x + 7, y, CLOUD_SH)
		px(im, x + 2, y + 2, (231, 205, 133))
	for x, color, height in [(22, (65, 82, 117), 18), (29, (153, 62, 52), 15), (36, (191, 150, 62), 17)]:
		fill_rect(im, x, 121 - height, x + 5, 120, color)
		fill_rect(im, x + 1, 104, x + 4, 105, SAND_HI)
	fill_ellipse(im, (72, 99, 94, 118), (91, 55, 39))
	fill_ellipse(im, (75, 102, 91, 115), (174, 112, 58))
	pixel_line(im, [(83, 99), (99, 103), (103, 113)], CLOUD_SH, 2)

	# Lantern, wall map and knotted fishing net.
	pixel_line(im, [(143, 8), (143, 31)], INK_BROWN, 2)
	fill_polygon(im, [(137, 31), (149, 31), (153, 45), (133, 45)], INK_BROWN)
	fill_rect(im, 137, 33, 149, 42, (222, 145, 54))
	fill_rect(im, 140, 34, 146, 39, (255, 218, 104))
	fill_rect(im, 119, 70, 162, 112, SAND_DARK)
	fill_rect(im, 122, 67, 159, 109, (213, 182, 116))
	pixel_line(im, [(128, 77), (137, 84), (151, 73)], (97, 126, 91))
	pixel_line(im, [(127, 99), (140, 91), (153, 102)], (138, 73, 50))
	for offset in range(0, 45, 8):
		pixel_line(im, [(4, 20 + offset), (48 - offset // 2, 63)], (160, 132, 83))
		pixel_line(im, [(4 + offset, 18), (4, 62 - offset // 2)], (160, 132, 83))

	# Floorboards with perspective seams and nail clusters.
	fill_rect(im, 0, 153, W - 1, H - 1, WOOD_DK)
	for y in range(153, H, 10):
		fill_rect(im, 0, y, W - 1, y + 1, INK_BROWN)
		fill_rect(im, 0, y + 2, W - 1, y + 3, WOOD)
	for x in range(8, W, 32):
		pixel_line(im, [(x, 153), (x - 10 + (x % 5), H - 1)], INK_BROWN)
	speckles(im, 0, 153, W, H, [TRUNK, WOOD_HI, INK_BROWN], 0.012, rng)
	return im


def main() -> None:
	BACKDROPS.mkdir(parents=True, exist_ok=True)
	with paint_scale(NATIVE_SCALE):
		generators = {
			"beach": (beach, 42),
			"tree": (tree, 43),
			"ocean": (ocean, 44),
			"cavern": (cavern, 45),
			"hut": (hut, 46),
		}
		for name, (generate, seed) in generators.items():
			save(generate(random.Random(seed)), BACKDROPS / f"{name}.png")
	print("backdrops done")


if __name__ == "__main__":
	main()
