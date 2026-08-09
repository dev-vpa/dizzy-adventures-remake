#!/usr/bin/env python3
"""
Regenerate all Treasure Island pixel art (original homage, CC BY-NC).

Usage (from repo root):
  python scripts/generate_ti_art.py
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
	sys.path.insert(0, str(ROOT))


def main() -> None:
	import generate_ti_backdrops
	import generate_ti_dizzy
	import generate_ti_sprites
	import generate_ti_tiles

	generate_ti_backdrops.main()
	generate_ti_tiles.main()
	generate_ti_dizzy.main()
	generate_ti_sprites.main()
	print("=== all TI art regenerated ===")


if __name__ == "__main__":
	main()
