#!/usr/bin/env python3
"""High-effort original TI biome backdrops (512×384). Homage style, not a rip."""
from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image, ImageDraw

from ti_art_lib import (
	REPO_ROOT,
	LEAF,
	LEAF_DK,
	SAND_DARK,
	SAND_DRY,
	SAND_MID,
	SAND_WET,
	SEA_DEEP,
	SEA_FOAM,
	SEA_MID,
	SKY_HORIZON,
	SKY_MID,
	SKY_TOP,
	TRUNK,
	TRUNK_DK,
	blend,
	dither_vgrad,
	draw_bird,
	draw_cloud,
	draw_palm,
	fill_ellipse,
	fill_rect,
	new_canvas,
	px,
	save,
	speckles,
)

BACKDROPS = REPO_ROOT / "games/treasure-island/art/backdrops"
W, H = 512, 384


def beach(rng: random.Random) -> Image.Image:
	im = new_canvas(W, H)
	# sky
	dither_vgrad(im, 0, 150, SKY_TOP, SKY_MID)
	dither_vgrad(im, 150, 210, SKY_MID, SKY_HORIZON)
	draw_cloud(im, 90, 48, 1.1)
	draw_cloud(im, 250, 36, 0.85)
	draw_cloud(im, 400, 55, 1.0)
	draw_bird(im, 160, 70)
	draw_bird(im, 175, 68)
	# distant sea band
	for y in range(210, 248):
		t = (y - 210) / 38
		c = blend(SEA_MID, SEA_DEEP, t)
		for x in range(W):
			if (x + y * 3) % 17 == 0:
				c2 = blend(c[:3], SEA_FOAM[:3], 0.25)
				px(im, x, y, c2)
			else:
				px(im, x, y, c)
	# waves
	for i, y in enumerate(range(248, 268)):
		for x in range(W):
			wave = math.sin(x * 0.08 + i * 0.7) * 2
			yy = y + int(wave)
			foam = (x + i * 5) % 23 < 3
			px(im, x, yy, SEA_FOAM if foam else SEA_MID)
	# wet sand then dry
	fill_rect(im, 0, 268, W - 1, 300, (*SAND_WET, 255))
	dither_vgrad(im, 300, H, SAND_MID, SAND_DRY)
	speckles(im, 0, 300, W, H, [SAND_DARK, SAND_WET, (235, 205, 140)], 0.02, rng)
	# shoreline darker edge
	for x in range(W):
		px(im, x, 268, SAND_DARK)
		if x % 4 == 0:
			px(im, x, 269, SEA_FOAM)
	draw_palm(im, 420, 318)
	# second smaller palm for depth
	draw_palm(im, 455, 330)
	# distant islet
	fill_ellipse(im, (300, 200, 360, 218), (50, 110, 70, 255))
	fill_ellipse(im, (310, 190, 340, 210), (40, 100, 55, 255))
	# small dune grass
	for gx in (40, 70, 110, 300, 340):
		for i in range(8):
			px(im, gx + i // 2, 312 - i, LEAF if i % 2 == 0 else LEAF_DK)
			px(im, gx + 1 + i // 2, 312 - i, LEAF_DK)
	return im


def tree(rng: random.Random) -> Image.Image:
	im = new_canvas(W, H)
	# sky peeking through leaves
	dither_vgrad(im, 0, 120, (100, 160, 210), (140, 180, 220))
	# layered canopy
	for cx, cy, r, col in [
		(80, 70, 75, LEAF_DK),
		(200, 50, 95, LEAF),
		(340, 65, 85, LEAF_DK),
		(460, 80, 70, LEAF),
		(260, 100, 70, LEAF),
		(140, 110, 55, LEAF_DK),
	]:
		fill_ellipse(im, (cx - r, cy - r // 2, cx + r, cy + r // 2), (*col, 255))
	# thick trunks with bark notches
	for tx in (110, 250, 390):
		for y in range(100, 310):
			for dx in range(-7, 8):
				c = TRUNK_DK if dx > 3 else (TRUNK if dx > -3 else (150, 100, 55))
				px(im, tx + dx, y, c)
			if y % 14 == 0:
				px(im, tx + 4, y, (70, 45, 25, 255))
	# rope bridges / platforms
	for y, x0, x1 in [(200, 50, 220), (170, 200, 380), (240, 320, 500), (280, 80, 280)]:
		fill_rect(im, x0, y, x1, y + 7, (130, 85, 45, 255))
		fill_rect(im, x0, y, x1, y + 2, (170, 115, 65, 255))
		for x in range(x0, x1, 10):
			px(im, x, y + 8, (90, 60, 30, 255))
	# hut silhouettes on platforms
	for hx, hy in [(90, 175), (300, 145)]:
		fill_rect(im, hx, hy, hx + 40, hy + 24, (160, 110, 60, 255))
		for i in range(20):
			px(im, hx + i, hy - 8 + abs(i - 10) // 2, (140, 60, 40, 255))
	dither_vgrad(im, 310, H, (70, 50, 30), (95, 70, 40))
	speckles(im, 0, 310, W, H, [(50, 35, 20), (110, 80, 45)], 0.015, rng)
	return im


def ocean(rng: random.Random) -> Image.Image:
	im = new_canvas(W, H)
	dither_vgrad(im, 0, H, (10, 40, 90), (30, 100, 150))
	# caustic-ish highlights
	for y in range(0, H, 3):
		for x in range(0, W, 4):
			if (x * 7 + y * 13 + rng.randint(0, 3)) % 11 == 0:
				px(im, x, y, (80, 180, 220, 180))
	# seabed
	dither_vgrad(im, 300, H, (40, 70, 60), (80, 100, 50))
	for i in range(12):
		x = rng.randint(20, 490)
		fill_ellipse(im, (x, 320, x + 30, 350), (60, 90, 55, 255))
	# bubbles
	for _ in range(40):
		x, y = rng.randint(10, 500), rng.randint(20, 280)
		r = rng.randint(1, 3)
		fill_ellipse(im, (x, y, x + r * 2, y + r * 2), (200, 230, 255, 120))
	return im


def cavern(rng: random.Random) -> Image.Image:
	im = new_canvas(W, H, (35, 28, 32, 255))
	dither_vgrad(im, 0, H, (25, 20, 28), (55, 42, 38))
	# rock arches
	d = ImageDraw.Draw(im)
	for x0, x1, yb in [(0, 90, 220), (420, 512, 200), (180, 330, 80)]:
		d.polygon([(x0, 0), (x1, 0), (x1 - 20, yb), (x0 + 20, yb)], fill=(45, 35, 40, 255))
	# stalactites
	for x in range(30, 500, 28):
		h = 20 + (x * 3) % 40
		d.polygon([(x, 0), (x + 10, 0), (x + 5, h)], fill=(60, 48, 45, 255))
	# floor
	dither_vgrad(im, 300, H, (50, 40, 35), (70, 55, 45))
	speckles(im, 0, 300, W, H, [(40, 30, 28), (90, 70, 55)], 0.02, rng)
	# torch glow
	for r, a in [(80, 40), (50, 70), (25, 110)]:
		fill_ellipse(im, (70 - r, 250 - r, 70 + r, 250 + r), (255, 140, 40, a))
	return im


def hut(rng: random.Random) -> Image.Image:
	im = new_canvas(W, H)
	dither_vgrad(im, 0, H, (90, 55, 35), (140, 95, 55))
	# wood planks
	for y in range(0, H, 14):
		fill_rect(im, 0, y, W - 1, y + 12, (150, 100, 55, 255))
		fill_rect(im, 0, y, W - 1, y + 2, (170, 120, 70, 255))
		fill_rect(im, 0, y + 11, W - 1, y + 12, (100, 65, 35, 255))
		for x in range(0, W, 64):
			fill_rect(im, x, y, x + 2, y + 12, (90, 55, 30, 255))
	# window light
	fill_rect(im, 360, 60, 470, 160, (220, 200, 120, 255))
	fill_rect(im, 368, 68, 462, 152, (180, 210, 230, 255))
	# shelves shadow
	fill_rect(im, 40, 180, 220, 188, (80, 50, 30, 255))
	fill_rect(im, 40, 240, 220, 248, (80, 50, 30, 255))
	speckles(im, 0, 0, W, H, [(120, 80, 40)], 0.004, rng)
	return im


def main() -> None:
	rng = random.Random(42)
	BACKDROPS.mkdir(parents=True, exist_ok=True)
	save(beach(rng), BACKDROPS / "beach.png")
	save(tree(rng), BACKDROPS / "tree.png")
	save(ocean(rng), BACKDROPS / "ocean.png")
	save(cavern(rng), BACKDROPS / "cavern.png")
	save(hut(rng), BACKDROPS / "hut.png")
	print("backdrops done")


if __name__ == "__main__":
	main()
