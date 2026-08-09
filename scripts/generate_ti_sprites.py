#!/usr/bin/env python3
"""Items, hazards, NPCs, props — richer original pixel icons."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

from ti_art_lib import REPO_ROOT, new_canvas, save

ROOT = REPO_ROOT / "games/treasure-island/art"
ITEMS = ROOT / "items"
HAZ = ROOT / "hazards"
NPC = ROOT / "npc"
PROPS = ROOT / "props"


def item(name: str, paint) -> None:
	im = new_canvas(16, 16)
	paint(im, ImageDraw.Draw(im))
	save(im, ITEMS / f"{name}.png")


def main() -> None:
	for p in (ITEMS, HAZ, NPC, PROPS):
		p.mkdir(parents=True, exist_ok=True)

	item("default", lambda im, d: d.rectangle([4, 4, 11, 11], fill=(200, 200, 200, 255)))
	item(
		"coin",
		lambda im, d: (
			d.ellipse([1, 1, 14, 14], fill=(200, 150, 20, 255)),
			d.ellipse([3, 3, 12, 12], fill=(255, 215, 60, 255)),
			d.ellipse([5, 5, 8, 8], fill=(255, 240, 140, 255)),
		),
	)
	item(
		"snorkel",
		lambda im, d: (
			d.rectangle([2, 5, 13, 10], fill=(30, 90, 170, 255)),
			d.rectangle([3, 6, 12, 9], fill=(50, 140, 210, 255)),
			d.rectangle([7, 1, 9, 6], fill=(40, 120, 190, 255)),
			d.ellipse([6, 0, 10, 3], fill=(60, 160, 220, 255)),
		),
	)
	item(
		"salt_spade",
		lambda im, d: (
			d.rectangle([7, 2, 9, 11], fill=(140, 100, 50, 255)),
			d.polygon([(4, 10), (12, 10), (10, 15), (6, 15)], fill=(90, 90, 100, 255)),
		),
	)
	item(
		"glass_sword",
		lambda im, d: (
			d.polygon([(8, 1), (10, 1), (10, 11), (8, 11)], fill=(160, 220, 255, 255)),
			d.rectangle([6, 11, 12, 13], fill=(180, 150, 60, 255)),
			d.rectangle([7, 13, 9, 15], fill=(120, 80, 40, 255)),
		),
	)
	item(
		"woodcutters_axe",
		lambda im, d: (
			d.rectangle([7, 4, 9, 14], fill=(120, 80, 40, 255)),
			d.polygon([(3, 3), (13, 3), (12, 7), (4, 7)], fill=(160, 160, 170, 255)),
		),
	)
	item(
		"holy_bible",
		lambda im, d: (
			d.rectangle([3, 2, 12, 14], fill=(90, 40, 30, 255)),
			d.rectangle([4, 3, 11, 13], fill=(140, 60, 45, 255)),
			d.rectangle([7, 5, 9, 11], fill=(220, 190, 80, 255)),
		),
	)
	item(
		"dynamite",
		lambda im, d: (
			d.rectangle([4, 4, 11, 13], fill=(200, 50, 40, 255)),
			d.rectangle([5, 3, 10, 4], fill=(40, 40, 40, 255)),
			d.line([(8, 1), (8, 3)], fill=(255, 220, 80, 255)),
		),
	)
	item(
		"detonator",
		lambda im, d: (
			d.rectangle([3, 6, 12, 13], fill=(60, 60, 70, 255)),
			d.rectangle([5, 3, 7, 6], fill=(200, 40, 40, 255)),
			d.rectangle([9, 4, 11, 6], fill=(40, 200, 80, 255)),
		),
	)
	item(
		"golden_key",
		lambda im, d: (
			d.ellipse([3, 2, 10, 9], fill=(230, 190, 40, 255)),
			d.ellipse([5, 4, 8, 7], fill=(0, 0, 0, 0)),
			d.rectangle([8, 5, 14, 7], fill=(230, 190, 40, 255)),
			d.rectangle([12, 7, 14, 10], fill=(230, 190, 40, 255)),
		),
	)
	item(
		"video_camera",
		lambda im, d: (
			d.rectangle([2, 5, 11, 12], fill=(50, 50, 55, 255)),
			d.ellipse([9, 6, 14, 11], fill=(30, 30, 35, 255)),
			d.rectangle([4, 3, 7, 5], fill=(80, 80, 90, 255)),
		),
	)
	item(
		"microwave",
		lambda im, d: (
			d.rectangle([1, 4, 14, 13], fill=(180, 180, 185, 255)),
			d.rectangle([3, 6, 10, 11], fill=(40, 40, 50, 255)),
			d.rectangle([11, 6, 13, 8], fill=(80, 200, 80, 255)),
		),
	)
	item(
		"cursed_treasure",
		lambda im, d: (
			d.rectangle([2, 6, 13, 13], fill=(160, 110, 40, 255)),
			d.rectangle([3, 4, 12, 7], fill=(200, 150, 50, 255)),
			d.ellipse([6, 7, 9, 10], fill=(40, 200, 80, 255)),
		),
	)
	item(
		"gold_bag",
		lambda im, d: (
			d.ellipse([3, 5, 12, 14], fill=(200, 160, 40, 255)),
			d.polygon([(5, 5), (10, 5), (8, 2)], fill=(160, 100, 40, 255)),
		),
	)
	item(
		"dehydrated_boat",
		lambda im, d: (
			d.polygon([(2, 9), (14, 9), (12, 13), (4, 13)], fill=(130, 80, 40, 255)),
			d.rectangle([4, 6, 12, 9], fill=(160, 110, 55, 255)),
		),
	)
	item(
		"outboard_motor",
		lambda im, d: (
			d.rectangle([5, 2, 11, 10], fill=(50, 50, 55, 255)),
			d.rectangle([7, 10, 9, 14], fill=(40, 40, 45, 255)),
		),
	)
	item(
		"petrol",
		lambda im, d: (
			d.rectangle([4, 3, 11, 13], fill=(200, 160, 40, 255)),
			d.rectangle([6, 1, 9, 3], fill=(80, 80, 80, 255)),
			d.rectangle([5, 6, 10, 9], fill=(40, 40, 40, 255)),
		),
	)
	item(
		"ignition_key",
		lambda im, d: (
			d.ellipse([3, 3, 9, 9], fill=(180, 180, 190, 255)),
			d.rectangle([8, 5, 14, 7], fill=(180, 180, 190, 255)),
		),
	)

	# plants / junk — varied greens and browns
	for i, col in enumerate(
		[(50, 140, 60), (70, 120, 50), (40, 100, 70), (90, 140, 40)], 1
	):
		item(
			f"plant_{i}",
			lambda im, d, c=col: (
				d.rectangle([7, 8, 9, 14], fill=(100, 70, 40, 255)),
				d.ellipse([4, 2, 12, 10], fill=(*c, 255)),
			),
		)
	for i in (1, 2):
		item(
			f"skull_{i}",
			lambda im, d: (
				d.ellipse([3, 2, 12, 12], fill=(230, 220, 200, 255)),
				d.ellipse([5, 5, 7, 7], fill=(20, 20, 20, 255)),
				d.ellipse([9, 5, 11, 7], fill=(20, 20, 20, 255)),
			),
		)
	for i in (1, 2):
		item(
			f"tree_trunk_{i}",
			lambda im, d: d.rectangle([5, 2, 10, 14], fill=(120, 80, 45, 255)),
		)
	for i in (1, 2):
		item(
			f"wooden_rail_{i}",
			lambda im, d: d.rectangle([2, 6, 13, 10], fill=(140, 95, 50, 255)),
		)
	item("mushrooms", lambda im, d: (
		d.ellipse([3, 4, 9, 9], fill=(200, 60, 60, 255)),
		d.rectangle([5, 8, 7, 13], fill=(230, 220, 200, 255)),
		d.ellipse([8, 6, 13, 10], fill=(220, 80, 70, 255)),
	))
	item("misty_window", lambda im, d: (
		d.rectangle([2, 2, 13, 13], fill=(140, 180, 200, 200)),
		d.rectangle([3, 3, 12, 12], fill=(200, 220, 230, 180)),
	))
	item("empty_bucket", lambda im, d: (
		d.polygon([(4, 5), (12, 5), (11, 13), (5, 13)], fill=(120, 120, 130, 255)),
	))
	item("empty_chest", lambda im, d: (
		d.rectangle([2, 6, 13, 13], fill=(140, 90, 40, 255)),
		d.rectangle([3, 4, 12, 7], fill=(160, 110, 50, 255)),
	))
	item("heavy_rock", lambda im, d: d.ellipse([2, 4, 13, 13], fill=(110, 105, 115, 255)))
	item("toothpaste", lambda im, d: d.rectangle([5, 2, 10, 14], fill=(240, 240, 245, 255)))
	item("magazine", lambda im, d: (
		d.rectangle([3, 2, 12, 14], fill=(40, 100, 180, 255)),
		d.rectangle([4, 4, 11, 8], fill=(230, 230, 240, 255)),
	))

	# hazards
	def haz(name, w, h, paint):
		im = new_canvas(w, h)
		paint(ImageDraw.Draw(im))
		save(im, HAZ / f"{name}.png")

	haz(
		"trap",
		32,
		24,
		lambda d: (
			d.polygon([(4, 20), (16, 2), (28, 20)], fill=(140, 40, 40, 255)),
			d.polygon([(10, 20), (16, 8), (22, 20)], fill=(180, 60, 50, 255)),
		),
	)
	haz(
		"fish",
		40,
		24,
		lambda d: (
			d.ellipse([2, 4, 28, 20], fill=(40, 110, 170, 255)),
			d.polygon([(26, 12), (38, 4), (38, 20)], fill=(30, 90, 140, 255)),
			d.ellipse([8, 8, 12, 12], fill=(240, 240, 240, 255)),
			d.point((10, 10), fill=(10, 10, 10, 255)),
		),
	)
	haz(
		"crab",
		40,
		24,
		lambda d: (
			d.ellipse([10, 6, 30, 20], fill=(210, 70, 45, 255)),
			d.polygon([(2, 8), (12, 10), (12, 16), (2, 18)], fill=(190, 55, 35, 255)),
			d.polygon([(38, 8), (28, 10), (28, 16), (38, 18)], fill=(190, 55, 35, 255)),
			d.ellipse([14, 10, 18, 14], fill=(20, 20, 20, 255)),
			d.ellipse([22, 10, 26, 14], fill=(20, 20, 20, 255)),
		),
	)
	haz(
		"cuttlefish",
		40,
		28,
		lambda d: (
			d.ellipse([6, 4, 32, 20], fill=(150, 85, 170, 255)),
			*[d.line([(12 + i * 4, 18), (10 + i * 4, 26)], fill=(120, 60, 140, 255), width=2) for i in range(5)],
			d.ellipse([12, 8, 16, 12], fill=(240, 240, 100, 255)),
			d.ellipse([20, 8, 24, 12], fill=(240, 240, 100, 255)),
		),
	)

	# NPCs
	def npc(name, body, head, accent=None):
		im = new_canvas(48, 72)
		d = ImageDraw.Draw(im)
		d.ellipse([10, 2, 38, 30], fill=head)
		d.rectangle([12, 26, 36, 58], fill=body)
		d.rectangle([8, 32, 14, 44], fill=head)
		d.rectangle([34, 32, 40, 44], fill=head)
		d.rectangle([14, 58, 22, 70], fill=(50, 35, 25, 255))
		d.rectangle([26, 58, 34, 70], fill=(50, 35, 25, 255))
		d.ellipse([16, 12, 22, 18], fill=(20, 20, 20, 255))
		d.ellipse([26, 12, 32, 18], fill=(20, 20, 20, 255))
		if accent:
			d.rectangle([14, 36, 34, 52], fill=accent)
		save(im, NPC / f"{name}.png")

	npc("shopkeeper", (130, 75, 42, 255), (235, 195, 155, 255), (210, 210, 220, 255))
	npc("taxman", (45, 45, 55, 255), (225, 185, 145, 255), (30, 30, 35, 255))

	# props
	def prop(name, w, h, paint):
		im = new_canvas(w, h)
		paint(ImageDraw.Draw(im))
		save(im, PROPS / f"{name}.png")

	prop("boat", 72, 40, lambda d: (
		d.polygon([(4, 22), (68, 22), (62, 36), (10, 36)], fill=(125, 75, 38, 255)),
		d.rectangle([10, 12, 58, 22], fill=(155, 100, 52, 255)),
		d.rectangle([32, 4, 36, 12], fill=(95, 60, 30, 255)),
	))
	prop("motor", 28, 32, lambda d: (
		d.rectangle([4, 2, 24, 20], fill=(55, 55, 60, 255)),
		d.rectangle([10, 20, 18, 30], fill=(40, 40, 45, 255)),
	))
	prop("grave", 48, 52, lambda d: (
		d.rectangle([8, 14, 40, 50], fill=(155, 155, 160, 255)),
		d.ellipse([8, 2, 40, 28], fill=(155, 155, 160, 255)),
		d.rectangle([18, 20, 30, 24], fill=(90, 90, 95, 255)),
		d.rectangle([22, 16, 26, 34], fill=(90, 90, 95, 255)),
	))
	prop("totem", 36, 72, lambda d: (
		d.rectangle([12, 4, 24, 70], fill=(135, 85, 42, 255)),
		*[
			(
				d.ellipse([6, y, 30, y + 16], fill=(165, 105, 52, 255)),
				d.ellipse([10, y + 4, 15, y + 9], fill=(20, 20, 20, 255)),
				d.ellipse([21, y + 4, 26, y + 9], fill=(20, 20, 20, 255)),
			)
			for y in (6, 28, 50)
		],
	))
	prop("hatch", 48, 18, lambda d: (
		d.rectangle([2, 2, 46, 16], fill=(110, 75, 42, 255)),
		d.rectangle([4, 4, 44, 14], fill=(145, 100, 55, 255)),
		d.ellipse([20, 6, 28, 12], fill=(70, 50, 30, 255)),
	))
	prop("bubble", 16, 16, lambda d: (
		d.ellipse([1, 1, 14, 14], fill=(180, 220, 255, 150)),
		d.ellipse([3, 3, 7, 7], fill=(240, 250, 255, 200)),
	))
	prop("barrel", 32, 40, lambda d: (
		d.ellipse([2, 2, 30, 14], fill=(130, 80, 42, 255)),
		d.rectangle([2, 8, 30, 32], fill=(150, 95, 52, 255)),
		d.ellipse([2, 26, 30, 38], fill=(110, 70, 38, 255)),
		d.rectangle([2, 16, 30, 19], fill=(70, 45, 25, 255)),
	))
	prop("door", 28, 44, lambda d: (
		d.rectangle([2, 2, 26, 42], fill=(100, 60, 32, 255)),
		d.rectangle([4, 4, 24, 40], fill=(130, 80, 42, 255)),
		d.ellipse([16, 20, 22, 26], fill=(210, 180, 60, 255)),
	))
	prop("rock", 48, 32, lambda d: (
		d.ellipse([2, 8, 46, 30], fill=(115, 110, 120, 255)),
		d.ellipse([10, 4, 36, 22], fill=(135, 130, 140, 255)),
	))
	prop("stump", 32, 36, lambda d: (
		d.ellipse([2, 2, 30, 14], fill=(105, 72, 40, 255)),
		d.rectangle([6, 8, 26, 30], fill=(125, 85, 48, 255)),
	))
	prop("hut", 56, 52, lambda d: (
		d.polygon([(2, 24), (28, 4), (54, 24)], fill=(150, 65, 42, 255)),
		d.rectangle([8, 24, 48, 50], fill=(190, 150, 95, 255)),
		d.rectangle([20, 32, 36, 50], fill=(95, 55, 30, 255)),
	))
	print("sprites done")


if __name__ == "__main__":
	main()
