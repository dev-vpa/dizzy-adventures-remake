#!/usr/bin/env python3
"""Seam-friendly chunky terrain tiles for every Treasure Island biome."""
from __future__ import annotations

import random

from ti_art_lib import (
	INK,
	INK_BROWN,
	LEAF,
	LEAF_DK,
	LEAF_HI,
	REPO_ROOT,
	ROCK,
	ROCK_DK,
	ROCK_HI,
	SAND_DARK,
	SAND_DRY,
	SAND_HI,
	SAND_MID,
	SEA_DEEP,
	SEA_FOAM,
	SEA_LIGHT,
	SEA_MID,
	TRUNK,
	TRUNK_DK,
	TRUNK_HI,
	WOOD,
	WOOD_DK,
	WOOD_HI,
	fill_ellipse,
	fill_polygon,
	fill_rect,
	logical_canvas,
	outline,
	paint_scale,
	pixel_line,
	px,
	save,
	speckles,
)

TILES = REPO_ROOT / "games/treasure-island/art/tiles"
SIZE = 32
NATIVE_SCALE = 2


def sand(rng: random.Random):
	im = logical_canvas(SIZE, SIZE, SAND_MID)
	fill_rect(im, 0, 0, 31, 2, SAND_HI)
	fill_rect(im, 0, 3, 31, 5, SAND_DRY)
	for y, color, phase in [
		(9, SAND_DARK, 2),
		(17, SAND_HI, 7),
		(25, SAND_DARK, 4),
	]:
		for x in range(-phase, SIZE, 10):
			pixel_line(im, [(max(0, x), y), (min(31, x + 6), y + 1)], color)
	speckles(im, 0, 5, SIZE, SIZE, [SAND_DARK, SAND_DRY, SAND_HI], 0.055, rng, (1, 1, 2))
	for x, y in [(5, 13), (21, 7), (27, 21)]:
		px(im, x, y, (134, 92, 52))
		px(im, x + 1, y, SAND_HI)
	return im


def dirt(rng: random.Random):
	im = logical_canvas(SIZE, SIZE, (91, 61, 39))
	fill_rect(im, 0, 0, 31, 2, LEAF_HI)
	fill_rect(im, 0, 3, 31, 5, LEAF)
	for x in range(0, SIZE, 5):
		height = 2 + (x * 3) % 4
		fill_polygon(im, [(x, 5), (x + 2, 5), (x + 1, 5 + height)], LEAF_DK)
	for points in [
		[(3, 11), (9, 15), (7, 24)],
		[(17, 7), (16, 17), (22, 27)],
		[(29, 12), (24, 18), (27, 31)],
	]:
		pixel_line(im, points, (130, 85, 43), 2)
		pixel_line(im, points[1:], (65, 43, 33))
	speckles(im, 0, 7, SIZE, SIZE, [(62, 43, 33), (122, 81, 46), (151, 103, 52)], 0.055, rng, (1, 2))
	return im


def wood(rng: random.Random):
	im = logical_canvas(SIZE, SIZE, WOOD)
	for y in (0, 15, 31):
		fill_rect(im, 0, y, 31, min(31, y + 1), WOOD_DK)
		if y < 31:
			fill_rect(im, 0, y + 2, 31, y + 2, WOOD_HI)
	fill_rect(im, 13, 1, 14, 14, TRUNK_DK)
	fill_rect(im, 23, 16, 24, 30, TRUNK_DK)
	for y, offset in [(7, 0), (22, 6)]:
		for x in range(offset, SIZE, 12):
			pixel_line(im, [(x, y), (min(31, x + 7), y + (x % 3) - 1)], TRUNK_HI)
	fill_ellipse(im, (4, 4, 9, 9), TRUNK_DK)
	fill_ellipse(im, (5, 5, 8, 8), TRUNK)
	fill_ellipse(im, (25, 20, 29, 24), TRUNK_DK)
	px(im, 27, 22, INK_BROWN)
	for x, y in [(2, 2), (17, 13), (20, 18), (30, 29)]:
		fill_rect(im, x, y, x + 1, y + 1, (64, 49, 42))
	return im


def rock(rng: random.Random):
	im = logical_canvas(SIZE, SIZE, ROCK_DK)
	facets = [
		([(0, 1), (10, 0), (14, 9), (7, 15), (0, 12)], ROCK),
		([(11, 0), (25, 0), (31, 6), (23, 13), (14, 9)], ROCK_HI),
		([(31, 7), (31, 19), (23, 20), (20, 13)], (89, 87, 101)),
		([(0, 13), (7, 16), (9, 28), (0, 31)], (92, 87, 96)),
		([(8, 15), (22, 13), (27, 24), (19, 31), (9, 28)], ROCK),
		([(27, 20), (31, 20), (31, 31), (20, 31)], ROCK_HI),
	]
	for points, color in facets:
		fill_polygon(im, points, color)
	for points in [
		[(14, 2), (13, 8), (18, 13), (17, 19)],
		[(3, 21), (9, 19), (13, 23)],
		[(27, 10), (24, 14), (29, 18)],
	]:
		pixel_line(im, points, ROCK_DK, 2)
	px(im, 5, 5, (190, 181, 173))
	speckles(im, 0, 0, SIZE, SIZE, [ROCK_DK, ROCK_HI], 0.025, rng)
	return im


def cave(rng: random.Random):
	im = logical_canvas(SIZE, SIZE, (72, 53, 52))
	blocks = [
		(0, 0, 12, 8, (94, 67, 61)),
		(13, 0, 27, 10, (61, 48, 53)),
		(28, 0, 31, 8, (101, 72, 63)),
		(0, 9, 8, 20, (57, 45, 49)),
		(9, 11, 22, 21, (91, 63, 57)),
		(23, 10, 31, 20, (64, 50, 54)),
		(0, 21, 14, 31, (99, 68, 58)),
		(15, 22, 27, 31, (65, 49, 50)),
		(28, 21, 31, 31, (105, 73, 59)),
	]
	for x0, y0, x1, y1, color in blocks:
		fill_rect(im, x0, y0, x1, y1, color)
		pixel_line(im, [(x0, y1), (x1, y1)], (44, 38, 44))
		pixel_line(im, [(x1, y0), (x1, y1)], (44, 38, 44))
	for points in [[(4, 3), (8, 6), (7, 11)], [(19, 13), (16, 17), (20, 21)], [(25, 24), (21, 28), (23, 31)]]:
		pixel_line(im, points, (130, 85, 66))
	speckles(im, 0, 0, SIZE, SIZE, [(48, 40, 45), (123, 82, 67)], 0.03, rng)
	return im


def ledge(name: str, material: str, rng: random.Random) -> None:
	im = logical_canvas(32, 16)
	if material == "sand":
		fill_rect(im, 0, 0, 31, 12, SAND_MID)
		fill_rect(im, 0, 0, 31, 2, SAND_HI)
		fill_rect(im, 0, 3, 31, 4, SAND_DRY)
		fill_rect(im, 0, 11, 31, 14, SAND_DARK)
		for x in range(1, 32, 7):
			fill_polygon(im, [(x, 11), (min(31, x + 4), 11), (x + 2, 15)], SAND_DARK)
		speckles(im, 0, 4, 32, 12, [SAND_HI, SAND_DARK], 0.06, rng)
	elif material == "dirt":
		fill_rect(im, 0, 0, 31, 13, (92, 61, 39))
		fill_rect(im, 0, 0, 31, 2, LEAF_HI)
		fill_rect(im, 0, 3, 31, 4, LEAF)
		for x in range(2, 32, 6):
			fill_polygon(im, [(x, 4), (x + 2, 4), (x + 1, 8 + x % 4)], LEAF_DK)
		pixel_line(im, [(4, 7), (10, 13), (9, 15)], TRUNK)
		pixel_line(im, [(23, 6), (19, 12), (22, 15)], TRUNK)
	elif material == "wood":
		fill_rect(im, 0, 0, 31, 13, WOOD)
		fill_rect(im, 0, 0, 31, 2, WOOD_HI)
		fill_rect(im, 0, 12, 31, 15, WOOD_DK)
		for x in (7, 19, 30):
			fill_rect(im, x, 2, min(31, x + 1), 12, TRUNK_DK)
		for x in (3, 15, 26):
			fill_rect(im, x, 6, x + 1, 7, INK_BROWN)
		pixel_line(im, [(9, 5), (15, 4)], TRUNK_HI)
	elif material == "rock":
		fill_rect(im, 0, 0, 31, 14, ROCK_DK)
		fill_polygon(im, [(0, 0), (12, 0), (15, 7), (9, 13), (0, 11)], ROCK_HI)
		fill_polygon(im, [(13, 0), (31, 0), (31, 9), (23, 14), (14, 7)], ROCK)
		pixel_line(im, [(0, 0), (31, 0)], (196, 187, 178), 2)
		pixel_line(im, [(15, 1), (14, 7), (18, 11)], ROCK_DK)
	else:
		fill_rect(im, 0, 0, 31, 14, (72, 53, 52))
		fill_rect(im, 0, 0, 31, 2, (125, 83, 67))
		for x0, x1, color in [(0, 9, (91, 61, 56)), (10, 21, (61, 47, 50)), (22, 31, (100, 67, 57))]:
			fill_rect(im, x0, 3, x1, 13, color)
			pixel_line(im, [(x1, 4), (x1, 13)], INK, 2)
		fill_rect(im, 0, 13, 31, 15, (43, 37, 42))
	save(im, TILES / f"{name}.png")


def pier() -> Image.Image:
	im = logical_canvas(32, 16, WOOD_DK)
	fill_rect(im, 0, 0, 31, 2, WOOD_HI)
	fill_rect(im, 0, 3, 31, 11, WOOD)
	fill_rect(im, 0, 12, 31, 15, TRUNK_DK)
	for x in (0, 10, 21, 31):
		fill_rect(im, x, 3, min(31, x + 1), 13, INK_BROWN)
	for x, y in [(4, 6), (16, 9), (27, 5)]:
		fill_rect(im, x, y, x + 1, y + 1, (85, 91, 96))
	pixel_line(im, [(2, 4), (8, 3)], TRUNK_HI)
	pixel_line(im, [(22, 8), (29, 7)], TRUNK_HI)
	return im


def bridge() -> Image.Image:
	im = logical_canvas(32, 16)
	pixel_line(im, [(0, 2), (31, 2)], (96, 63, 42), 2)
	pixel_line(im, [(0, 14), (31, 14)], INK_BROWN, 2)
	for x in range(-2, 34, 8):
		fill_polygon(im, [(x, 4), (x + 6, 4), (x + 5, 12), (x + 1, 12)], WOOD)
		pixel_line(im, [(x, 4), (x + 6, 4)], WOOD_HI, 2)
		pixel_line(im, [(x + 5, 5), (x + 5, 12)], WOOD_DK)
		px(im, x + 2, 6, INK_BROWN)
	return im


def roof() -> Image.Image:
	im = logical_canvas(32, 16, (132, 61, 38))
	fill_rect(im, 0, 0, 31, 2, (238, 151, 66))
	for y, phase, color in [
		(3, 0, (205, 102, 47)),
		(8, 4, (174, 75, 42)),
		(13, 0, (225, 126, 54)),
	]:
		fill_rect(im, 0, y, 31, min(15, y + 3), color)
		for x in range(phase, 32, 8):
			pixel_line(im, [(x, y), (min(31, x + 4), min(15, y + 3))], INK_BROWN)
	fill_rect(im, 0, 15, 31, 15, INK_BROWN)
	return im


def counter() -> Image.Image:
	im = logical_canvas(32, 52, WOOD_DK)
	fill_rect(im, 0, 0, 31, 5, TRUNK_DK)
	fill_rect(im, 0, 0, 31, 2, WOOD_HI)
	fill_rect(im, 2, 6, 29, 50, WOOD)
	for y in (8, 29, 49):
		fill_rect(im, 2, y, 29, y + 2, TRUNK_DK)
	for x in (2, 15, 29):
		fill_rect(im, x, 8, min(31, x + 1), 50, INK_BROWN)
	for x, y in [(8, 18), (23, 18), (8, 39), (23, 39)]:
		fill_rect(im, x, y, x + 2, y + 1, (210, 159, 76))
	return im


def barrel_stack() -> Image.Image:
	im = logical_canvas(32, 16, TRUNK_DK)
	for x0 in (-2, 14, 30):
		fill_ellipse(im, (x0, 1, x0 + 17, 14), WOOD_DK)
		fill_ellipse(im, (x0 + 2, 3, x0 + 15, 12), WOOD)
		fill_ellipse(im, (x0 + 5, 5, x0 + 12, 10), TRUNK)
		pixel_line(im, [(x0 + 2, 5), (x0 + 15, 5)], WOOD_HI)
	fill_rect(im, 0, 13, 31, 15, INK_BROWN)
	return im


def shelf() -> Image.Image:
	im = logical_canvas(32, 16)
	fill_rect(im, 0, 3, 31, 10, WOOD_DK)
	fill_rect(im, 0, 3, 31, 5, WOOD_HI)
	fill_rect(im, 2, 6, 29, 9, WOOD)
	for x in (5, 25):
		fill_polygon(im, [(x, 10), (x + 4, 10), (x + 2, 15)], TRUNK_DK)
	return im


def rail() -> Image.Image:
	im = logical_canvas(32, 16)
	fill_rect(im, 0, 1, 31, 5, WOOD_DK)
	fill_rect(im, 0, 1, 31, 2, WOOD_HI)
	fill_rect(im, 0, 12, 31, 15, TRUNK_DK)
	for x in (2, 15, 28):
		fill_rect(im, x, 3, x + 3, 14, WOOD)
		fill_rect(im, x, 3, x, 14, WOOD_HI)
	pixel_line(im, [(5, 12), (14, 5)], TRUNK_HI, 2)
	pixel_line(im, [(18, 5), (27, 12)], TRUNK_HI, 2)
	return im


def water() -> Image.Image:
	im = logical_canvas(32, 16, (30, 105, 158, 78))
	fill_rect(im, 0, 0, 31, 2, (*SEA_FOAM, 180))
	for x in range(-4, 32, 12):
		pixel_line(im, [(max(0, x), 5), (min(31, x + 6), 4), (min(31, x + 10), 5)], (*SEA_LIGHT, 150), 2)
	for x, y in [(6, 11), (20, 8), (28, 13)]:
		px(im, x, y, (*SEA_FOAM, 170))
		px(im, x, y + 1, (*SEA_MID, 110))
	fill_rect(im, 0, 14, 31, 15, (*SEA_DEEP, 105))
	return im


def zone_glow(color: tuple[int, int, int]) -> Image.Image:
	im = logical_canvas(32, 16)
	soft = (*color, 42)
	bright = (*color, 165)
	fill_rect(im, 0, 5, 31, 13, soft)
	for x in range(0, 32, 8):
		fill_rect(im, x, 3, min(31, x + 4), 4, bright)
	for x, y in [(3, 9), (15, 7), (27, 11)]:
		px(im, x, y, (*SEA_FOAM, 205))
		px(im, x - 1, y, bright)
		px(im, x + 1, y, bright)
	return im


def main() -> None:
	TILES.mkdir(parents=True, exist_ok=True)
	with paint_scale(NATIVE_SCALE):
		_write_tiles()


def _write_tiles() -> None:
	generators = {
		"sand": sand,
		"dirt": dirt,
		"wood": wood,
		"rock": rock,
		"cave": cave,
	}
	for index, (name, generate) in enumerate(generators.items()):
		save(generate(random.Random(70 + index)), TILES / f"{name}.png")
	for index, material in enumerate(("sand", "dirt", "wood", "rock", "cave")):
		ledge(f"{material}_ledge", material, random.Random(90 + index))
	special_tiles = {
		"pier": pier(),
		"bridge": bridge(),
		"roof": roof(),
		"counter": counter(),
		"barrel_stack": barrel_stack(),
		"shelf": shelf(),
		"rail": rail(),
		"water": water(),
		"zone_glow_green": zone_glow((93, 205, 92)),
		"zone_glow_blue": zone_glow((86, 207, 235)),
	}
	for name, image in special_tiles.items():
		save(image, TILES / f"{name}.png")
	print("tiles done")


if __name__ == "__main__":
	main()
