#!/usr/bin/env python3
"""Shared pixel helpers for TI homage art (original, CC BY-NC — not a rip)."""
from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image, ImageDraw

# Repo root (parent of scripts/), so generators work from any cwd.
REPO_ROOT = Path(__file__).resolve().parent.parent

# Warm CPC-ish palette (original homage, not a dump of Codemasters assets)
SKY_TOP = (56, 120, 200)
SKY_MID = (90, 160, 220)
SKY_HORIZON = (140, 190, 230)
SEA_DEEP = (28, 70, 140)
SEA_MID = (40, 110, 170)
SEA_FOAM = (180, 220, 240)
SAND_DRY = (222, 188, 118)
SAND_MID = (205, 168, 95)
SAND_WET = (180, 145, 85)
SAND_DARK = (160, 125, 70)
LEAF = (40, 130, 55)
LEAF_DK = (25, 95, 40)
LEAF_HI = (70, 165, 70)
TRUNK = (120, 75, 40)
TRUNK_DK = (85, 50, 28)
TRUNK_HI = (150, 100, 55)
CLOUD = (245, 250, 255)
CLOUD_SH = (200, 215, 235)

EGG = (255, 220, 70)
EGG_HI = (255, 240, 140)
EGG_SH = (210, 160, 40)
BOOT = (200, 45, 35)
BOOT_HI = (230, 80, 60)
GLOVE = (250, 245, 230)
EYE = (25, 20, 30)
SMILE = (80, 40, 40)


def save(img: Image.Image, path: Path) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	img = img.convert("RGBA")
	img.save(path)
	print("wrote", path, img.size)


def new_canvas(w: int, h: int, fill=(0, 0, 0, 0)) -> Image.Image:
	return Image.new("RGBA", (w, h), fill)


def px(im: Image.Image, x: int, y: int, c: tuple) -> None:
	if 0 <= x < im.width and 0 <= y < im.height:
		im.putpixel((x, y), c if len(c) == 4 else (*c, 255))


def blend(a: tuple, b: tuple, t: float) -> tuple:
	t = max(0.0, min(1.0, t))
	return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3)) + (255,)


def dither_vgrad(im: Image.Image, y0: int, y1: int, c0: tuple, c1: tuple) -> None:
	h = max(1, y1 - y0)
	for y in range(y0, y1):
		t = (y - y0) / h
		base = blend(c0, c1, t)
		alt = blend(c0, c1, min(1.0, t + 0.04))
		for x in range(im.width):
			use = alt if ((x + y) & 1) and t < 0.95 else base
			px(im, x, y, use)


def fill_rect(im: Image.Image, x0: int, y0: int, x1: int, y1: int, c: tuple) -> None:
	d = ImageDraw.Draw(im)
	d.rectangle([x0, y0, x1, y1], fill=c if len(c) == 4 else (*c, 255))


def fill_ellipse(im: Image.Image, box: tuple, c: tuple) -> None:
	d = ImageDraw.Draw(im)
	d.ellipse(box, fill=c if len(c) == 4 else (*c, 255))


def draw_cloud(im: Image.Image, cx: int, cy: int, scale: float = 1.0) -> None:
	blobs = [(-18, 0, 22), (0, -6, 26), (16, 2, 20), (-6, 6, 18)]
	for ox, oy, r in blobs:
		rr = int(r * scale)
		fill_ellipse(
			im,
			(cx + int(ox * scale) - rr, cy + int(oy * scale) - rr // 2, cx + int(ox * scale) + rr, cy + int(oy * scale) + rr // 2),
			CLOUD,
		)
	# soft shadow underbelly
	for ox, oy, r in blobs:
		rr = int(r * scale * 0.7)
		fill_ellipse(
			im,
			(
				cx + int(ox * scale) - rr,
				cy + int(oy * scale) + rr // 3,
				cx + int(ox * scale) + rr,
				cy + int(oy * scale) + rr,
			),
			CLOUD_SH,
		)


def draw_palm(im: Image.Image, base_x: int, base_y: int) -> None:
	"""Layered palm — original silhouette, not a rip."""
	# trunk curve
	for i in range(78):
		t = i / 77
		x = base_x + int(math.sin(t * 1.4) * 6)
		y = base_y - i
		w = 7 - int(t * 3)
		for dx in range(-w, w + 1):
			shade = TRUNK_HI if dx < -1 else (TRUNK_DK if dx > 2 else TRUNK)
			px(im, x + dx, y, shade)
	# fronds
	fronds = [
		(-50, -20, 40),
		(-35, -40, 36),
		(0, -52, 34),
		(35, -38, 38),
		(52, -18, 42),
		(-20, -28, 30),
		(22, -30, 30),
	]
	crown_x, crown_y = base_x + 2, base_y - 78
	for fx, fy, length in fronds:
		steps = length
		for s in range(steps):
			t = s / max(1, steps - 1)
			x = crown_x + int(fx * t) + int(math.sin(t * 6) * 2)
			y = crown_y + int(fy * t) + int(t * t * 18)
			# leaf width taper
			half = max(1, int(4 * (1 - t)))
			for dy in range(-half, half + 1):
				col = LEAF_HI if dy < 0 else (LEAF_DK if dy > 1 else LEAF)
				px(im, x, y + dy, col)
				if s % 3 == 0:
					px(im, x + 1, y + dy, col)
	# coconuts
	fill_ellipse(im, (crown_x - 6, crown_y + 2, crown_x - 1, crown_y + 8), (90, 55, 30, 255))
	fill_ellipse(im, (crown_x + 1, crown_y + 3, crown_x + 6, crown_y + 9), (100, 60, 32, 255))


def draw_bird(im: Image.Image, x: int, y: int) -> None:
	px(im, x, y, (40, 40, 50, 255))
	px(im, x - 1, y + 1, (40, 40, 50, 255))
	px(im, x + 1, y + 1, (40, 40, 50, 255))


def speckles(im: Image.Image, x0: int, y0: int, x1: int, y1: int, colors: list, density: float, rng: random.Random) -> None:
	area = max(1, (x1 - x0) * (y1 - y0))
	n = int(area * density)
	for _ in range(n):
		x = rng.randint(x0, x1 - 1)
		y = rng.randint(y0, y1 - 1)
		px(im, x, y, rng.choice(colors))
