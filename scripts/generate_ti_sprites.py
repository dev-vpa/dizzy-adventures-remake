#!/usr/bin/env python3
"""Original item, hazard, NPC, and prop pixel art for Treasure Island."""
from __future__ import annotations

from collections.abc import Callable

from PIL import Image, ImageDraw

from ti_art_lib import (
	BOOT,
	BOOT_DK,
	BOOT_HI,
	CLOUD_HI,
	CLOUD_SH,
	GLOVE,
	GLOVE_HI,
	GLOVE_SH,
	GOLD,
	GOLD_DK,
	GOLD_HI,
	INK,
	INK_BLUE,
	INK_BROWN,
	LEAF,
	LEAF_DK,
	LEAF_HI,
	LEAF_LIME,
	METAL,
	METAL_DK,
	METAL_HI,
	REPO_ROOT,
	ROCK,
	ROCK_DK,
	ROCK_HI,
	SAND_DARK,
	SAND_HI,
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
	new_canvas,
	outline,
	pixel_line,
	px,
	rgba,
	save,
	star_points,
)

ROOT = REPO_ROOT / "games/treasure-island/art"
ITEMS = ROOT / "items"
HAZARDS = ROOT / "hazards"
NPCS = ROOT / "npc"
PROPS = ROOT / "props"

ITEM_SIZE = 22
Paint = Callable[[Image.Image, ImageDraw.ImageDraw], None]


def item(name: str, paint: Paint, outline_color=INK) -> None:
	im = new_canvas(ITEM_SIZE, ITEM_SIZE)
	paint(im, ImageDraw.Draw(im))
	outline(im, outline_color, diagonal=True)
	save(im, ITEMS / f"{name}.png")


def sprite_asset(
	folder,
	name: str,
	width: int,
	height: int,
	paint: Paint,
	outline_color=INK,
	add_outline: bool = True,
) -> None:
	im = new_canvas(width, height)
	paint(im, ImageDraw.Draw(im))
	if add_outline:
		outline(im, outline_color, diagonal=True)
	save(im, folder / f"{name}.png")


# ---------------------------------------------------------------------------
# Inventory and world items (22×22, so world rendering is crisp at 1:1).


def paint_default(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.rectangle((4, 5, 17, 18), fill=rgba(WOOD_DK))
	d.rectangle((5, 6, 16, 17), fill=rgba(WOOD))
	d.line((5, 7, 16, 16), fill=rgba(WOOD_HI), width=2)
	d.line((16, 7, 5, 16), fill=rgba(TRUNK_DK), width=2)
	d.rectangle((3, 9, 18, 11), fill=rgba(METAL_DK))
	d.rectangle((10, 5, 12, 18), fill=rgba(METAL))
	for x, y in [(5, 10), (16, 10), (11, 6), (11, 17)]:
		d.point((x, y), fill=rgba(METAL_HI))


def paint_coin(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	# Tall milled rim + stamped star reads unmistakably as a gold coin.
	d.ellipse((2, 1, 19, 20), fill=rgba(GOLD_DK))
	d.ellipse((3, 2, 18, 19), fill=rgba(GOLD))
	d.ellipse((5, 4, 16, 17), fill=rgba(GOLD_HI))
	d.ellipse((6, 5, 15, 16), fill=rgba((226, 153, 30)))
	d.polygon(star_points(11, 11, 4.5, 2.0, 5), fill=rgba(GOLD_DK))
	d.polygon(star_points(10, 10, 2.5, 1.0, 5), fill=rgba(GOLD_HI))
	d.arc((3, 2, 18, 19), 105, 245, fill=rgba((255, 244, 145)), width=2)
	d.point((6, 4), fill=rgba(CLOUD_HI))


def paint_snorkel(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.rectangle((3, 8, 16, 14), fill=rgba(INK_BLUE))
	d.rectangle((4, 9, 9, 13), fill=rgba(SEA_LIGHT))
	d.rectangle((11, 9, 15, 13), fill=rgba(SEA_LIGHT))
	d.rectangle((5, 9, 8, 10), fill=rgba(SEA_FOAM))
	d.rectangle((12, 9, 14, 10), fill=rgba(SEA_FOAM))
	d.rectangle((9, 10, 11, 11), fill=rgba(CLOUD_SH))
	d.line((16, 11, 18, 11, 18, 3), fill=rgba((223, 77, 55)), width=3)
	d.rectangle((17, 2, 20, 5), fill=rgba(BOOT_HI))
	d.rectangle((15, 14, 20, 17), fill=rgba(BOOT))
	d.rectangle((16, 15, 20, 15), fill=rgba((255, 130, 76)))


def paint_spade(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.arc((6, 1, 15, 8), 180, 360, fill=rgba(TRUNK_DK), width=3)
	d.line((8, 5, 13, 16), fill=rgba(TRUNK_DK), width=4)
	d.line((9, 5, 13, 15), fill=rgba(TRUNK_HI), width=2)
	d.polygon(((9, 14), (16, 12), (19, 16), (17, 20), (12, 20)), fill=rgba(METAL_DK))
	d.polygon(((11, 15), (16, 13), (17, 16), (15, 19), (12, 19)), fill=rgba(METAL_HI))


def paint_sword(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((4, 18), (6, 19), (17, 4), (17, 1), (14, 3)), fill=rgba((72, 138, 170)))
	d.polygon(((6, 17), (8, 17), (17, 3), (15, 4)), fill=rgba((162, 225, 235)))
	d.line((8, 15, 16, 4), fill=rgba(CLOUD_HI), width=1)
	d.line((3, 14, 10, 19), fill=rgba(GOLD_DK), width=3)
	d.line((5, 17, 2, 20), fill=rgba(TRUNK_DK), width=3)
	d.point((2, 20), fill=rgba(GOLD_HI))


def paint_axe(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.line((5, 19, 14, 5), fill=rgba(TRUNK_DK), width=4)
	d.line((6, 18, 14, 6), fill=rgba(TRUNK_HI), width=2)
	d.polygon(((9, 3), (17, 2), (20, 6), (16, 11), (11, 8)), fill=rgba(METAL_DK))
	d.polygon(((11, 4), (17, 3), (19, 6), (16, 9), (12, 7)), fill=rgba(METAL_HI))
	d.line((17, 3, 20, 6, 17, 9), fill=rgba(CLOUD_HI), width=1)


def paint_bible(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((4, 4), (15, 2), (18, 5), (18, 18), (7, 20), (4, 17)), fill=rgba((85, 35, 42)))
	d.polygon(((6, 5), (15, 4), (16, 17), (7, 18)), fill=rgba((142, 48, 48)))
	d.line((5, 18, 16, 16), fill=rgba(CLOUD_HI), width=2)
	d.line((6, 19, 17, 17), fill=rgba(GOLD_HI), width=1)
	d.rectangle((10, 7, 12, 15), fill=rgba(GOLD_HI))
	d.rectangle((8, 9, 14, 11), fill=rgba(GOLD_HI))
	d.line((5, 5, 6, 18), fill=rgba(GOLD_DK), width=2)


def paint_dynamite(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	for x, color in [(4, BOOT), (9, BOOT_HI), (14, BOOT)]:
		d.rounded_rectangle((x, 7, x + 4, 19), radius=1, fill=rgba(color))
		d.rectangle((x, 8, x + 1, 17), fill=rgba((238, 94, 59)))
	d.rectangle((3, 11, 19, 14), fill=rgba((88, 61, 42)))
	d.rectangle((4, 12, 18, 12), fill=rgba(GOLD_DK))
	d.line((16, 7, 16, 4, 19, 2), fill=rgba(INK_BROWN), width=2)
	d.polygon(star_points(19, 2, 3.0, 1.0, 5), fill=rgba((255, 190, 47)))
	d.point((19, 2), fill=rgba(CLOUD_HI))


def paint_detonator(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.rectangle((3, 9, 18, 19), fill=rgba(WOOD_DK))
	d.rectangle((5, 10, 16, 17), fill=rgba(WOOD))
	d.rectangle((7, 5, 9, 11), fill=rgba(METAL_DK))
	d.rectangle((6, 3, 10, 6), fill=rgba(BOOT_HI))
	d.rectangle((13, 7, 16, 10), fill=rgba(METAL))
	d.ellipse((13, 8, 15, 10), fill=rgba(GOLD_HI))
	d.line((16, 9, 20, 5), fill=rgba((52, 163, 104)), width=2)
	d.line((17, 11, 20, 14), fill=rgba((201, 64, 55)), width=2)
	d.rectangle((6, 14, 15, 16), fill=rgba(TRUNK_HI))


def paint_golden_key(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.ellipse((1, 3, 11, 13), fill=rgba(GOLD_DK))
	d.ellipse((3, 5, 9, 11), fill=(0, 0, 0, 0))
	d.rectangle((8, 7, 19, 11), fill=rgba(GOLD))
	d.rectangle((9, 8, 18, 9), fill=rgba(GOLD_HI))
	d.rectangle((15, 10, 18, 15), fill=rgba(GOLD_DK))
	d.rectangle((18, 10, 20, 13), fill=rgba(GOLD))
	d.point((5, 5), fill=rgba(CLOUD_HI))


def paint_camera(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.rectangle((2, 7, 15, 17), fill=rgba(METAL_DK))
	d.rectangle((4, 6, 12, 8), fill=rgba(ROCK))
	d.rectangle((5, 4, 10, 7), fill=rgba(METAL))
	d.polygon(((14, 8), (20, 6), (20, 18), (14, 16)), fill=rgba(INK_BLUE))
	d.ellipse((9, 8, 18, 17), fill=rgba((20, 32, 47)))
	d.ellipse((11, 10, 17, 16), fill=rgba(SEA_DEEP))
	d.ellipse((12, 10, 15, 13), fill=rgba(SEA_LIGHT))
	d.rectangle((4, 10, 7, 13), fill=rgba((192, 50, 46)))
	d.point((8, 9), fill=rgba(GOLD_HI))


def paint_microwave(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.rectangle((1, 5, 20, 18), fill=rgba(METAL_DK))
	d.rectangle((2, 6, 19, 17), fill=rgba(METAL))
	d.rectangle((4, 8, 14, 15), fill=rgba(INK_BLUE))
	d.rectangle((5, 9, 13, 13), fill=rgba((43, 91, 111)))
	d.line((5, 14, 13, 14), fill=rgba(SEA_LIGHT))
	d.rectangle((15, 8, 18, 10), fill=rgba((71, 168, 94)))
	for y in (12, 15):
		d.point((16, y), fill=rgba(INK))
		d.point((18, y), fill=rgba(CLOUD_HI))
	d.rectangle((3, 6, 18, 7), fill=rgba(METAL_HI))


def paint_cursed_treasure(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	# Open lid, visible gold, and an unnatural green jewel sell the concept.
	d.polygon(((4, 4), (16, 3), (19, 9), (5, 10)), fill=rgba(WOOD_DK))
	d.polygon(((6, 5), (15, 5), (17, 8), (6, 8)), fill=rgba(WOOD_HI))
	for x, y in [(7, 10), (10, 9), (13, 10), (16, 9)]:
		d.ellipse((x - 2, y - 2, x + 2, y + 2), fill=rgba(GOLD_HI))
	d.rectangle((3, 10, 19, 19), fill=rgba(WOOD_DK))
	d.rectangle((5, 11, 17, 17), fill=rgba(WOOD))
	d.rectangle((10, 10, 13, 16), fill=rgba(GOLD_DK))
	d.polygon(((11, 9), (15, 12), (12, 17), (8, 13)), fill=rgba((76, 211, 114)))
	d.point((11, 11), fill=rgba((200, 255, 176)))


def paint_gold_bag(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((7, 4), (14, 4), (16, 8), (19, 17), (16, 20), (5, 20), (2, 17), (5, 8)), fill=rgba((174, 116, 45)))
	d.polygon(((6, 8), (15, 8), (17, 17), (15, 19), (6, 19), (4, 16)), fill=rgba(GOLD))
	d.rectangle((5, 6, 16, 9), fill=rgba(TRUNK_DK))
	d.line((7, 4, 10, 7, 14, 3), fill=rgba(WOOD_HI), width=2)
	d.ellipse((7, 11, 14, 18), fill=rgba(GOLD_HI))
	d.rectangle((10, 12, 11, 17), fill=rgba(GOLD_DK))
	d.rectangle((8, 14, 13, 15), fill=rgba(GOLD_DK))


def paint_dehydrated_boat(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((2, 12), (7, 7), (18, 8), (20, 13), (17, 18), (5, 18)), fill=rgba(WOOD_DK))
	d.polygon(((4, 12), (8, 9), (17, 10), (18, 13), (16, 16), (6, 16)), fill=rgba((183, 112, 55)))
	d.line((6, 11, 17, 13), fill=rgba(WOOD_HI), width=2)
	d.line((7, 15, 16, 11), fill=rgba(TRUNK_DK), width=2)
	d.rectangle((10, 7, 12, 18), fill=rgba((207, 181, 115)))
	d.point((3, 12), fill=rgba(SAND_HI))


def paint_outboard_motor(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.rounded_rectangle((5, 2, 17, 10), radius=3, fill=rgba(METAL_DK))
	d.rectangle((7, 3, 15, 8), fill=rgba((176, 56, 50)))
	d.rectangle((8, 3, 14, 4), fill=rgba(BOOT_HI))
	d.rectangle((9, 9, 13, 17), fill=rgba(METAL))
	d.line((11, 15, 8, 20), fill=rgba(METAL_DK), width=3)
	d.line((6, 19, 12, 19), fill=rgba(METAL_HI), width=2)
	d.line((8, 16, 15, 19), fill=rgba(METAL_DK), width=2)
	d.rectangle((16, 5, 20, 7), fill=rgba(INK_BLUE))


def paint_petrol(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((5, 4), (15, 4), (18, 7), (18, 19), (3, 19), (3, 7)), fill=rgba(BOOT_DK))
	d.polygon(((6, 5), (14, 5), (16, 8), (16, 17), (5, 17), (5, 7)), fill=rgba((201, 65, 44)))
	d.rectangle((8, 2, 15, 6), fill=rgba(METAL_DK))
	d.rectangle((9, 3, 13, 5), fill=(0, 0, 0, 0))
	d.rectangle((15, 4, 19, 7), fill=rgba(METAL))
	d.line((7, 8, 14, 15), fill=rgba(BOOT_HI), width=2)
	d.line((14, 8, 7, 15), fill=rgba(BOOT_HI), width=2)
	d.rectangle((7, 16, 14, 18), fill=rgba(GOLD_HI))


def paint_ignition_key(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.rounded_rectangle((2, 3, 11, 13), radius=3, fill=rgba(INK_BLUE))
	d.rectangle((4, 5, 9, 10), fill=rgba((58, 74, 91)))
	d.ellipse((5, 6, 8, 9), fill=rgba(BOOT_HI))
	d.line((10, 10, 18, 18), fill=rgba(METAL_DK), width=4)
	d.line((11, 9, 19, 17), fill=rgba(METAL_HI), width=2)
	d.rectangle((16, 15, 20, 17), fill=rgba(METAL))
	d.rectangle((17, 17, 19, 20), fill=rgba(METAL_DK))


def paint_plant(im: Image.Image, d: ImageDraw.ImageDraw, variant: int) -> None:
	d.rectangle((9, 11, 12, 20), fill=rgba(TRUNK_DK))
	if variant == 1:
		for end in [(2, 8), (4, 3), (9, 2), (16, 4), (20, 8), (5, 13), (17, 13)]:
			d.line((11, 15, *end), fill=rgba(LEAF_DK), width=3)
			d.line((11, 14, *end), fill=rgba(LEAF_HI), width=1)
	elif variant == 2:
		for box, color in [
			((2, 5, 11, 13), LEAF),
			((10, 2, 20, 11), LEAF_HI),
			((7, 9, 18, 17), LEAF_DK),
		]:
			d.ellipse(box, fill=rgba(color))
		d.line((11, 13, (box[0] + box[2]) // 2, (box[1] + box[3]) // 2), fill=rgba(LEAF_LIME))
	elif variant == 3:
		d.line((10, 15, 5, 7), fill=rgba(LEAF), width=3)
		d.line((11, 14, 17, 8), fill=rgba(LEAF_HI), width=3)
		d.ellipse((2, 2, 9, 9), fill=rgba((220, 78, 76)))
		d.ellipse((13, 3, 20, 10), fill=rgba((236, 136, 61)))
		d.point((5, 5), fill=rgba(GOLD_HI))
		d.point((16, 6), fill=rgba(GOLD_HI))
	else:
		d.line((10, 18, 5, 14, 8, 9, 4, 5), fill=rgba(LEAF_DK), width=3)
		d.line((12, 18, 17, 14, 14, 9, 19, 5), fill=rgba(LEAF), width=3)
		for x, y in [(5, 5), (8, 9), (14, 9), (19, 5)]:
			d.ellipse((x - 2, y - 2, x + 2, y + 2), fill=rgba(LEAF_LIME))


def paint_skull(im: Image.Image, d: ImageDraw.ImageDraw, variant: int) -> None:
	if variant == 2:
		d.line((3, 18, 18, 8), fill=rgba(GLOVE_SH), width=3)
		d.line((4, 7, 19, 18), fill=rgba(GLOVE_SH), width=3)
	d.ellipse((3, 2, 18, 16), fill=rgba(GLOVE))
	d.rectangle((6, 12, 15, 19), fill=rgba(GLOVE))
	d.ellipse((6, 7, 10, 11), fill=rgba(INK))
	d.ellipse((12, 7, 16, 11), fill=rgba(INK))
	d.polygon(((11, 10), (9, 14), (13, 14)), fill=rgba(INK_BROWN))
	for x in (7, 10, 13):
		d.line((x, 16, x, 19), fill=rgba(GLOVE_SH))
	if variant == 2:
		d.line((14, 3, 12, 7, 15, 9), fill=rgba(ROCK_DK), width=1)
	else:
		d.point((6, 4), fill=rgba(GLOVE_HI))


def paint_trunk(im: Image.Image, d: ImageDraw.ImageDraw, variant: int) -> None:
	if variant == 1:
		d.rectangle((4, 7, 18, 16), fill=rgba(TRUNK_DK))
		d.rectangle((5, 8, 16, 15), fill=rgba(TRUNK))
		d.ellipse((14, 7, 20, 16), fill=rgba(WOOD_HI))
		d.ellipse((16, 9, 19, 14), outline=rgba(TRUNK_DK), width=1)
		d.line((6, 10, 14, 9), fill=rgba(TRUNK_HI), width=2)
	else:
		d.polygon(((4, 18), (7, 3), (16, 4), (18, 19)), fill=rgba(TRUNK_DK))
		d.polygon(((7, 17), (9, 5), (14, 6), (15, 17)), fill=rgba(TRUNK))
		d.line((9, 7, 14, 10), fill=rgba(TRUNK_HI), width=2)
		d.line((7, 14, 14, 12), fill=rgba(INK_BROWN), width=2)


def paint_rail(im: Image.Image, d: ImageDraw.ImageDraw, variant: int) -> None:
	if variant == 1:
		d.rectangle((3, 4, 6, 19), fill=rgba(TRUNK_DK))
		d.rectangle((16, 4, 19, 19), fill=rgba(TRUNK_DK))
		d.rectangle((2, 7, 20, 11), fill=rgba(WOOD))
		d.rectangle((2, 14, 20, 18), fill=rgba(WOOD))
		d.line((3, 8, 19, 8), fill=rgba(WOOD_HI))
	else:
		d.rectangle((3, 3, 7, 19), fill=rgba(TRUNK_DK))
		d.rectangle((15, 3, 19, 19), fill=rgba(TRUNK_DK))
		d.line((4, 16, 18, 6), fill=rgba(WOOD_DK), width=6)
		d.line((5, 15, 17, 7), fill=rgba(WOOD_HI), width=2)
	for x, y in [(5, 9), (17, 9), (5, 16), (17, 16)]:
		d.rectangle((x, y, x + 1, y + 1), fill=rgba(METAL_HI))


def paint_mushrooms(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	for x, y, width, color in [(6, 7, 7, (205, 61, 55)), (14, 10, 8, (226, 102, 63)), (10, 14, 6, (174, 55, 65))]:
		d.rectangle((x - 1, y, x + 1, 19), fill=rgba(GLOVE))
		d.ellipse((x - width // 2, y - 4, x + width // 2, y + 2), fill=rgba(color))
		d.point((x - 1, y - 2), fill=rgba(GLOVE_HI))
		d.point((x + 2, y), fill=rgba(GLOVE_HI))
	d.line((2, 20, 19, 20), fill=rgba(LEAF_DK), width=2)


def paint_window(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.rectangle((2, 2, 19, 19), fill=rgba(WOOD_DK))
	d.rectangle((4, 4, 17, 17), fill=rgba((98, 155, 175)))
	d.rectangle((5, 5, 16, 16), fill=rgba((175, 209, 208)))
	d.line((5, 14, 9, 10, 13, 13, 17, 8), fill=rgba(CLOUD_HI), width=2)
	d.line((5, 8, 9, 6, 14, 8), fill=rgba(CLOUD_SH), width=2)
	d.rectangle((10, 3, 12, 18), fill=rgba(WOOD_HI))
	d.rectangle((3, 10, 18, 12), fill=rgba(WOOD_HI))
	d.line((14, 4, 13, 8, 16, 11), fill=rgba(SEA_DEEP))


def paint_bucket(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.arc((3, 1, 19, 15), 180, 360, fill=rgba(METAL_HI), width=2)
	d.polygon(((4, 7), (18, 7), (16, 20), (6, 20)), fill=rgba(METAL_DK))
	d.polygon(((6, 8), (16, 8), (14, 18), (8, 18)), fill=rgba(METAL))
	d.rectangle((5, 7, 17, 10), fill=rgba(INK_BLUE))
	d.line((8, 11, 14, 11), fill=rgba(METAL_HI))
	d.point((14, 15), fill=rgba(CLOUD_HI))


def paint_empty_chest(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((3, 8), (5, 3), (17, 3), (20, 8), (18, 11), (4, 11)), fill=rgba(WOOD_DK))
	d.polygon(((5, 7), (7, 5), (16, 5), (18, 8), (16, 9), (6, 9)), fill=rgba(WOOD_HI))
	d.rectangle((3, 11, 19, 20), fill=rgba(WOOD_DK))
	d.rectangle((5, 12, 17, 18), fill=rgba(WOOD))
	d.rectangle((10, 11, 13, 17), fill=rgba(GOLD_DK))
	d.rectangle((11, 13, 12, 15), fill=rgba(INK))
	d.line((5, 13, 17, 13), fill=rgba(TRUNK_HI))


def paint_heavy_rock(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((2, 15), (5, 6), (11, 2), (18, 6), (21, 15), (17, 20), (6, 20)), fill=rgba(ROCK_DK))
	d.polygon(((5, 14), (7, 7), (12, 4), (16, 7), (13, 14)), fill=rgba(ROCK_HI))
	d.polygon(((14, 14), (17, 8), (19, 15), (16, 18), (9, 18)), fill=rgba(ROCK))
	d.line((6, 15, 11, 12, 14, 15), fill=rgba(METAL_DK), width=2)
	d.point((9, 6), fill=rgba(CLOUD_SH))


def paint_toothpaste(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((6, 2), (16, 3), (15, 18), (5, 17)), fill=rgba(CLOUD_SH))
	d.polygon(((7, 3), (15, 4), (14, 16), (6, 16)), fill=rgba(GLOVE_HI))
	d.rectangle((5, 17, 15, 20), fill=rgba(METAL))
	d.line((7, 7, 14, 11), fill=rgba((50, 125, 190)), width=3)
	d.line((7, 11, 14, 14), fill=rgba(BOOT_HI), width=2)
	d.rectangle((8, 3, 14, 5), fill=rgba((54, 147, 190)))


def paint_magazine(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((5, 2), (18, 4), (16, 20), (3, 18)), fill=rgba((34, 75, 141)))
	d.polygon(((6, 3), (17, 5), (15, 18), (4, 17)), fill=rgba((57, 120, 187)))
	d.rectangle((7, 5, 15, 7), fill=rgba(GOLD_HI))
	d.polygon(((7, 9), (14, 8), (15, 14), (8, 15)), fill=rgba((226, 105, 73)))
	d.ellipse((9, 9, 13, 13), fill=rgba(GLOVE))
	d.line((6, 16, 14, 17), fill=rgba(CLOUD_HI))
	d.rectangle((3, 3, 5, 17), fill=rgba(SEA_DEEP))


# ---------------------------------------------------------------------------
# Hazards.


def paint_trap(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.rectangle((2, 19, 29, 22), fill=rgba(INK_BROWN))
	d.rectangle((4, 17, 27, 20), fill=rgba(METAL_DK))
	for x, height in [(5, 10), (10, 15), (16, 12), (22, 16), (27, 9)]:
		d.polygon(((x - 3, 18), (x, 18 - height), (x + 3, 18)), fill=rgba(METAL))
		d.line((x, 18 - height + 2, x, 15), fill=rgba(METAL_HI))
	d.rectangle((12, 18, 19, 21), fill=rgba(BOOT_DK))
	d.point((15, 19), fill=rgba(BOOT_HI))


def paint_fish(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((29, 12), (38, 3), (37, 20)), fill=rgba(SEA_DEEP))
	d.polygon(((17, 5), (23, 0), (27, 7)), fill=rgba(SEA_LIGHT))
	d.polygon(((16, 19), (23, 23), (27, 17)), fill=rgba(SEA_DEEP))
	d.ellipse((2, 4, 31, 20), fill=rgba((45, 132, 169)))
	d.polygon(((4, 12), (12, 5), (25, 6), (29, 12), (24, 18), (11, 19)), fill=rgba(SEA_MID))
	d.line((8, 7, 22, 6), fill=rgba(SEA_LIGHT), width=2)
	d.ellipse((7, 7, 13, 13), fill=rgba(CLOUD_HI))
	d.ellipse((9, 9, 12, 12), fill=rgba(INK))
	d.polygon(((3, 14), (10, 14), (7, 17)), fill=rgba(CLOUD_HI))
	for x in (4, 7, 10):
		d.line((x, 14, x + 1, 16), fill=rgba(INK))


def paint_crab(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	for points in [
		((13, 15), (6, 20), (2, 21)),
		((15, 18), (10, 23), (6, 23)),
		((27, 15), (34, 20), (38, 21)),
		((25, 18), (30, 23), (34, 23)),
	]:
		d.line(points, fill=rgba(BOOT_DK), width=3)
	d.ellipse((10, 7, 30, 21), fill=rgba((205, 69, 44)))
	d.rectangle((13, 11, 27, 18), fill=rgba(BOOT_HI))
	for x in (15, 25):
		d.line((x, 9, x - 1 if x < 20 else x + 1, 3), fill=rgba(BOOT_DK), width=2)
		d.ellipse((x - 3, 1, x + 2, 6), fill=rgba(CLOUD_HI))
		d.point((x, 3), fill=rgba(INK))
	d.line((4, 9, 12, 12), fill=rgba(BOOT_DK), width=4)
	d.line((28, 12, 36, 9), fill=rgba(BOOT_DK), width=4)
	d.polygon(((1, 4), (8, 5), (7, 12), (2, 14)), fill=rgba((226, 79, 47)))
	d.polygon(((39, 4), (32, 5), (33, 12), (38, 14)), fill=rgba((226, 79, 47)))
	d.line((16, 18, 20, 20, 24, 18), fill=rgba(INK_BROWN), width=1)


def paint_cuttlefish(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((7, 7), (14, 2), (29, 4), (35, 11), (30, 20), (12, 20), (5, 15)), fill=rgba((94, 51, 124)))
	d.ellipse((7, 3, 33, 21), fill=rgba((151, 86, 166)))
	d.polygon(((10, 7), (25, 4), (31, 10), (28, 17), (12, 17)), fill=rgba((188, 111, 178)))
	for x in (13, 21):
		d.ellipse((x - 3, 8, x + 3, 14), fill=rgba(GOLD_HI))
		d.ellipse((x - 1, 9, x + 1, 13), fill=rgba(INK))
	d.line((29, 11, 36, 8), fill=rgba(SEA_LIGHT), width=2)
	for x, end_x in [(11, 7), (15, 13), (20, 22), (25, 29), (29, 35)]:
		d.line((x, 18, end_x, 27), fill=rgba((102, 58, 135)), width=3)
		d.point((end_x, 27), fill=rgba((208, 127, 190)))


# ---------------------------------------------------------------------------
# NPCs: original friendly island characters, not traced likenesses.


def paint_shopkeeper(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	skin = (216, 166, 116)
	skin_hi = (242, 199, 147)
	hair = (71, 43, 35)
	# Shoes, legs, torso, apron.
	d.rectangle((11, 57, 21, 68), fill=rgba(TRUNK_DK))
	d.rectangle((27, 57, 37, 68), fill=rgba(TRUNK_DK))
	d.rectangle((7, 67, 22, 71), fill=rgba(INK_BROWN))
	d.rectangle((26, 67, 42, 71), fill=rgba(INK_BROWN))
	d.polygon(((10, 28), (38, 28), (42, 58), (7, 58)), fill=rgba((45, 120, 116)))
	d.rectangle((14, 31, 34, 58), fill=rgba((207, 183, 131)))
	d.rectangle((17, 35, 31, 53), fill=rgba((232, 215, 170)))
	d.rectangle((18, 47, 30, 50), fill=rgba(WOOD_HI))
	# Sleeves and expressive hands.
	d.line((10, 33, 4, 47), fill=rgba((43, 97, 91)), width=8)
	d.line((38, 33, 44, 45), fill=rgba((43, 97, 91)), width=8)
	d.ellipse((0, 43, 9, 52), fill=rgba(skin))
	d.ellipse((39, 41, 47, 50), fill=rgba(skin))
	d.rectangle((39, 45, 46, 55), fill=rgba((96, 54, 35)))
	d.ellipse((40, 42, 45, 47), fill=rgba(GOLD_HI))
	# Head, ears, hair and a bright island headscarf.
	d.ellipse((9, 4, 39, 34), fill=rgba(hair))
	d.ellipse((11, 5, 37, 32), fill=rgba(skin))
	d.ellipse((7, 14, 14, 23), fill=rgba(skin))
	d.ellipse((34, 14, 41, 23), fill=rgba(skin))
	d.polygon(((8, 8), (17, 1), (39, 7), (36, 13), (12, 12)), fill=rgba((202, 69, 52)))
	d.rectangle((11, 7, 37, 11), fill=rgba(BOOT_HI))
	d.polygon(((36, 8), (46, 5), (40, 14)), fill=rgba((202, 69, 52)))
	# Face: brows, glinting eyes, nose, moustache and smile.
	d.line((16, 15, 21, 14), fill=rgba(hair), width=2)
	d.line((27, 14, 32, 15), fill=rgba(hair), width=2)
	for x in (18, 29):
		d.ellipse((x - 2, 16, x + 2, 21), fill=rgba(INK))
		d.point((x - 1, 17), fill=rgba(CLOUD_HI))
	d.polygon(((24, 19), (21, 24), (25, 25)), fill=rgba((179, 118, 80)))
	d.ellipse((15, 23, 25, 29), fill=rgba(hair))
	d.ellipse((24, 23, 34, 29), fill=rgba(hair))
	d.line((21, 29, 27, 29), fill=rgba((108, 43, 40)), width=2)


def paint_taxman(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	skin = (205, 158, 115)
	skin_hi = (232, 188, 139)
	navy = (35, 43, 61)
	# Boots and long angular coat.
	d.rectangle((10, 57, 20, 69), fill=rgba(INK_BROWN))
	d.rectangle((28, 57, 38, 69), fill=rgba(INK_BROWN))
	d.rectangle((7, 68, 21, 71), fill=rgba(INK))
	d.rectangle((27, 68, 42, 71), fill=rgba(INK))
	d.polygon(((9, 28), (38, 28), (43, 62), (29, 59), (24, 65), (19, 59), (5, 62)), fill=rgba(navy))
	d.polygon(((20, 29), (28, 29), (33, 55), (15, 55)), fill=rgba((126, 42, 48)))
	d.polygon(((20, 29), (24, 40), (16, 34)), fill=rgba(CLOUD_SH))
	d.polygon(((28, 29), (24, 40), (34, 34)), fill=rgba(CLOUD_HI))
	d.rectangle((22, 30, 26, 57), fill=rgba(GOLD_DK))
	for y in (37, 46, 54):
		d.ellipse((22, y, 25, y + 3), fill=rgba(GOLD_HI))
	# One arm carries a red ledger; the other points sternly.
	d.line((9, 34, 3, 50), fill=rgba(navy), width=8)
	d.ellipse((0, 47, 8, 55), fill=rgba(skin))
	d.polygon(((33, 39), (47, 35), (47, 54), (33, 57)), fill=rgba((90, 30, 40)))
	d.rectangle((36, 38, 45, 53), fill=rgba((151, 47, 50)))
	d.rectangle((35, 39, 37, 54), fill=rgba(GOLD_DK))
	# Head, sideburns and tall hat.
	d.ellipse((11, 7, 38, 33), fill=rgba(skin))
	d.rectangle((10, 15, 14, 29), fill=rgba((64, 43, 39)))
	d.rectangle((35, 15, 39, 29), fill=rgba((64, 43, 39)))
	d.rectangle((10, 0, 39, 7), fill=rgba(INK))
	d.rectangle((14, 0, 35, 15), fill=rgba(navy))
	d.rectangle((16, 2, 33, 4), fill=rgba((62, 75, 96)))
	d.rectangle((13, 12, 37, 16), fill=rgba(INK))
	for x in (18, 30):
		d.ellipse((x - 2, 18, x + 2, 22), fill=rgba(INK))
	d.ellipse((27, 16, 34, 24), outline=rgba(GOLD_HI), width=2)
	d.line((33, 22, 37, 34), fill=rgba(GOLD), width=1)
	d.polygon(((24, 21), (21, 26), (26, 26)), fill=rgba((166, 106, 75)))
	d.line((17, 28, 24, 26, 31, 28), fill=rgba((76, 44, 40)), width=2)
	d.point((13, 19), fill=rgba(skin_hi))


# ---------------------------------------------------------------------------
# Scenery props.


def paint_boat(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((3, 18), (68, 18), (63, 34), (54, 39), (14, 39), (7, 33)), fill=rgba(WOOD_DK))
	d.polygon(((6, 20), (65, 20), (60, 31), (52, 35), (15, 35), (10, 31)), fill=rgba((157, 82, 43)))
	d.line((9, 22, 63, 22), fill=rgba(WOOD_HI), width=3)
	d.polygon(((15, 12), (58, 12), (64, 19), (8, 19)), fill=rgba(TRUNK_DK))
	for x in (19, 36, 53):
		d.rectangle((x - 5, 13, x + 5, 18), fill=rgba(WOOD_HI))
		d.rectangle((x - 4, 14, x + 4, 15), fill=rgba((224, 155, 77)))
	d.rectangle((34, 4, 38, 13), fill=rgba(TRUNK_DK))
	d.line((36, 5, 49, 11), fill=rgba((212, 190, 133)), width=2)
	d.ellipse((51, 25, 58, 32), outline=rgba(GOLD_HI), width=2)
	d.line((3, 27, 15, 36), fill=rgba(INK_BROWN), width=2)


def paint_motor(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.rounded_rectangle((3, 1, 25, 17), radius=5, fill=rgba(METAL_DK))
	d.rectangle((6, 4, 22, 13), fill=rgba((167, 54, 50)))
	d.rectangle((7, 4, 21, 6), fill=rgba(BOOT_HI))
	d.rectangle((10, 16, 18, 27), fill=rgba(METAL))
	d.polygon(((11, 26), (17, 25), (21, 31), (7, 31)), fill=rgba(METAL_DK))
	d.line((8, 30, 20, 30), fill=rgba(METAL_HI), width=2)
	d.rectangle((22, 7, 27, 10), fill=rgba(INK_BLUE))
	d.point((9, 9), fill=rgba(GOLD_HI))


def paint_grave(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.ellipse((7, 3, 41, 34), fill=rgba(ROCK_DK))
	d.rectangle((7, 18, 41, 49), fill=rgba(ROCK_DK))
	d.ellipse((10, 5, 38, 31), fill=rgba(ROCK))
	d.rectangle((10, 19, 38, 47), fill=rgba(ROCK))
	d.line((13, 14, 34, 11), fill=rgba(ROCK_HI), width=3)
	d.rectangle((21, 18, 27, 39), fill=rgba(METAL_DK))
	d.rectangle((15, 24, 33, 30), fill=rgba(METAL_DK))
	d.line((12, 41, 19, 35, 24, 40), fill=rgba(ROCK_DK), width=2)
	for x, y in [(8, 43), (14, 48), (35, 46), (40, 41)]:
		d.line((x, y, x - 4, y - 6), fill=rgba(LEAF_DK), width=2)
		d.point((x - 4, y - 6), fill=rgba(LEAF_HI))


def paint_totem(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.rectangle((10, 3, 26, 70), fill=rgba(TRUNK_DK))
	d.rectangle((12, 4, 24, 69), fill=rgba(TRUNK))
	for y, accent in [(5, (56, 147, 145)), (27, (196, 68, 52)), (49, (221, 156, 54))]:
		d.polygon(((5, y + 7), (10, y), (26, y), (31, y + 7), (27, y + 20), (9, y + 20)), fill=rgba(WOOD))
		d.rectangle((8, y + 7, 28, y + 11), fill=rgba(accent))
		for x in (12, 23):
			d.rectangle((x - 3, y + 4, x + 2, y + 9), fill=rgba(CLOUD_HI))
			d.rectangle((x - 1, y + 6, x + 1, y + 9), fill=rgba(INK))
		d.polygon(((18, y + 9), (14, y + 15), (22, y + 15)), fill=rgba(TRUNK_DK))
		d.line((12, y + 17, 18, y + 19, 24, y + 17), fill=rgba(INK_BROWN), width=2)
	d.polygon(((3, 5), (10, 10), (4, 16)), fill=rgba(LEAF_HI))
	d.polygon(((33, 5), (26, 10), (32, 16)), fill=rgba(LEAF))


def paint_hatch(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.rectangle((1, 2, 46, 16), fill=rgba(METAL_DK))
	d.rectangle((3, 4, 44, 14), fill=rgba(WOOD_DK))
	for x0, color in [(4, WOOD), (15, TRUNK), (26, WOOD), (37, TRUNK)]:
		d.rectangle((x0, 5, x0 + 7, 13), fill=rgba(color))
		d.line((x0 + 1, 6, x0 + 6, 6), fill=rgba(WOOD_HI))
	for x in (3, 44):
		d.rectangle((x, 5, x + 1, 13), fill=rgba(METAL_HI))
	d.arc((19, 4, 29, 14), 180, 360, fill=rgba(GOLD_HI), width=2)
	d.rectangle((21, 9, 27, 11), fill=rgba(GOLD_DK))


def paint_bubble(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.ellipse((1, 1, 14, 14), fill=(76, 156, 205, 46), outline=(169, 226, 245, 210), width=2)
	d.arc((3, 3, 12, 12), 190, 320, fill=(62, 112, 176, 150), width=1)
	d.ellipse((3, 2, 6, 5), fill=(244, 252, 255, 230))
	d.point((11, 11), fill=(211, 241, 249, 180))


def paint_barrel(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.ellipse((2, 1, 30, 14), fill=rgba(WOOD_DK))
	d.rectangle((2, 8, 30, 32), fill=rgba(WOOD_DK))
	d.ellipse((2, 26, 30, 39), fill=rgba(TRUNK_DK))
	d.ellipse((5, 3, 27, 11), fill=rgba(WOOD_HI))
	d.rectangle((5, 8, 27, 30), fill=rgba(WOOD))
	for x in (9, 15, 22):
		d.line((x, 8, x - 1, 31), fill=rgba(TRUNK_DK), width=2)
	d.rectangle((2, 11, 30, 15), fill=rgba(METAL_DK))
	d.rectangle((2, 26, 30, 30), fill=rgba(METAL_DK))
	d.line((3, 12, 29, 12), fill=rgba(METAL_HI))
	d.line((4, 27, 28, 27), fill=rgba(METAL_HI))
	d.ellipse((10, 5, 22, 9), outline=rgba(TRUNK_DK), width=2)


def paint_door(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.rectangle((1, 1, 27, 43), fill=rgba(WOOD_DK))
	d.rectangle((4, 3, 24, 41), fill=rgba(WOOD))
	d.rectangle((6, 5, 22, 19), fill=rgba(TRUNK))
	d.rectangle((6, 23, 22, 39), fill=rgba(TRUNK))
	for box in [(7, 6, 21, 18), (7, 24, 21, 38)]:
		d.line((box[0], box[1], box[2], box[1]), fill=rgba(WOOD_HI), width=2)
		d.line((box[0], box[1], box[0], box[3]), fill=rgba(WOOD_HI), width=2)
		d.line((box[2], box[1], box[2], box[3]), fill=rgba(TRUNK_DK), width=2)
	d.ellipse((18, 19, 24, 25), fill=rgba(GOLD_DK))
	d.ellipse((19, 20, 22, 23), fill=rgba(GOLD_HI))
	d.point((20, 20), fill=rgba(CLOUD_HI))


def paint_rock(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((2, 25), (7, 11), (20, 4), (36, 7), (46, 20), (44, 30), (8, 31)), fill=rgba(ROCK_DK))
	d.polygon(((7, 24), (11, 13), (21, 7), (28, 14), (23, 27)), fill=rgba(ROCK_HI))
	d.polygon(((29, 13), (36, 9), (43, 20), (41, 27), (24, 28)), fill=rgba(ROCK))
	d.line((11, 24, 20, 20, 25, 25), fill=rgba(METAL_DK), width=2)
	d.line((31, 14, 36, 20, 34, 25), fill=rgba(ROCK_DK), width=2)
	d.point((17, 10), fill=rgba(CLOUD_SH))


def paint_stump(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((6, 8), (26, 8), (27, 28), (23, 34), (8, 34), (4, 28)), fill=rgba(TRUNK_DK))
	d.rectangle((8, 8, 24, 29), fill=rgba(TRUNK))
	d.ellipse((3, 1, 29, 15), fill=rgba(WOOD_DK))
	d.ellipse((6, 3, 26, 12), fill=rgba(WOOD_HI))
	d.ellipse((10, 5, 22, 10), outline=rgba(TRUNK_DK), width=2)
	d.ellipse((14, 6, 19, 9), outline=rgba(TRUNK), width=1)
	d.line((9, 16, 7, 27), fill=rgba(TRUNK_HI), width=2)
	d.line((22, 14, 24, 28), fill=rgba(INK_BROWN), width=2)
	d.polygon(((6, 27), (1, 34), (10, 32)), fill=rgba(TRUNK_DK))
	d.polygon(((25, 27), (31, 34), (21, 32)), fill=rgba(TRUNK_DK))


def paint_hut(im: Image.Image, d: ImageDraw.ImageDraw) -> None:
	d.polygon(((1, 23), (27, 2), (55, 23), (49, 28), (7, 28)), fill=rgba(INK_BROWN))
	for y, color in [(5, (188, 97, 49)), (10, (218, 123, 57)), (15, (173, 78, 43)), (20, (225, 135, 66))]:
		d.polygon(((4 + y // 2, 23), (27, y), (52 - y // 2, 23)), fill=rgba(color))
	d.rectangle((7, 24, 49, 51), fill=rgba(SAND_DARK))
	for x in range(8, 49, 7):
		d.rectangle((x, 25, x + 4, 50), fill=rgba((185, 139, 79)))
		d.line((x, 25, x, 50), fill=rgba(WOOD_HI))
	d.rectangle((20, 32, 36, 51), fill=rgba(WOOD_DK))
	d.rectangle((23, 35, 33, 51), fill=rgba(INK_BROWN))
	d.rectangle((9, 31, 18, 41), fill=rgba(SEA_DEEP))
	d.rectangle((10, 32, 17, 37), fill=rgba(SEA_LIGHT))
	d.line((5, 51, 51, 51), fill=rgba(TRUNK_DK), width=3)
	d.line((13, 51, 7, 55), fill=rgba(TRUNK_DK), width=3)
	d.line((43, 51, 49, 55), fill=rgba(TRUNK_DK), width=3)


def main() -> None:
	for folder in (ITEMS, HAZARDS, NPCS, PROPS):
		folder.mkdir(parents=True, exist_ok=True)

	item_painters: dict[str, Paint] = {
		"default": paint_default,
		"coin": paint_coin,
		"snorkel": paint_snorkel,
		"salt_spade": paint_spade,
		"glass_sword": paint_sword,
		"woodcutters_axe": paint_axe,
		"holy_bible": paint_bible,
		"dynamite": paint_dynamite,
		"detonator": paint_detonator,
		"golden_key": paint_golden_key,
		"video_camera": paint_camera,
		"microwave": paint_microwave,
		"cursed_treasure": paint_cursed_treasure,
		"gold_bag": paint_gold_bag,
		"dehydrated_boat": paint_dehydrated_boat,
		"outboard_motor": paint_outboard_motor,
		"petrol": paint_petrol,
		"ignition_key": paint_ignition_key,
		"mushrooms": paint_mushrooms,
		"misty_window": paint_window,
		"empty_bucket": paint_bucket,
		"empty_chest": paint_empty_chest,
		"heavy_rock": paint_heavy_rock,
		"toothpaste": paint_toothpaste,
		"magazine": paint_magazine,
	}
	for name, paint in item_painters.items():
		item(name, paint, INK_BROWN if name in {"coin", "gold_bag", "holy_bible"} else INK)
	for variant in range(1, 5):
		item(f"plant_{variant}", lambda im, d, v=variant: paint_plant(im, d, v), LEAF_DK)
	for variant in (1, 2):
		item(f"skull_{variant}", lambda im, d, v=variant: paint_skull(im, d, v), INK_BLUE)
		item(f"tree_trunk_{variant}", lambda im, d, v=variant: paint_trunk(im, d, v), INK_BROWN)
		item(f"wooden_rail_{variant}", lambda im, d, v=variant: paint_rail(im, d, v), INK_BROWN)

	sprite_asset(HAZARDS, "trap", 32, 24, paint_trap, INK_BROWN)
	sprite_asset(HAZARDS, "fish", 40, 24, paint_fish, INK_BLUE)
	sprite_asset(HAZARDS, "crab", 40, 24, paint_crab, INK_BROWN)
	sprite_asset(HAZARDS, "cuttlefish", 40, 28, paint_cuttlefish, INK_BLUE)

	sprite_asset(NPCS, "shopkeeper", 48, 72, paint_shopkeeper, INK_BROWN)
	sprite_asset(NPCS, "taxman", 48, 72, paint_taxman, INK)

	sprite_asset(PROPS, "boat", 72, 40, paint_boat, INK_BROWN)
	sprite_asset(PROPS, "motor", 28, 32, paint_motor, INK_BLUE)
	sprite_asset(PROPS, "grave", 48, 52, paint_grave, ROCK_DK)
	sprite_asset(PROPS, "totem", 36, 72, paint_totem, INK_BROWN)
	sprite_asset(PROPS, "hatch", 48, 18, paint_hatch, INK_BROWN)
	sprite_asset(PROPS, "bubble", 16, 16, paint_bubble, add_outline=False)
	sprite_asset(PROPS, "barrel", 32, 40, paint_barrel, INK_BROWN)
	sprite_asset(PROPS, "door", 28, 44, paint_door, INK_BROWN)
	sprite_asset(PROPS, "rock", 48, 32, paint_rock, ROCK_DK)
	sprite_asset(PROPS, "stump", 32, 36, paint_stump, INK_BROWN)
	sprite_asset(PROPS, "hut", 56, 52, paint_hut, INK_BROWN)
	print("sprites done")


if __name__ == "__main__":
	main()
