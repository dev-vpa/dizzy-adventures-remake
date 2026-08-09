#!/usr/bin/env python3
"""Tile textures with richer dither / edge detail."""
from __future__ import annotations

import random
from pathlib import Path

from ti_art_lib import REPO_ROOT, new_canvas, px, save, speckles

TILES = REPO_ROOT / "games/treasure-island/art/tiles"


def sand(rng: random.Random):
	im = new_canvas(32, 32, (215, 180, 105, 255))
	for y in range(32):
		for x in range(32):
			if (x + y) % 5 == 0:
				px(im, x, y, (200, 165, 90, 255))
	speckles(im, 0, 0, 32, 32, [(180, 140, 70), (230, 200, 130), (190, 155, 85)], 0.08, rng)
	for x in range(32):
		px(im, x, 0, (170, 130, 65, 255))
		px(im, x, 1, (190, 150, 80, 255))
	return im


def dirt(rng: random.Random):
	im = new_canvas(32, 32, (95, 68, 42, 255))
	speckles(im, 0, 0, 32, 32, [(70, 50, 30), (120, 85, 50)], 0.1, rng)
	for y in range(5):
		for x in range(32):
			px(im, x, y, (55, 120, 50, 255) if y < 3 else (70, 100, 45, 255))
	return im


def wood(rng: random.Random):
	im = new_canvas(32, 32, (145, 98, 52, 255))
	for x in range(0, 32, 8):
		for y in range(32):
			px(im, x, y, (110, 70, 35, 255))
			px(im, x + 1, y, (125, 80, 40, 255))
	speckles(im, 0, 0, 32, 32, [(160, 110, 60)], 0.03, rng)
	for x in range(32):
		px(im, x, 0, (100, 65, 30, 255))
	return im


def rock(rng: random.Random):
	im = new_canvas(32, 32, (105, 100, 110, 255))
	speckles(im, 0, 0, 32, 32, [(80, 75, 85), (130, 125, 135)], 0.12, rng)
	return im


def cave(rng: random.Random):
	im = new_canvas(32, 32, (75, 58, 52, 255))
	speckles(im, 0, 0, 32, 32, [(55, 42, 38), (95, 75, 65)], 0.1, rng)
	for x in range(0, 32, 7):
		for y in range(24, 32):
			px(im, x + (y % 3), y, (50, 40, 35, 255))
	return im


def ledge(name: str, base: tuple[int, int, int], rng: random.Random):
	im = new_canvas(32, 16, (*base, 255))
	hi = tuple(min(255, c + 35) for c in base)
	lo = tuple(max(0, c - 30) for c in base)
	for x in range(32):
		for y in range(3):
			px(im, x, y, (*hi, 255))
		for y in range(13, 16):
			px(im, x, y, (*lo, 255))
	speckles(im, 0, 3, 32, 13, [lo, hi], 0.05, rng)
	save(im, TILES / f"{name}.png")


def main() -> None:
	rng = random.Random(7)
	TILES.mkdir(parents=True, exist_ok=True)
	save(sand(rng), TILES / "sand.png")
	save(dirt(rng), TILES / "dirt.png")
	save(wood(rng), TILES / "wood.png")
	save(rock(rng), TILES / "rock.png")
	save(cave(rng), TILES / "cave.png")
	ledge("sand_ledge", (205, 168, 95), rng)
	ledge("dirt_ledge", (100, 72, 42), rng)
	ledge("wood_ledge", (150, 100, 55), rng)
	ledge("rock_ledge", (100, 95, 105), rng)
	ledge("cave_ledge", (78, 60, 52), rng)
	print("tiles done")


if __name__ == "__main__":
	main()
