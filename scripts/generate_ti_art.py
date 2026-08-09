#!/usr/bin/env python3
"""Generate TI pixel art: tiles, items, hazards, dizzy frames, NPCs."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path("games/treasure-island/art")
TILES = ROOT / "tiles"
ITEMS = ROOT / "items"
HAZ = ROOT / "hazards"
NPC = ROOT / "npc"
PROPS = ROOT / "props"
DIZZY = Path("shared/sprites/dizzy")


def save(img: Image.Image, path: Path) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	img.save(path)
	print("wrote", path, img.size)


def tile(name: str, paint, size: int = 32) -> None:
	im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
	paint(ImageDraw.Draw(im), size)
	save(im, TILES / f"{name}.png")


def paint_sand(d: ImageDraw.ImageDraw, s: int) -> None:
	d.rectangle([0, 0, s - 1, s - 1], fill=(210, 180, 100, 255))
	for y in range(0, s, 4):
		for x in range(0, s, 4):
			if ((x + y) // 4) % 2:
				d.rectangle([x, y, x + 3, y + 3], fill=(195, 165, 85, 255))
	d.rectangle([0, 0, s - 1, 3], fill=(180, 140, 70, 255))


def paint_dirt(d: ImageDraw.ImageDraw, s: int) -> None:
	d.rectangle([0, 0, s - 1, s - 1], fill=(90, 65, 40, 255))
	for i in range(8):
		d.point((i * 4 + 2, (i * 7) % s), fill=(70, 50, 30, 255))
	d.rectangle([0, 0, s - 1, 4], fill=(60, 110, 50, 255))


def paint_wood(d: ImageDraw.ImageDraw, s: int) -> None:
	d.rectangle([0, 0, s - 1, s - 1], fill=(140, 95, 50, 255))
	for x in range(0, s, 8):
		d.line([(x, 0), (x, s)], fill=(110, 70, 35, 255), width=2)
	d.rectangle([0, 0, s - 1, 3], fill=(100, 65, 30, 255))


def paint_rock(d: ImageDraw.ImageDraw, s: int) -> None:
	d.rectangle([0, 0, s - 1, s - 1], fill=(90, 85, 95, 255))
	d.ellipse([4, 4, 20, 18], fill=(70, 65, 75, 255))
	d.ellipse([12, 10, 28, 26], fill=(100, 95, 105, 255))


def paint_cave(d: ImageDraw.ImageDraw, s: int) -> None:
	d.rectangle([0, 0, s - 1, s - 1], fill=(70, 55, 50, 255))
	for x in range(0, s, 6):
		d.ellipse([x, s - 10, x + 10, s - 1], fill=(55, 45, 40, 255))


def ledge(name: str, base: tuple[int, int, int]) -> None:
	im = Image.new("RGBA", (32, 16), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rectangle([0, 0, 31, 15], fill=base + (255,))
	hi = tuple(min(255, c + 30) for c in base) + (255,)
	lo = tuple(max(0, c - 25) for c in base) + (255,)
	d.rectangle([0, 0, 31, 3], fill=hi)
	d.rectangle([0, 12, 31, 15], fill=lo)
	save(im, TILES / f"{name}.png")


def mk_item(name: str, paint) -> None:
	im = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
	paint(ImageDraw.Draw(im))
	save(im, ITEMS / f"{name}.png")


def mk_haz(name: str, w: int, h: int, paint) -> None:
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	paint(ImageDraw.Draw(im))
	save(im, HAZ / f"{name}.png")


def main() -> None:
	for p in (TILES, ITEMS, HAZ, NPC, PROPS, DIZZY):
		p.mkdir(parents=True, exist_ok=True)

	tile("sand", paint_sand)
	tile("dirt", paint_dirt)
	tile("wood", paint_wood)
	tile("rock", paint_rock)
	tile("cave", paint_cave)
	ledge("sand_ledge", (200, 165, 90))
	ledge("dirt_ledge", (100, 75, 45))
	ledge("wood_ledge", (150, 100, 55))
	ledge("rock_ledge", (95, 90, 100))
	ledge("cave_ledge", (75, 60, 55))

	mk_item(
		"default",
		lambda d: (
			d.rectangle([4, 4, 11, 11], fill=(200, 200, 200, 255)),
			d.rectangle([5, 5, 10, 10], fill=(120, 120, 120, 255)),
		),
	)
	mk_item(
		"coin",
		lambda d: (
			d.ellipse([2, 2, 13, 13], fill=(230, 190, 40, 255)),
			d.ellipse([5, 5, 10, 10], fill=(255, 220, 80, 255)),
		),
	)
	mk_item(
		"snorkel",
		lambda d: (
			d.rectangle([3, 6, 12, 10], fill=(40, 100, 180, 255)),
			d.rectangle([7, 2, 9, 8], fill=(50, 140, 210, 255)),
			d.rectangle([2, 5, 13, 6], fill=(180, 40, 40, 255)),
		),
	)
	for i, col in enumerate(
		[(40, 140, 50), (50, 150, 60), (30, 120, 45), (60, 160, 70)], start=1
	):
		c = col

		def paint_plant(d, color=c):
			d.ellipse([4, 8, 11, 14], fill=color + (255,))
			d.rectangle([7, 3, 8, 10], fill=(80, 50, 30, 255))

		mk_item(f"plant_{i}", paint_plant)

	mk_item(
		"empty_chest",
		lambda d: (
			d.rectangle([2, 5, 13, 13], fill=(140, 90, 40, 255)),
			d.rectangle([2, 5, 13, 8], fill=(160, 110, 50, 255)),
			d.rectangle([7, 8, 9, 10], fill=(200, 170, 50, 255)),
		),
	)
	mk_item(
		"toothpaste",
		lambda d: (
			d.rectangle([5, 2, 10, 13], fill=(230, 230, 240, 255)),
			d.rectangle([5, 2, 10, 5], fill=(40, 140, 200, 255)),
		),
	)
	mk_item(
		"misty_window",
		lambda d: (
			d.rectangle([2, 2, 13, 13], fill=(80, 60, 40, 255)),
			d.rectangle([4, 4, 11, 11], fill=(160, 190, 210, 200)),
		),
	)
	mk_item(
		"mushrooms",
		lambda d: (
			d.ellipse([3, 5, 9, 11], fill=(200, 60, 60, 255)),
			d.rectangle([5, 10, 7, 14], fill=(220, 200, 160, 255)),
			d.ellipse([8, 7, 14, 12], fill=(180, 50, 50, 255)),
		),
	)
	mk_item(
		"wooden_rail_1",
		lambda d: (
			d.rectangle([1, 6, 14, 9], fill=(150, 100, 50, 255)),
			d.rectangle([2, 3, 4, 12], fill=(130, 85, 40, 255)),
			d.rectangle([11, 3, 13, 12], fill=(130, 85, 40, 255)),
		),
	)
	mk_item(
		"wooden_rail_2",
		lambda d: (
			d.rectangle([1, 6, 14, 9], fill=(160, 110, 55, 255)),
			d.rectangle([2, 3, 4, 12], fill=(140, 90, 45, 255)),
			d.rectangle([11, 3, 13, 12], fill=(140, 90, 45, 255)),
		),
	)
	mk_item(
		"tree_trunk_1",
		lambda d: (
			d.ellipse([3, 3, 12, 13], fill=(110, 75, 40, 255)),
			d.ellipse([5, 5, 10, 11], fill=(90, 60, 30, 255)),
		),
	)
	mk_item(
		"tree_trunk_2",
		lambda d: (
			d.ellipse([2, 4, 13, 13], fill=(100, 70, 35, 255)),
			d.rectangle([6, 2, 9, 6], fill=(80, 55, 30, 255)),
		),
	)
	mk_item(
		"glass_sword",
		lambda d: (
			d.polygon([(8, 1), (10, 10), (8, 12), (6, 10)], fill=(180, 220, 240, 255)),
			d.rectangle([6, 11, 10, 13], fill=(140, 100, 50, 255)),
			d.rectangle([7, 13, 9, 15], fill=(100, 70, 40, 255)),
		),
	)
	mk_item(
		"video_camera",
		lambda d: (
			d.rectangle([2, 5, 11, 12], fill=(50, 50, 60, 255)),
			d.ellipse([9, 6, 14, 11], fill=(30, 30, 40, 255)),
			d.rectangle([4, 3, 7, 5], fill=(80, 80, 90, 255)),
		),
	)
	mk_item(
		"salt_spade",
		lambda d: (
			d.rectangle([7, 1, 9, 10], fill=(140, 100, 50, 255)),
			d.polygon([(4, 9), (12, 9), (10, 14), (6, 14)], fill=(160, 160, 170, 255)),
		),
	)
	mk_item(
		"heavy_rock",
		lambda d: (
			d.ellipse([2, 3, 13, 13], fill=(180, 50, 40, 255)),
			d.ellipse([4, 5, 10, 10], fill=(210, 80, 60, 255)),
		),
	)
	mk_item(
		"dehydrated_boat",
		lambda d: (
			d.polygon([(2, 10), (14, 10), (12, 13), (4, 13)], fill=(180, 140, 70, 255)),
			d.rectangle([7, 4, 9, 10], fill=(100, 70, 40, 255)),
		),
	)
	mk_item(
		"empty_bucket",
		lambda d: (
			d.rectangle([4, 5, 11, 13], fill=(120, 120, 130, 255)),
			d.arc([4, 3, 11, 8], 0, 180, fill=(140, 140, 150, 255)),
		),
	)
	mk_item(
		"holy_bible",
		lambda d: (
			d.rectangle([4, 2, 12, 14], fill=(80, 40, 30, 255)),
			d.rectangle([5, 3, 11, 13], fill=(160, 50, 40, 255)),
			d.line([(8, 4), (8, 12)], fill=(220, 180, 60, 255)),
		),
	)
	mk_item(
		"woodcutters_axe",
		lambda d: (
			d.rectangle([7, 2, 9, 12], fill=(120, 80, 40, 255)),
			d.polygon([(3, 3), (10, 2), (10, 7), (3, 6)], fill=(160, 160, 170, 255)),
		),
	)
	mk_item(
		"cursed_treasure",
		lambda d: (
			d.rectangle([3, 6, 12, 13], fill=(180, 140, 40, 255)),
			d.ellipse([5, 3, 10, 8], fill=(80, 200, 80, 255)),
		),
	)
	mk_item(
		"outboard_motor",
		lambda d: (
			d.rectangle([4, 4, 11, 12], fill=(40, 40, 50, 255)),
			d.ellipse([6, 1, 10, 5], fill=(60, 60, 70, 255)),
			d.rectangle([7, 12, 9, 15], fill=(30, 30, 40, 255)),
		),
	)
	mk_item(
		"golden_key",
		lambda d: (
			d.ellipse([3, 3, 9, 9], fill=(230, 190, 40, 255)),
			d.rectangle([8, 5, 13, 7], fill=(230, 190, 40, 255)),
			d.rectangle([11, 7, 13, 10], fill=(230, 190, 40, 255)),
		),
	)
	mk_item(
		"dynamite",
		lambda d: (
			d.rectangle([5, 2, 10, 13], fill=(200, 40, 40, 255)),
			d.rectangle([6, 1, 9, 3], fill=(40, 40, 40, 255)),
			d.line([(7, 0), (10, 2)], fill=(255, 200, 50, 255)),
		),
	)
	mk_item(
		"detonator",
		lambda d: (
			d.rectangle([4, 6, 11, 13], fill=(40, 40, 50, 255)),
			d.rectangle([6, 3, 9, 7], fill=(200, 40, 40, 255)),
			d.ellipse([6, 8, 10, 12], fill=(80, 80, 90, 255)),
		),
	)
	mk_item(
		"microwave",
		lambda d: (
			d.rectangle([2, 4, 13, 13], fill=(180, 180, 190, 255)),
			d.rectangle([4, 6, 10, 11], fill=(40, 40, 50, 255)),
			d.rectangle([11, 6, 12, 11], fill=(100, 100, 110, 255)),
		),
	)
	mk_item(
		"petrol",
		lambda d: (
			d.rectangle([4, 3, 11, 13], fill=(40, 120, 50, 255)),
			d.rectangle([6, 1, 9, 4], fill=(30, 30, 30, 255)),
		),
	)
	mk_item(
		"gold_bag",
		lambda d: (
			d.ellipse([3, 5, 12, 14], fill=(180, 140, 50, 255)),
			d.rectangle([6, 2, 9, 6], fill=(140, 100, 40, 255)),
		),
	)
	mk_item(
		"ignition_key",
		lambda d: (
			d.ellipse([3, 4, 9, 10], fill=(160, 160, 170, 255)),
			d.rectangle([8, 6, 13, 8], fill=(160, 160, 170, 255)),
		),
	)
	mk_item(
		"skull_1",
		lambda d: (
			d.ellipse([3, 3, 12, 12], fill=(230, 220, 200, 255)),
			d.point((6, 7), fill=(20, 20, 20, 255)),
			d.point((10, 7), fill=(20, 20, 20, 255)),
		),
	)
	mk_item(
		"skull_2",
		lambda d: (
			d.ellipse([3, 3, 12, 12], fill=(220, 210, 190, 255)),
			d.rectangle([6, 7, 7, 8], fill=(20, 20, 20, 255)),
			d.rectangle([9, 7, 10, 8], fill=(20, 20, 20, 255)),
		),
	)
	mk_item(
		"magazine",
		lambda d: (
			d.rectangle([3, 2, 12, 14], fill=(40, 80, 160, 255)),
			d.rectangle([4, 4, 11, 7], fill=(220, 220, 230, 255)),
		),
	)

	def paint_trap(d: ImageDraw.ImageDraw) -> None:
		d.polygon([(0, 23), (4, 6), (8, 23)], fill=(180, 40, 40, 255))
		d.polygon([(8, 23), (12, 4), (16, 23)], fill=(200, 50, 50, 255))
		d.polygon([(16, 23), (20, 6), (24, 23)], fill=(180, 40, 40, 255))
		d.polygon([(22, 23), (26, 8), (28, 23)], fill=(160, 30, 30, 255))

	def paint_fish(d: ImageDraw.ImageDraw) -> None:
		d.ellipse([2, 4, 28, 20], fill=(40, 100, 160, 255))
		d.polygon([(26, 12), (35, 4), (35, 20)], fill=(30, 80, 130, 255))
		d.ellipse([8, 8, 12, 12], fill=(240, 240, 240, 255))
		d.point((10, 10), fill=(10, 10, 10, 255))

	def paint_crab(d: ImageDraw.ImageDraw) -> None:
		d.ellipse([8, 6, 28, 20], fill=(200, 60, 40, 255))
		d.polygon([(2, 8), (10, 10), (10, 16), (2, 18)], fill=(180, 50, 30, 255))
		d.polygon([(34, 8), (26, 10), (26, 16), (34, 18)], fill=(180, 50, 30, 255))
		d.ellipse([12, 10, 16, 14], fill=(20, 20, 20, 255))
		d.ellipse([20, 10, 24, 14], fill=(20, 20, 20, 255))

	def paint_cuttle(d: ImageDraw.ImageDraw) -> None:
		d.ellipse([6, 4, 30, 20], fill=(140, 80, 160, 255))
		for i in range(5):
			d.line([(10 + i * 4, 18), (8 + i * 4, 27)], fill=(120, 60, 140, 255), width=2)
		d.ellipse([12, 8, 16, 12], fill=(240, 240, 100, 255))
		d.ellipse([20, 8, 24, 12], fill=(240, 240, 100, 255))

	mk_haz("trap", 28, 24, paint_trap)
	mk_haz("fish", 36, 24, paint_fish)
	mk_haz("crab", 36, 24, paint_crab)
	mk_haz("cuttlefish", 36, 28, paint_cuttle)

	def make_npc(name: str, body: tuple, head: tuple) -> None:
		im = Image.new("RGBA", (40, 64), (0, 0, 0, 0))
		d = ImageDraw.Draw(im)
		d.ellipse([8, 2, 32, 26], fill=head)
		d.rectangle([10, 22, 30, 56], fill=body)
		d.rectangle([6, 28, 12, 40], fill=head)
		d.rectangle([28, 28, 34, 40], fill=head)
		d.rectangle([12, 56, 18, 63], fill=(40, 30, 20, 255))
		d.rectangle([22, 56, 28, 63], fill=(40, 30, 20, 255))
		d.ellipse([14, 10, 18, 14], fill=(20, 20, 20, 255))
		d.ellipse([22, 10, 26, 14], fill=(20, 20, 20, 255))
		save(im, NPC / f"{name}.png")

	make_npc("shopkeeper", (120, 70, 40, 255), (230, 190, 150, 255))
	make_npc("taxman", (40, 40, 50, 255), (220, 180, 140, 255))
	im = Image.open(NPC / "shopkeeper.png")
	ImageDraw.Draw(im).rectangle([12, 32, 28, 50], fill=(200, 200, 210, 255))
	im.save(NPC / "shopkeeper.png")
	im = Image.open(NPC / "taxman.png")
	d = ImageDraw.Draw(im)
	d.rectangle([14, 36, 26, 48], fill=(30, 30, 35, 255))
	d.rectangle([18, 4, 22, 10], fill=(20, 20, 20, 255))
	im.save(NPC / "taxman.png")

	def dizzy_frame(name: str, leg_offset: int = 0) -> None:
		im = Image.new("RGBA", (16, 20), (0, 0, 0, 0))
		px = im.load()
		body = (220, 40, 30, 255)
		hi = (255, 100, 80, 255)
		sh = (150, 25, 20, 255)
		glove = (250, 240, 210, 255)
		shoe = (230, 200, 40, 255)
		eye = (15, 10, 15, 255)

		def setp(x: int, y: int, c: tuple) -> None:
			if 0 <= x < 16 and 0 <= y < 20:
				px[x, y] = c

		for x in range(4, 12):
			for y in range(5, 15):
				setp(x, y, sh if x <= 6 else (hi if x >= 9 else body))
		for x in range(3, 13):
			for y in range(3, 6):
				setp(x, y, hi if x > 8 else body)
		for x in range(6, 10):
			setp(x, 8, eye)
		for x in range(2, 5):
			for y in range(11, 13):
				setp(x, y, glove)
		for x in range(11, 14):
			for y in range(11, 13):
				setp(x, y, glove)
		for x in range(5, 8):
			for y in range(17 + leg_offset, 20):
				setp(x, y, shoe)
		for x in range(9, 12):
			for y in range(17 - leg_offset, 20):
				setp(x, y, shoe)
		save(im.resize((48, 60), Image.NEAREST), DIZZY / f"{name}.png")

	dizzy_frame("idle", 0)
	dizzy_frame("walk_a", 1)
	dizzy_frame("walk_b", -1)

	def dizzy_air(name: str, mode: str) -> None:
		im = Image.new("RGBA", (16, 20), (0, 0, 0, 0))
		px = im.load()
		body = (220, 40, 30, 255)
		hi = (255, 100, 80, 255)
		sh = (150, 25, 20, 255)
		glove = (250, 240, 210, 255)
		shoe = (230, 200, 40, 255)
		eye = (15, 10, 15, 255)

		def setp(x: int, y: int, c: tuple) -> None:
			if 0 <= x < 16 and 0 <= y < 20:
				px[x, y] = c

		if mode == "jump":
			for x in range(4, 12):
				for y in range(4, 14):
					setp(x, y, sh if x <= 6 else (hi if x >= 9 else body))
			for x in range(6, 10):
				setp(x, 7, eye)
			for x in range(3, 6):
				for y in range(9, 11):
					setp(x, y, glove)
			for x in range(10, 13):
				for y in range(9, 11):
					setp(x, y, glove)
			for x in range(5, 8):
				for y in range(14, 17):
					setp(x, y, shoe)
			for x in range(9, 12):
				for y in range(14, 17):
					setp(x, y, shoe)
		elif mode == "roll_a":
			for x in range(2, 14):
				for y in range(6, 16):
					setp(x, y, sh if y <= 8 else (hi if y >= 13 else body))
			for x in range(7, 11):
				setp(x, 10, eye)
			for x in range(1, 4):
				for y in range(9, 12):
					setp(x, y, glove)
			for x in range(12, 15):
				for y in range(9, 12):
					setp(x, y, shoe)
		else:  # roll_b — flipped limbs
			for x in range(2, 14):
				for y in range(6, 16):
					setp(x, y, hi if y <= 8 else (sh if y >= 13 else body))
			for x in range(5, 9):
				setp(x, 10, eye)
			for x in range(1, 4):
				for y in range(9, 12):
					setp(x, y, shoe)
			for x in range(12, 15):
				for y in range(9, 12):
					setp(x, y, glove)
		save(im.resize((48, 60), Image.NEAREST), DIZZY / f"{name}.png")

	dizzy_air("jump", "jump")
	dizzy_air("roll_a", "roll_a")
	dizzy_air("roll_b", "roll_b")

	def mk_prop(name: str, w: int, h: int, paint) -> None:
		im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
		paint(ImageDraw.Draw(im))
		save(im, PROPS / f"{name}.png")

	def paint_boat(d: ImageDraw.ImageDraw) -> None:
		d.polygon([(4, 20), (60, 20), (56, 32), (8, 32)], fill=(120, 70, 35, 255))
		d.rectangle([8, 12, 52, 20], fill=(150, 95, 50, 255))
		d.rectangle([28, 4, 32, 12], fill=(90, 60, 30, 255))

	def paint_motor(d: ImageDraw.ImageDraw) -> None:
		d.rectangle([4, 2, 20, 18], fill=(50, 50, 55, 255))
		d.rectangle([8, 18, 16, 26], fill=(35, 35, 40, 255))
		d.ellipse([6, 4, 12, 10], fill=(80, 80, 90, 255))

	def paint_grave(d: ImageDraw.ImageDraw) -> None:
		d.rectangle([8, 10, 40, 46], fill=(150, 150, 155, 255))
		d.ellipse([8, 2, 40, 22], fill=(150, 150, 155, 255))
		d.rectangle([18, 18, 30, 22], fill=(90, 90, 95, 255))
		d.rectangle([22, 14, 26, 30], fill=(90, 90, 95, 255))

	def paint_totem(d: ImageDraw.ImageDraw) -> None:
		d.rectangle([10, 4, 22, 60], fill=(130, 80, 40, 255))
		for y in (8, 24, 40):
			d.ellipse([6, y, 26, y + 14], fill=(160, 100, 50, 255))
			d.ellipse([10, y + 4, 14, y + 8], fill=(20, 20, 20, 255))
			d.ellipse([18, y + 4, 22, y + 8], fill=(20, 20, 20, 255))

	def paint_hatch(d: ImageDraw.ImageDraw) -> None:
		d.rectangle([2, 2, 46, 14], fill=(100, 70, 40, 255))
		d.rectangle([4, 4, 44, 12], fill=(130, 90, 50, 255))
		d.ellipse([20, 5, 28, 11], fill=(70, 50, 30, 255))

	def paint_bubble(d: ImageDraw.ImageDraw) -> None:
		d.ellipse([2, 2, 14, 14], fill=(180, 220, 255, 160))
		d.ellipse([4, 4, 8, 8], fill=(240, 250, 255, 200))

	def paint_barrel(d: ImageDraw.ImageDraw) -> None:
		d.ellipse([2, 2, 30, 14], fill=(120, 75, 40, 255))
		d.rectangle([2, 8, 30, 28], fill=(140, 90, 50, 255))
		d.ellipse([2, 22, 30, 34], fill=(100, 65, 35, 255))
		d.rectangle([2, 14, 30, 17], fill=(70, 45, 25, 255))

	def paint_door(d: ImageDraw.ImageDraw) -> None:
		d.rectangle([2, 2, 22, 38], fill=(90, 55, 30, 255))
		d.rectangle([4, 4, 20, 36], fill=(120, 75, 40, 255))
		d.ellipse([14, 18, 18, 22], fill=(200, 180, 60, 255))

	def paint_prop_rock(d: ImageDraw.ImageDraw) -> None:
		d.ellipse([2, 8, 46, 30], fill=(110, 105, 115, 255))
		d.ellipse([10, 4, 34, 22], fill=(130, 125, 135, 255))

	def paint_prop_stump(d: ImageDraw.ImageDraw) -> None:
		d.ellipse([2, 2, 30, 14], fill=(100, 70, 40, 255))
		d.rectangle([6, 8, 26, 28], fill=(120, 80, 45, 255))
		d.ellipse([4, 20, 28, 32], fill=(80, 55, 30, 255))

	def paint_prop_hut(d: ImageDraw.ImageDraw) -> None:
		d.polygon([(2, 20), (24, 4), (46, 20)], fill=(140, 60, 40, 255))
		d.rectangle([6, 20, 42, 44], fill=(180, 140, 90, 255))
		d.rectangle([18, 28, 30, 44], fill=(90, 55, 30, 255))

	mk_prop("boat", 64, 36, paint_boat)
	mk_prop("motor", 24, 28, paint_motor)
	mk_prop("grave", 48, 48, paint_grave)
	mk_prop("totem", 32, 64, paint_totem)
	mk_prop("hatch", 48, 16, paint_hatch)
	mk_prop("bubble", 16, 16, paint_bubble)
	mk_prop("barrel", 32, 36, paint_barrel)
	mk_prop("door", 24, 40, paint_door)
	mk_prop("rock", 48, 32, paint_prop_rock)
	mk_prop("stump", 32, 34, paint_prop_stump)
	mk_prop("hut", 48, 48, paint_prop_hut)
	print("art generation complete")


if __name__ == "__main__":
	main()
