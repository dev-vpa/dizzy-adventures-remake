#!/usr/bin/env python3
"""Shared helpers and palette for original Treasure Island homage pixel art."""
from __future__ import annotations

import math
import random
from contextlib import contextmanager
from pathlib import Path
from typing import Iterable, Iterator, Sequence

from PIL import Image, ImageDraw

# Every generated path is rooted here so scripts are safe to run from any cwd.
REPO_ROOT = Path(__file__).resolve().parent.parent

# Deliberately compact warm CPC/Speccy-inspired palette. These are original
# project colours, not sampled from or traced over any commercial game asset.
INK = (28, 24, 36)
INK_BLUE = (24, 38, 58)
INK_BROWN = (55, 35, 30)

SKY_TOP = (45, 87, 164)
SKY_MID = (64, 132, 196)
SKY_HORIZON = (139, 196, 216)
SUN = (255, 220, 112)
CLOUD = (246, 240, 210)
CLOUD_HI = (255, 252, 233)
CLOUD_SH = (178, 199, 216)

SEA_DEEP = (20, 54, 112)
SEA_MID = (28, 105, 159)
SEA_LIGHT = (58, 160, 190)
SEA_FOAM = (190, 231, 224)

SAND_DRY = (226, 188, 105)
SAND_HI = (246, 215, 139)
SAND_MID = (196, 151, 77)
SAND_WET = (153, 119, 70)
SAND_DARK = (112, 78, 48)

LEAF = (43, 126, 65)
LEAF_DK = (22, 75, 52)
LEAF_HI = (90, 174, 75)
LEAF_LIME = (151, 191, 75)
TRUNK = (126, 77, 43)
TRUNK_DK = (74, 45, 35)
TRUNK_HI = (181, 118, 57)

ROCK = (104, 98, 112)
ROCK_DK = (61, 55, 69)
ROCK_HI = (151, 142, 143)
WOOD = (145, 89, 47)
WOOD_DK = (82, 49, 34)
WOOD_HI = (202, 132, 63)

EGG = (248, 202, 54)
EGG_HI = (255, 238, 121)
EGG_SH = (199, 137, 30)
EGG_EDGE = (117, 73, 31)
BOOT = (190, 45, 43)
BOOT_HI = (239, 79, 58)
BOOT_DK = (104, 28, 38)
GLOVE = (244, 239, 216)
GLOVE_HI = (255, 253, 235)
GLOVE_SH = (177, 185, 176)
EYE = INK
SMILE = (99, 43, 37)

GOLD = (240, 178, 38)
GOLD_HI = (255, 228, 94)
GOLD_DK = (139, 78, 26)
METAL = (150, 165, 172)
METAL_HI = (221, 229, 220)
METAL_DK = (73, 78, 91)

_BAYER_4 = (
	(0, 8, 2, 10),
	(12, 4, 14, 6),
	(3, 11, 1, 9),
	(15, 7, 13, 5),
)

# Generators author in a compact logical grid; paint_scale draws straight into
# the final native pixel size (no separate PNG upscale step).
_PAINT_SCALE = 1


@contextmanager
def paint_scale(scale: int) -> Iterator[int]:
	"""Draw logical coordinates into a scale× native canvas until the block exits."""
	global _PAINT_SCALE
	if scale < 1:
		raise ValueError("paint_scale must be >= 1")
	previous = _PAINT_SCALE
	_PAINT_SCALE = scale
	try:
		yield scale
	finally:
		_PAINT_SCALE = previous


def paint_scale_value() -> int:
	return _PAINT_SCALE


def rgba(color: Sequence[int], alpha: int = 255) -> tuple[int, int, int, int]:
	if len(color) == 4:
		return int(color[0]), int(color[1]), int(color[2]), int(color[3])
	return int(color[0]), int(color[1]), int(color[2]), alpha


def shade(color: Sequence[int], amount: int) -> tuple[int, int, int]:
	return tuple(max(0, min(255, int(channel) + amount)) for channel in color[:3])


def blend(a: Sequence[int], b: Sequence[int], t: float) -> tuple[int, int, int, int]:
	t = max(0.0, min(1.0, t))
	return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3)) + (255,)


def save(img: Image.Image, path: Path) -> None:
	resolved = path.resolve()
	if REPO_ROOT not in resolved.parents:
		raise ValueError(f"Generated art must stay under REPO_ROOT: {resolved}")
	resolved.parent.mkdir(parents=True, exist_ok=True)
	output = img.convert("RGBA")
	output.save(resolved, format="PNG", compress_level=9)
	print("wrote", resolved.relative_to(REPO_ROOT), output.size)


def new_canvas(w: int, h: int, fill=(0, 0, 0, 0)) -> Image.Image:
	"""Create a canvas in *native* pixels (already final size)."""
	return Image.new("RGBA", (w, h), rgba(fill))


def logical_canvas(lw: int, lh: int, fill=(0, 0, 0, 0)) -> Image.Image:
	"""Create a native canvas for a logical lw×lh authoring grid at current paint_scale."""
	s = _PAINT_SCALE
	return new_canvas(lw * s, lh * s, fill)


def _native_box(x0: int, y0: int, x1: int, y1: int) -> tuple[int, int, int, int]:
	s = _PAINT_SCALE
	return (
		int(x0) * s,
		int(y0) * s,
		int(x1) * s + (s - 1),
		int(y1) * s + (s - 1),
	)


def px(im: Image.Image, x: int, y: int, color: Sequence[int]) -> None:
	s = _PAINT_SCALE
	if s == 1:
		if 0 <= x < im.width and 0 <= y < im.height:
			im.putpixel((x, y), rgba(color))
		return
	nx, ny = int(x) * s, int(y) * s
	ImageDraw.Draw(im).rectangle([nx, ny, nx + s - 1, ny + s - 1], fill=rgba(color))


def fill_rect(
	im: Image.Image,
	x0: int,
	y0: int,
	x1: int,
	y1: int,
	color: Sequence[int],
) -> None:
	ImageDraw.Draw(im).rectangle(list(_native_box(x0, y0, x1, y1)), fill=rgba(color))


def fill_ellipse(im: Image.Image, box: Sequence[int], color: Sequence[int]) -> None:
	x0, y0, x1, y1 = box
	ImageDraw.Draw(im).ellipse(_native_box(x0, y0, x1, y1), fill=rgba(color))


def fill_polygon(
	im: Image.Image,
	points: Iterable[tuple[int, int]],
	color: Sequence[int],
) -> None:
	s = _PAINT_SCALE
	native = [(int(p[0]) * s, int(p[1]) * s) for p in points]
	ImageDraw.Draw(im).polygon(native, fill=rgba(color))


def pixel_eye(im: Image.Image, x: int, y: int, look: int = 0) -> None:
	"""Draw a calm 5×4 stepped oval eye with a small directional pupil."""
	look = max(-1, min(1, int(look)))
	fill_rect(im, x + 1, y, x + 3, y, EYE)
	fill_rect(im, x, y + 1, x + 4, y + 2, EYE)
	fill_rect(im, x + 1, y + 3, x + 3, y + 3, EYE)
	fill_rect(im, x + 1, y + 1, x + 3, y + 2, GLOVE_HI)
	pupil_x = x + 2 + look
	px(im, pupil_x, y + 2, EYE)


def pixel_line(
	im: Image.Image,
	points: Iterable[tuple[int, int]],
	color: Sequence[int],
	width: int = 1,
) -> None:
	s = _PAINT_SCALE
	native = [(int(p[0]) * s, int(p[1]) * s) for p in points]
	ImageDraw.Draw(im).line(native, fill=rgba(color), width=max(1, int(width) * s))


def dither_vgrad(
	im: Image.Image,
	y0: int,
	y1: int,
	c0: Sequence[int],
	c1: Sequence[int],
	levels: int = 6,
) -> None:
	"""Ordered vertical gradient using a small, finite colour ramp."""
	levels = max(2, levels)
	s = _PAINT_SCALE
	lw = im.width // s
	lh = im.height // s
	height = max(1, y1 - y0)
	for y in range(max(0, y0), min(lh, y1)):
		t = (y - y0) / max(1, height - 1)
		position = t * (levels - 1)
		low = int(math.floor(position))
		high = min(levels - 1, low + 1)
		frac = position - low
		for x in range(lw):
			threshold = (_BAYER_4[y & 3][x & 3] + 0.5) / 16.0
			band = high if frac > threshold else low
			px(im, x, y, blend(c0, c1, band / (levels - 1)))


def outline(
	im: Image.Image,
	color: Sequence[int] = INK,
	diagonal: bool = True,
	alpha_threshold: int = 24,
) -> None:
	"""Add a one-logical-pixel outline behind existing non-transparent pixels."""
	s = _PAINT_SCALE
	offsets = [(-1, 0), (1, 0), (0, -1), (0, 1)]
	if diagonal:
		offsets.extend([(-1, -1), (1, -1), (-1, 1), (1, 1)])

	if s == 1:
		source = im.copy()
		for y in range(im.height):
			for x in range(im.width):
				if source.getpixel((x, y))[3] >= alpha_threshold:
					continue
				for dx, dy in offsets:
					nx, ny = x + dx, y + dy
					if (
						0 <= nx < im.width
						and 0 <= ny < im.height
						and source.getpixel((nx, ny))[3] >= alpha_threshold
					):
						px(im, x, y, color)
						break
		im.alpha_composite(source)
		return

	source = im.copy()
	lw, lh = im.width // s, im.height // s

	def logical_opaque(lx: int, ly: int) -> bool:
		return source.getpixel((lx * s, ly * s))[3] >= alpha_threshold

	for ly in range(lh):
		for lx in range(lw):
			if logical_opaque(lx, ly):
				continue
			for dx, dy in offsets:
				nx, ny = lx + dx, ly + dy
				if 0 <= nx < lw and 0 <= ny < lh and logical_opaque(nx, ny):
					px(im, lx, ly, color)
					break
	im.alpha_composite(source)


def draw_cloud(im: Image.Image, cx: int, cy: int, scale: float = 1.0) -> None:
	"""Blocky layered cloud intended for a 256×192 logical backdrop."""
	blobs = [(-12, 1, 12), (-3, -4, 14), (8, -2, 12), (16, 2, 8)]
	for ox, oy, radius in blobs:
		r = max(2, int(radius * scale))
		x = cx + int(ox * scale)
		y = cy + int((oy + 3) * scale)
		fill_ellipse(im, (x - r, y - r // 2, x + r, y + r // 2), CLOUD_SH)
	for ox, oy, radius in blobs:
		r = max(2, int(radius * scale))
		x = cx + int(ox * scale)
		y = cy + int(oy * scale)
		fill_ellipse(im, (x - r, y - r // 2, x + r, y + r // 2), CLOUD)
	fill_rect(
		im,
		cx - int(11 * scale),
		cy - int(4 * scale),
		cx + int(5 * scale),
		cy - int(2 * scale),
		CLOUD_HI,
	)
	fill_rect(
		im,
		cx - int(16 * scale),
		cy + int(5 * scale),
		cx + int(17 * scale),
		cy + int(6 * scale),
		CLOUD_SH,
	)


def draw_palm(
	im: Image.Image,
	base_x: int,
	base_y: int,
	scale: float = 1.0,
	mirror: bool = False,
) -> None:
	"""Original layered palm silhouette with a chunky curved trunk."""
	direction = -1 if mirror else 1
	height = max(24, int(58 * scale))
	trunk: list[tuple[int, int]] = []
	for i in range(height + 1):
		t = i / height
		x = base_x + direction * int(math.sin(t * 1.35) * 6 * scale)
		trunk.append((x, base_y - i))
	pixel_line(im, trunk, TRUNK_DK, max(3, int(7 * scale)))
	pixel_line(im, [(x - direction, y) for x, y in trunk], TRUNK, max(2, int(4 * scale)))
	pixel_line(im, [(x - direction * 2, y) for x, y in trunk], TRUNK_HI, 1)
	for i in range(7, height, max(5, int(8 * scale))):
		x, y = trunk[i]
		pixel_line(
			im,
			[(x - int(3 * scale), y), (x + int(3 * scale), y - 2)],
			TRUNK_DK,
			1,
		)

	crown_x, crown_y = trunk[-1]
	fronds = [
		(-35, -7),
		(-26, -19),
		(-10, -28),
		(9, -27),
		(27, -17),
		(37, -4),
		(-19, 2),
		(22, 2),
	]
	for index, (fx, fy) in enumerate(fronds):
		fx *= direction
		mid = (
			crown_x + int(fx * 0.45 * scale),
			crown_y + int((fy - 5) * 0.55 * scale),
		)
		end = (
			crown_x + int(fx * scale),
			crown_y + int((fy + 7) * scale),
		)
		pixel_line(im, [(crown_x, crown_y), mid, end], LEAF_DK, max(2, int(3 * scale)))
		pixel_line(im, [(crown_x, crown_y - 1), mid, end], LEAF, max(1, int(2 * scale)))
		if index % 2 == 0:
			pixel_line(im, [(crown_x, crown_y - 2), mid], LEAF_HI, 1)
		for step in (0.35, 0.55, 0.73):
			sx = int(mid[0] + (end[0] - mid[0]) * step)
			sy = int(mid[1] + (end[1] - mid[1]) * step)
			leaf_len = max(2, int(5 * scale * (1.0 - step * 0.35)))
			pixel_line(im, [(sx, sy), (sx - direction * leaf_len, sy + leaf_len)], LEAF_DK, 1)
			pixel_line(im, [(sx, sy), (sx + direction * leaf_len, sy + leaf_len)], LEAF_HI, 1)
	for ox, oy in [(-4, 1), (1, 2), (4, 5)]:
		r = max(1, int(2 * scale))
		fill_ellipse(
			im,
			(crown_x + ox - r, crown_y + oy - r, crown_x + ox + r, crown_y + oy + r),
			TRUNK_DK,
		)


def draw_bird(im: Image.Image, x: int, y: int, color: Sequence[int] = INK_BLUE) -> None:
	pixel_line(im, [(x - 4, y), (x - 1, y - 2), (x, y)], color)
	pixel_line(im, [(x, y), (x + 2, y - 2), (x + 5, y)], color)


def speckles(
	im: Image.Image,
	x0: int,
	y0: int,
	x1: int,
	y1: int,
	colors: Sequence[Sequence[int]],
	density: float,
	rng: random.Random,
	sizes: Sequence[int] = (1,),
) -> None:
	"""Deterministic clustered pixels; useful for sand, bark, and stone."""
	s = _PAINT_SCALE
	lw, lh = im.width // s, im.height // s
	x0, y0 = max(0, x0), max(0, y0)
	x1, y1 = min(lw, x1), min(lh, y1)
	if x1 <= x0 or y1 <= y0:
		return
	area = (x1 - x0) * (y1 - y0)
	for _ in range(int(area * density)):
		x = rng.randrange(x0, x1)
		y = rng.randrange(y0, y1)
		size = max(1, rng.choice(tuple(sizes)))
		fill_rect(im, x, y, min(x1 - 1, x + size - 1), min(y1 - 1, y + size - 1), rng.choice(tuple(colors)))


def star_points(
	cx: int,
	cy: int,
	outer: float,
	inner: float,
	points: int = 5,
	rotation: float = -math.pi / 2,
) -> list[tuple[int, int]]:
	result: list[tuple[int, int]] = []
	for i in range(points * 2):
		radius = outer if i % 2 == 0 else inner
		angle = rotation + math.pi * i / points
		result.append((int(round(cx + math.cos(angle) * radius)), int(round(cy + math.sin(angle) * radius))))
	return result
