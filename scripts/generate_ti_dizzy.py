#!/usr/bin/env python3
"""Original homage Dizzy — round yellow egg, gloves, red boots (not a rip)."""
from __future__ import annotations

from pathlib import Path

from PIL import Image

from ti_art_lib import REPO_ROOT, px, save

DIZZY = REPO_ROOT / "shared/sprites/dizzy"
SRC_W, SRC_H = 22, 28
SCALE = 3  # 66×84


def blank() -> Image.Image:
	return Image.new("RGBA", (SRC_W, SRC_H), (0, 0, 0, 0))


def _egg_color(x: int, y: int, cx: float, cy: float) -> tuple:
	# Radial shading on yellow egg
	nx = (x - cx) / 7.2
	ny = (y - cy) / 9.0
	r2 = nx * nx + ny * ny
	if r2 > 1.0:
		return (0, 0, 0, 0)
	# highlight top-right, shadow bottom-left
	hi = max(0.0, 0.55 - ((x - (cx + 2)) ** 2 + (y - (cy - 3)) ** 2) / 40.0)
	sh = max(0.0, ((cx - 3 - x) ** 2 + (y - (cy + 4)) ** 2) / 80.0)
	r = int(min(255, 255 - sh * 40 + hi * 10))
	g = int(min(255, 215 - sh * 50 + hi * 25))
	b = int(min(255, 55 - sh * 20 + hi * 40))
	return (r, g, b, 255)


def body(im: Image.Image, y_off: int = 0, squash: float = 1.0) -> None:
	cx, cy = 10.5, 12.5 + y_off
	for y in range(SRC_H):
		for x in range(SRC_W):
			nx = (x - cx) / (7.2 * squash)
			ny = (y - cy) / 9.0
			if nx * nx + ny * ny <= 1.0:
				px(im, x, y, _egg_color(x, y, cx, cy))
	# outline
	for y in range(SRC_H):
		for x in range(SRC_W):
			c = im.getpixel((x, y))
			if c[3] == 0:
				continue
			for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
				xx, yy = x + dx, y + dy
				if 0 <= xx < SRC_W and 0 <= yy < SRC_H:
					if im.getpixel((xx, yy))[3] == 0:
						# soft edge darken
						px(im, x, y, (max(0, c[0] - 35), max(0, c[1] - 40), max(0, c[2] - 10), 255))
						break


def face(im: Image.Image, y_off: int = 0) -> None:
	# eyes (friendly dots)
	for x, y in ((7, 10 + y_off), (8, 10 + y_off), (12, 10 + y_off), (13, 10 + y_off)):
		px(im, x, y, (25, 20, 30, 255))
	# pupils gleam
	px(im, 8, 10 + y_off, (60, 50, 40, 255))
	px(im, 13, 10 + y_off, (60, 50, 40, 255))
	# smile
	px(im, 9, 13 + y_off, (90, 50, 40, 255))
	px(im, 10, 14 + y_off, (90, 50, 40, 255))
	px(im, 11, 13 + y_off, (90, 50, 40, 255))


def gloves(im: Image.Image, lx: int, rx: int, y: int) -> None:
	for x in range(lx, lx + 3):
		for dy in range(2):
			px(im, x, y + dy, (250, 245, 230, 255))
			if dy == 0:
				px(im, x, y + dy, (255, 255, 245, 255))
	for x in range(rx, rx + 3):
		for dy in range(2):
			px(im, x, y + dy, (250, 245, 230, 255))


def boots(im: Image.Image, lx: int, rx: int, y: int) -> None:
	for x in range(lx, lx + 4):
		px(im, x, y, (190, 40, 35, 255))
		px(im, x, y + 1, (220, 70, 50, 255) if x < lx + 2 else (170, 35, 30, 255))
	for x in range(rx, rx + 4):
		px(im, x, y, (190, 40, 35, 255))
		px(im, x, y + 1, (220, 70, 50, 255) if x < rx + 2 else (170, 35, 30, 255))


def export(name: str, im: Image.Image) -> None:
	save(im.resize((SRC_W * SCALE, SRC_H * SCALE), Image.NEAREST), DIZZY / f"{name}.png")


def main() -> None:
	DIZZY.mkdir(parents=True, exist_ok=True)

	idle = blank()
	body(idle)
	face(idle)
	gloves(idle, 1, 17, 15)
	boots(idle, 5, 12, 23)
	export("idle", idle)

	w0 = blank()
	body(w0)
	face(w0)
	gloves(w0, 2, 16, 14)
	boots(w0, 4, 13, 23)
	px(w0, 13, 22, (190, 40, 35, 255))
	export("walk_a", w0)

	w1 = blank()
	body(w1)
	face(w1)
	gloves(w1, 1, 17, 16)
	boots(w1, 6, 11, 23)
	px(w1, 5, 22, (190, 40, 35, 255))
	export("walk_b", w1)

	jp = blank()
	body(jp, -1)
	face(jp, -1)
	gloves(jp, 2, 16, 12)
	boots(jp, 7, 10, 20)
	export("jump", jp)

	r0 = blank()
	body(r0, 0, squash=1.15)
	for x in range(6, 15):
		px(r0, x, 12, (25, 20, 30, 255))
	boots(r0, 15, 15, 14)
	export("roll_a", r0)

	r1 = blank()
	body(r1, 0, squash=1.15)
	for x in range(6, 15):
		px(r1, x, 13, (25, 20, 30, 255))
	gloves(r1, 1, 1, 13)
	export("roll_b", r1)

	print("dizzy done")


if __name__ == "__main__":
	main()
