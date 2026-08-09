#!/usr/bin/env python3
"""
Regenerate all Treasure Island pixel art (original homage, CC BY-NC).

Usage (from any working directory):
  python path/to/repo/scripts/generate_ti_art.py
"""
from __future__ import annotations

from PIL import Image

import generate_pregame_art
import generate_ti_backdrops
import generate_ti_dizzy
import generate_ti_sprites
import generate_ti_tiles
from ti_art_lib import REPO_ROOT


EXPECTED: dict[str, tuple[int, int]] = {}


def _expect(folder: str, names: list[str], size: tuple[int, int]) -> None:
	for name in names:
		EXPECTED[f"{folder}/{name}.png"] = size


_expect("games/treasure-island/art/backdrops", ["beach", "tree", "ocean", "cavern", "hut"], (1024, 768))
_expect("shared/ui/art", ["menu_night", "boot_splash", "victory_escape"], (1024, 768))
_expect("shared/ui/art", ["menu_dizzy"], (88, 112))
_expect("games/treasure-island/art/icons", ["select_ti"], (96, 96))
_expect("games/treasure-island/art/tiles", ["sand", "dirt", "wood", "rock", "cave"], (64, 64))
_expect(
	"games/treasure-island/art/tiles",
	["sand_ledge", "dirt_ledge", "wood_ledge", "rock_ledge", "cave_ledge"],
	(64, 32),
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
	(64, 32),
)
_expect("games/treasure-island/art/tiles", ["counter"], (64, 104))
_expect("shared/sprites/dizzy", ["idle", "walk_a", "walk_b", "jump", "roll_a", "roll_b"], (88, 112))
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
	(44, 44),
)
_expect("games/treasure-island/art/hazards", ["trap"], (64, 48))
_expect("games/treasure-island/art/hazards", ["fish", "crab"], (80, 48))
_expect("games/treasure-island/art/hazards", ["cuttlefish"], (80, 56))
_expect("games/treasure-island/art/npc", ["shopkeeper", "taxman"], (96, 144))
for relative, size in {
	"boat": (144, 80),
	"motor": (56, 64),
	"grave": (96, 104),
	"totem": (72, 144),
	"hatch": (96, 36),
	"bubble": (32, 32),
	"barrel": (64, 80),
	"door": (56, 88),
	"rock": (96, 64),
	"boulder": (128, 96),
	"stump": (96, 128),
	"hut": (80, 72),
	"shop_facade": (224, 152),
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
				if (
					"/backdrops/" in relative
					or relative in (
						"shared/ui/art/menu_night.png",
						"shared/ui/art/boot_splash.png",
						"shared/ui/art/victory_escape.png",
					)
				) and image.getextrema()[3] != (255, 255):
					errors.append(f"{relative}: full-screen art contains transparent pixels")
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
	generate_pregame_art.main()
	validate_outputs()
	print("=== all project and TI art regenerated ===")


if __name__ == "__main__":
	main()
