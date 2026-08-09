#!/usr/bin/env python3
"""
Regenerate all Treasure Island pixel art (original homage, CC BY-NC).

Usage (from any working directory):
  python path/to/repo/scripts/generate_ti_art.py
"""
from __future__ import annotations

from PIL import Image

import generate_ti_backdrops
import generate_ti_dizzy
import generate_ti_sprites
import generate_ti_tiles
from ti_art_lib import REPO_ROOT


EXPECTED: dict[str, tuple[int, int]] = {}


def _expect(folder: str, names: list[str], size: tuple[int, int]) -> None:
	for name in names:
		EXPECTED[f"{folder}/{name}.png"] = size


_expect("games/treasure-island/art/backdrops", ["beach", "tree", "ocean", "cavern", "hut"], (512, 384))
_expect("games/treasure-island/art/tiles", ["sand", "dirt", "wood", "rock", "cave"], (32, 32))
_expect(
	"games/treasure-island/art/tiles",
	["sand_ledge", "dirt_ledge", "wood_ledge", "rock_ledge", "cave_ledge"],
	(32, 16),
)
_expect(
	"games/treasure-island/art/tiles",
	[
		"pier",
		"bridge",
		"roof",
		"barrel_stack",
		"shelf",
		"rail",
		"water",
		"zone_glow_green",
		"zone_glow_blue",
	],
	(32, 16),
)
_expect("games/treasure-island/art/tiles", ["counter"], (32, 52))
_expect("shared/sprites/dizzy", ["idle", "walk_a", "walk_b", "jump", "roll_a", "roll_b"], (44, 56))
_expect(
	"games/treasure-island/art/items",
	[
		"default",
		"coin",
		"snorkel",
		"salt_spade",
		"glass_sword",
		"woodcutters_axe",
		"holy_bible",
		"dynamite",
		"detonator",
		"golden_key",
		"video_camera",
		"microwave",
		"cursed_treasure",
		"gold_bag",
		"dehydrated_boat",
		"outboard_motor",
		"petrol",
		"ignition_key",
		"plant_1",
		"plant_2",
		"plant_3",
		"plant_4",
		"skull_1",
		"skull_2",
		"tree_trunk_1",
		"tree_trunk_2",
		"wooden_rail_1",
		"wooden_rail_2",
		"mushrooms",
		"misty_window",
		"empty_bucket",
		"empty_chest",
		"heavy_rock",
		"toothpaste",
		"magazine",
	],
	(22, 22),
)
_expect("games/treasure-island/art/hazards", ["trap"], (32, 24))
_expect("games/treasure-island/art/hazards", ["fish", "crab"], (40, 24))
_expect("games/treasure-island/art/hazards", ["cuttlefish"], (40, 28))
_expect("games/treasure-island/art/npc", ["shopkeeper", "taxman"], (48, 72))
for relative, size in {
	"boat": (72, 40),
	"motor": (28, 32),
	"grave": (48, 52),
	"totem": (36, 72),
	"hatch": (48, 18),
	"bubble": (16, 16),
	"barrel": (32, 40),
	"door": (28, 44),
	"rock": (48, 32),
	"boulder": (64, 48),
	"stump": (48, 64),
	"hut": (40, 36),
	"shop_facade": (112, 76),
}.items():
	_expect("games/treasure-island/art/props", [relative], size)


def validate_outputs() -> None:
	errors: list[str] = []
	for relative, expected_size in EXPECTED.items():
		path = REPO_ROOT / relative
		if not path.is_file():
			errors.append(f"missing {relative}")
			continue
		try:
			with Image.open(path) as image:
				image.load()
				if image.mode != "RGBA":
					errors.append(f"{relative}: mode {image.mode}, expected RGBA")
				if image.size != expected_size:
					errors.append(f"{relative}: size {image.size}, expected {expected_size}")
				if image.getbbox() is None:
					errors.append(f"{relative}: image is fully transparent")
				if "/backdrops/" in relative and image.getextrema()[3] != (255, 255):
					errors.append(f"{relative}: backdrop contains transparent pixels")
		except OSError as exc:
			errors.append(f"{relative}: invalid PNG ({exc})")
	if errors:
		raise RuntimeError("Generated art validation failed:\n- " + "\n- ".join(errors))
	print(f"validated {len(EXPECTED)} generated PNGs under {REPO_ROOT}")


def main() -> None:
	generate_ti_backdrops.main()
	generate_ti_tiles.main()
	generate_ti_dizzy.main()
	generate_ti_sprites.main()
	validate_outputs()
	print("=== all TI art regenerated ===")


if __name__ == "__main__":
	main()
